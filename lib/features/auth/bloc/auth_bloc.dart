import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:vsign_mobile_app/core/models/auth_models.dart';
import 'package:vsign_mobile_app/core/network/api_client.dart';
import 'package:vsign_mobile_app/core/network/analytics_service.dart';
import 'package:vsign_mobile_app/core/network/repositories.dart';

// --- Events ---
abstract class AuthEvent {}

class AppStarted extends AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  LoginRequested({required this.email, required this.password});
}

class RegisterRequested extends AuthEvent {
  final String displayName;
  final String email;
  final String password;
  RegisterRequested({required this.displayName, required this.email, required this.password});
}

class GoogleLoginSuccess extends AuthEvent {
  final String token;
  GoogleLoginSuccess({required this.token});
}

class LogoutRequested extends AuthEvent {}

// --- States ---
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final User user;
  Authenticated({required this.user});
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError({required this.message});
}

class RegisterSuccess extends AuthState {}

// --- BLoC ---
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repository = GetIt.instance<AuthRepository>();
  final ApiClient _client = GetIt.instance<ApiClient>();
  final AnalyticsService _analytics = GetIt.instance<AnalyticsService>();

  AuthBloc() : super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<GoogleLoginSuccess>(_onGoogleLoginSuccess);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final isLoggedIn = await _client.isLoggedIn();
      if (isLoggedIn) {
        final user = await _repository.getProfile();
        emit(Authenticated(user: user));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      // Clear token if invalid profile fetch
      await _client.clearAuthTokens();
      emit(Unauthenticated());
    }
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _repository.login(event.email, event.password);
      final user = await _repository.getProfile();
      await _analytics.logLogin('email');
      emit(Authenticated(user: user));
    } catch (e) {
      emit(AuthError(message: 'Tên đăng nhập hoặc mật khẩu không chính xác.'));
      emit(Unauthenticated());
    }
  }

  Future<void> _onRegisterRequested(RegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final success = await _repository.register(event.displayName, event.email, event.password);
      if (success) {
        await _analytics.logSignUp('email');
        emit(RegisterSuccess());
      } else {
        emit(AuthError(message: 'Không thể đăng ký tài khoản. Vui lòng kiểm tra lại.'));
      }
    } catch (e) {
      emit(AuthError(message: 'Email đã tồn tại hoặc dữ liệu không hợp lệ.'));
    }
  }

  Future<void> _onGoogleLoginSuccess(GoogleLoginSuccess event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _client.saveAuthTokens(event.token, null);
      final user = await _repository.getProfile();
      await _analytics.logLogin('google');
      emit(Authenticated(user: user));
    } catch (e) {
      await _client.clearAuthTokens();
      emit(AuthError(message: 'Không thể xác thực tài khoản Google.'));
      emit(Unauthenticated());
    }
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await _repository.logout();
    emit(Unauthenticated());
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:vsign_mobile_app/core/models/gamification_models.dart';
import 'package:vsign_mobile_app/core/network/repositories.dart';

// --- Events ---
abstract class GamificationEvent {}

class LoadGamificationSummary extends GamificationEvent {}

class LoadLeaderboardData extends GamificationEvent {
  final String period; // WEEKLY, MONTHLY
  LoadLeaderboardData({required this.period});
}

// --- States ---
abstract class GamificationState {}

class GamificationInitial extends GamificationState {}

class GamificationLoading extends GamificationState {}

class GamificationSummaryLoaded extends GamificationState {
  final GamificationSummary summary;
  GamificationSummaryLoaded({required this.summary});
}

class LeaderboardLoaded extends GamificationState {
  final List<LeaderboardEntry> entries;
  LeaderboardLoaded({required this.entries});
}

class GamificationError extends GamificationState {
  final String message;
  GamificationError({required this.message});
}

// --- BLoC ---
class GamificationBloc extends Bloc<GamificationEvent, GamificationState> {
  final GamificationRepository _repository = GetIt.instance<GamificationRepository>();

  GamificationBloc() : super(GamificationInitial()) {
    on<LoadGamificationSummary>(_onLoadGamificationSummary);
    on<LoadLeaderboardData>(_onLoadLeaderboardData);
  }

  Future<void> _onLoadGamificationSummary(LoadGamificationSummary event, Emitter<GamificationState> emit) async {
    emit(GamificationLoading());
    try {
      final summary = await _repository.getSummary();
      emit(GamificationSummaryLoaded(summary: summary));
    } catch (e) {
      emit(GamificationError(message: 'Không thể tải thông tin kinh nghiệm học tập.'));
    }
  }

  Future<void> _onLoadLeaderboardData(LoadLeaderboardData event, Emitter<GamificationState> emit) async {
    emit(GamificationLoading());
    try {
      final entries = await _repository.getLeaderboard(event.period);
      emit(LeaderboardLoaded(entries: entries));
    } catch (e) {
      emit(GamificationError(message: 'Không thể tải bảng xếp hạng học viên.'));
    }
  }
}

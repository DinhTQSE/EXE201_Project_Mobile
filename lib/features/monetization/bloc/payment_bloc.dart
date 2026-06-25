import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:vsign_mobile_app/core/models/payment_models.dart';
import 'package:vsign_mobile_app/core/network/repositories.dart';

// --- Events ---
abstract class PaymentEvent {}

class LoadPaymentPlans extends PaymentEvent {}

class CreateOrderRequested extends PaymentEvent {
  final String planType; // MONTHLY, YEARLY
  final String provider; // MOMO, ZALOPAY, PAYOS
  CreateOrderRequested({required this.planType, required this.provider});
}

// --- States ---
abstract class PaymentState {}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

class PaymentPlansLoaded extends PaymentState {
  final List<PaymentPlan> plans;
  PaymentPlansLoaded({required this.plans});
}

class PaymentOrderCreated extends PaymentState {
  final PaymentOrderResponse order;
  PaymentOrderCreated({required this.order});
}

class PaymentError extends PaymentState {
  final String message;
  PaymentError({required this.message});
}

// --- BLoC ---
class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final PaymentRepository _repository = GetIt.instance<PaymentRepository>();

  PaymentBloc() : super(PaymentInitial()) {
    on<LoadPaymentPlans>(_onLoadPaymentPlans);
    on<CreateOrderRequested>(_onCreateOrderRequested);
  }

  Future<void> _onLoadPaymentPlans(LoadPaymentPlans event, Emitter<PaymentState> emit) async {
    emit(PaymentLoading());
    try {
      final plans = await _repository.listPlans();
      emit(PaymentPlansLoaded(plans: plans));
    } catch (e) {
      emit(PaymentError(message: 'Không thể tải danh sách gói đăng ký.'));
    }
  }

  Future<void> _onCreateOrderRequested(CreateOrderRequested event, Emitter<PaymentState> emit) async {
    emit(PaymentLoading());
    try {
      final order = await _repository.createPaymentOrder(event.planType, event.provider);
      emit(PaymentOrderCreated(order: order));
    } catch (e) {
      emit(PaymentError(message: 'Tạo đơn thanh toán thất bại. Vui lòng thử lại.'));
    }
  }
}

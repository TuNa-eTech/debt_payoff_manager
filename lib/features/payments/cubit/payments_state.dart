import 'package:equatable/equatable.dart';

import '../../../../domain/entities/payment.dart';

/// State for payments feature.
sealed class PaymentsState extends Equatable {
  const PaymentsState();

  @override
  List<Object?> get props => [];
}

class PaymentsInitial extends PaymentsState {
  const PaymentsInitial();
}

class PaymentsLoading extends PaymentsState {
  const PaymentsLoading();
}

class PaymentsLoaded extends PaymentsState {
  const PaymentsLoaded({required this.payments});

  final List<Payment> payments;

  @override
  List<Object?> get props => [payments];
}

class PaymentSubmitting extends PaymentsState {
  const PaymentSubmitting();
}

class PaymentSubmitted extends PaymentsState {
  const PaymentSubmitted();
}

class PaymentsError extends PaymentsState {
  const PaymentsError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

// lib/core/error/failures.dart
import 'package:equatable/equatable.dart'; // FIX: Corrected import path

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

// General failures
class ServerFailure extends Failure {
  const ServerFailure({String message = 'حدث خطأ في الخادم، يرجى المحاولة مرة أخرى.'}) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure({String message = 'لا يوجد اتصال بالإنترنت.'}) : super(message);
}
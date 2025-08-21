// lib/core/usecase/usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:imarket/core/error/failures.dart';

// FIX: Changed 'Type' to 'T' to avoid conflict with Dart's built-in Type class.
// This resolves the 'avoid_types_as_parameter_names' lint warning.
abstract class UseCase<T, Params> {
  /// The `call` method for the use case.
  ///
  /// Returns an `Either` type, which contains a `Failure` on the left
  /// or the success type `T` on the right.
  Future<Either<Failure, T>> call(Params params);
}

/// A class to be used when a use case does not require any parameters.
class NoParams extends Equatable {
  @override
  List<Object?> get props => [];
}
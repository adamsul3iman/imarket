// FIX: Removed unused 'dart:io' import.
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:imarket/core/error/failures.dart';
import 'package:imarket/core/usecase/usecase.dart';
import 'package:imarket/domain/repositories/ad_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class SubmitAdUseCase implements UseCase<void, SubmitAdParams> {
  final AdRepository repository;

  SubmitAdUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(SubmitAdParams params) {
    return repository.submitAd(params);
  }
}

// This class will carry all the form data from the BLoC to the UseCase
class SubmitAdParams extends Equatable {
  final String? model;
  final int? storage;
  final String? color;
  final String? condition;
  final String? city;
  final String price;
  final String phoneNumber;
  final String? batteryHealth;
  final bool isRepaired;
  final String repairedParts;
  final bool hasBox;
  final bool hasCharger;
  final String description;
  final List<XFile> images;

  const SubmitAdParams({
    required this.model,
    required this.storage,
    required this.color,
    required this.condition,
    required this.city,
    required this.price,
    required this.phoneNumber,
    this.batteryHealth,
    required this.isRepaired,
    required this.repairedParts,
    required this.hasBox,
    required this.hasCharger,
    required this.description,
    required this.images,
  });

  @override
  List<Object?> get props => [
        model,
        storage,
        color,
        condition,
        city,
        price,
        phoneNumber,
        batteryHealth,
        isRepaired,
        repairedParts,
        hasBox,
        hasCharger,
        description,
        images,
      ];
}
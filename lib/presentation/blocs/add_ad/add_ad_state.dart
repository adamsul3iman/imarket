part of 'add_ad_bloc.dart';

// An enum to represent the form's submission status
enum FormSubmissionStatus { initial, submitting, success, failure }

class AddAdState extends Equatable {
  // Form fields
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
  final List<XFile> selectedImages;

  // Status fields
  final FormSubmissionStatus formStatus;
  final String? errorMessage;

  const AddAdState({
    this.model,
    this.storage,
    this.color,
    this.condition,
    this.city,
    this.price = '',
    this.phoneNumber = '',
    this.batteryHealth,
    this.isRepaired = false,
    this.repairedParts = '',
    this.hasBox = false,
    this.hasCharger = false,
    this.description = '',
    this.selectedImages = const [],
    this.formStatus = FormSubmissionStatus.initial,
    this.errorMessage,
  });

  // copyWith allows us to easily create a new state with updated values
  AddAdState copyWith({
    String? model,
    int? storage,
    String? color,
    String? condition,
    String? city,
    String? price,
    String? phoneNumber,
    String? batteryHealth,
    bool? isRepaired,
    String? repairedParts,
    bool? hasBox,
    bool? hasCharger,
    String? description,
    List<XFile>? selectedImages,
    FormSubmissionStatus? formStatus,
    String? errorMessage,
  }) {
    return AddAdState(
      model: model ?? this.model,
      storage: storage ?? this.storage,
      color: color ?? this.color,
      condition: condition ?? this.condition,
      city: city ?? this.city,
      price: price ?? this.price,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      batteryHealth: batteryHealth ?? this.batteryHealth,
      isRepaired: isRepaired ?? this.isRepaired,
      repairedParts: repairedParts ?? this.repairedParts,
      hasBox: hasBox ?? this.hasBox,
      hasCharger: hasCharger ?? this.hasCharger,
      description: description ?? this.description,
      selectedImages: selectedImages ?? this.selectedImages,
      formStatus: formStatus ?? this.formStatus,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

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
        selectedImages,
        formStatus,
        errorMessage,
      ];
}
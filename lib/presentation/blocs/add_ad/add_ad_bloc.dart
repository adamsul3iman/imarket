import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:imarket/domain/usecases/submit_ad_usecase.dart';
import 'package:injectable/injectable.dart';

part 'add_ad_event.dart';
part 'add_ad_state.dart';

@injectable
class AddAdBloc extends Bloc<AddAdEvent, AddAdState> {
  final SubmitAdUseCase _submitAdUseCase;
  final ImagePicker _imagePicker;

  AddAdBloc(this._submitAdUseCase, this._imagePicker) : super(const AddAdState()) {
    // Register handlers for all events
    on<AddAdModelChanged>(_onModelChanged);
    on<AddAdStorageChanged>(_onStorageChanged);
    on<AddAdColorChanged>(_onColorChanged);
    on<AddAdConditionChanged>(_onConditionChanged);
    on<AddAdCityChanged>(_onCityChanged);
    on<AddAdPriceChanged>(_onPriceChanged);
    on<AddAdPhoneNumberChanged>(_onPhoneNumberChanged);
    on<AddAdBatteryHealthChanged>(_onBatteryHealthChanged);
    on<AddAdIsRepairedChanged>(_onIsRepairedChanged);
    on<AddAdRepairedPartsChanged>(_onRepairedPartsChanged);
    on<AddAdHasBoxChanged>(_onHasBoxChanged);
    on<AddAdHasChargerChanged>(_onHasChargerChanged);
    on<AddAdDescriptionChanged>(_onDescriptionChanged);
    on<AddAdImagesPicked>(_onImagesPicked);
    on<AddAdSubmitted>(_onSubmitted);
  }

  // Event handlers simply emit a new state with the updated value
  void _onModelChanged(AddAdModelChanged event, Emitter<AddAdState> emit) {
    emit(state.copyWith(model: event.model));
  }
  void _onStorageChanged(AddAdStorageChanged event, Emitter<AddAdState> emit) {
    emit(state.copyWith(storage: event.storage));
  }
  void _onColorChanged(AddAdColorChanged event, Emitter<AddAdState> emit) {
    emit(state.copyWith(color: event.color));
  }
  void _onConditionChanged(AddAdConditionChanged event, Emitter<AddAdState> emit) {
    emit(state.copyWith(condition: event.condition));
  }
  void _onCityChanged(AddAdCityChanged event, Emitter<AddAdState> emit) {
    emit(state.copyWith(city: event.city));
  }
  void _onPriceChanged(AddAdPriceChanged event, Emitter<AddAdState> emit) {
    emit(state.copyWith(price: event.price));
  }
  void _onPhoneNumberChanged(AddAdPhoneNumberChanged event, Emitter<AddAdState> emit) {
    emit(state.copyWith(phoneNumber: event.phoneNumber));
  }
  void _onBatteryHealthChanged(AddAdBatteryHealthChanged event, Emitter<AddAdState> emit) {
    emit(state.copyWith(batteryHealth: event.batteryHealth));
  }
  void _onIsRepairedChanged(AddAdIsRepairedChanged event, Emitter<AddAdState> emit) {
    emit(state.copyWith(isRepaired: event.isRepaired));
  }
  void _onRepairedPartsChanged(AddAdRepairedPartsChanged event, Emitter<AddAdState> emit) {
    emit(state.copyWith(repairedParts: event.repairedParts));
  }
  void _onHasBoxChanged(AddAdHasBoxChanged event, Emitter<AddAdState> emit) {
    emit(state.copyWith(hasBox: event.hasBox));
  }
  void _onHasChargerChanged(AddAdHasChargerChanged event, Emitter<AddAdState> emit) {
    emit(state.copyWith(hasCharger: event.hasCharger));
  }
  void _onDescriptionChanged(AddAdDescriptionChanged event, Emitter<AddAdState> emit) {
    emit(state.copyWith(description: event.description));
  }
  
  Future<void> _onImagesPicked(AddAdImagesPicked event, Emitter<AddAdState> emit) async {
    final pickedImages = await _imagePicker.pickMultiImage(imageQuality: 50);
    emit(state.copyWith(selectedImages: pickedImages));
  }

  Future<void> _onSubmitted(AddAdSubmitted event, Emitter<AddAdState> emit) async {
    emit(state.copyWith(formStatus: FormSubmissionStatus.submitting));
    
    final params = SubmitAdParams(
      model: state.model,
      storage: state.storage,
      color: state.color,
      condition: state.condition,
      city: state.city,
      price: state.price,
      phoneNumber: state.phoneNumber,
      batteryHealth: state.batteryHealth,
      isRepaired: state.isRepaired,
      repairedParts: state.repairedParts,
      hasBox: state.hasBox,
      hasCharger: state.hasCharger,
      description: state.description,
      images: state.selectedImages,
    );

    final result = await _submitAdUseCase.call(params);

    result.fold(
      (failure) => emit(state.copyWith(formStatus: FormSubmissionStatus.failure, errorMessage: failure.message)),
      (_) => emit(state.copyWith(formStatus: FormSubmissionStatus.success)),
    );
  }
}
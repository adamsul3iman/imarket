import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:imarket/core/di/dependency_injection.dart';
import 'package:imarket/presentation/blocs/add_ad/add_ad_bloc.dart';
import 'package:imarket/presentation/widgets/action_success_dialog.dart';

/// الشاشة الرئيسية التي توفر BLoC وتستمع لتغييرات الحالة العامة (مثل نجاح أو فشل الإرسال).
class AddAdScreen extends StatelessWidget {
  const AddAdScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AddAdBloc>(),
      child: BlocListener<AddAdBloc, AddAdState>(
        listenWhen: (previous, current) =>
            previous.formStatus != current.formStatus,
        listener: (context, state) {
          if (state.formStatus == FormSubmissionStatus.success) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => ActionSuccessDialog(
                title: 'تم النشر بنجاح!',
                message: 'إعلانك الآن ظاهر لجميع المستخدمين في التطبيق.',
                onButtonPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(true);
                },
              ),
            );
          } else if (state.formStatus == FormSubmissionStatus.failure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                    content: Text(
                        state.errorMessage ?? 'An unexpected error occurred')),
              );
          }
        },
        child: const _AddAdView(),
      ),
    );
  }
}

/// الواجهة الفعلية للنموذج، وهي StatefulWidget لإدارة الـ Controllers ومفتاح النموذج.
class _AddAdView extends StatefulWidget {
  const _AddAdView();

  @override
  State<_AddAdView> createState() => _AddAdViewState();
}

class _AddAdViewState extends State<_AddAdView> {
  final _formKey = GlobalKey<FormState>();

  final _priceController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _repairedPartsController = TextEditingController();
  final _batteryHealthController = TextEditingController();

  static const List<String> _iphoneModels = [
    'iPhone 15 Pro Max',
    'iPhone 15 Pro',
    'iPhone 15 Plus',
    'iPhone 15',
    'iPhone 14 Pro Max',
    'iPhone 14 Pro',
    'iPhone 14 Plus',
    'iPhone 14',
    'iPhone 13 Pro Max',
    'iPhone 13 Pro',
    'iPhone 13',
    'iPhone 13 mini',
    'iPhone 12 Pro Max',
    'iPhone 12 Pro',
    'iPhone 12',
    'iPhone 12 mini',
    'iPhone 11 Pro Max',
    'iPhone 11 Pro',
    'iPhone 11'
  ];
  static const List<int> _storageOptions = [64, 128, 256, 512, 1024];
  static const List<String> _colorOptions = [
    'تيتانيوم طبيعي',
    'تيتانيوم أزرق',
    'تيتانيوم أبيض',
    'تيتانيوم أسود',
    'بنفسجي غامق',
    'ذهبي',
    'فضي',
    'رصاصي (غرافيت)',
    'أزرق سييرا',
    'أزرق',
    'أخضر',
    'أحمر',
    'وردي',
    'أصفر',
    'ضوء النجوم (ستارلايت)',
    'سماء الليل (ميدنايت)',
    'أسود',
    'أبيض'
  ];
  static const List<String> _conditionOptions = [
    'جديد (مغلق بالكرتونة)',
    'مستعمل - بحالة ممتازة (كالجديد)',
    'مستعمل - بحالة جيدة جداً',
    'مستعمل - بحالة جيدة'
  ];
  static const List<String> _cityOptions = [
    'عمان',
    'إربد',
    'الزرقاء',
    'البلقاء',
    'المفرق',
    'جرش',
    'عجلون',
    'مادبا',
    'الكرك',
    'الطفيلة',
    'معان',
    'العقبة'
  ];

  @override
  void dispose() {
    _priceController.dispose();
    _phoneNumberController.dispose();
    _descriptionController.dispose();
    _repairedPartsController.dispose();
    _batteryHealthController.dispose();
    super.dispose();
  }

  /// دالة مساعدة لإنشاء تصميم موحد لحقول الإدخال.
  InputDecoration _inputDecoration(
      {required String label, Widget? prefixIcon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: prefixIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = context.select((AddAdBloc bloc) =>
        bloc.state.formStatus == FormSubmissionStatus.submitting);

    return Scaffold(
      appBar: AppBar(title: const Text('إضافة إعلان جديد')),
      body: isSubmitting
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildImagePicker(),
                    const SizedBox(height: 24),
                    _buildDropdowns(),
                    const SizedBox(height: 16),
                    _buildTextFields(),
                    _buildRepairSection(),
                    const SizedBox(height: 16),
                    _buildAccessorySwitches(),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() == true) {
                          context.read<AddAdBloc>().add(AddAdSubmitted());
                        }
                      },
                      child: const Text('نشر الإعلان'),
                    )
                  ],
                ),
              ),
            ),
    );
  }

  /// ويدجت مسؤول عن عرض واختيار الصور.
  Widget _buildImagePicker() {
    return BlocSelector<AddAdBloc, AddAdState, List<XFile>>(
      selector: (state) => state.selectedImages,
      builder: (context, selectedImages) {
        return InkWell(
          onTap: () =>
              context.read<AddAdBloc>().add(const AddAdImagesPicked([])),
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(12),
            ),
            child: selectedImages.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: kIsWeb
                        ? Image.network(selectedImages[0].path,
                            fit: BoxFit.cover)
                        : Image.file(File(selectedImages[0].path),
                            fit: BoxFit.cover),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo_outlined,
                          size: 50, color: Colors.grey.shade600),
                      const SizedBox(height: 8),
                      const Text('أضف صورة أو أكثر'),
                    ],
                  ),
          ),
        );
      },
    );
  }

  /// ويدجت يجمع كل القوائم المنسدلة في النموذج.
  Widget _buildDropdowns() {
    return Column(
      children: [
        BlocBuilder<AddAdBloc, AddAdState>(
          buildWhen: (p, c) => p.model != c.model,
          builder: (context, state) {
            return DropdownButtonFormField<String>(
              initialValue: state.model,
              decoration: _inputDecoration(
                  label: 'نوع الآيفون',
                  prefixIcon: const Icon(Icons.phone_iphone)),
              items: _iphoneModels
                  .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                  .toList(),
              onChanged: (val) =>
                  context.read<AddAdBloc>().add(AddAdModelChanged(val)),
              validator: (val) => val == null ? 'الحقل مطلوب' : null,
            );
          },
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ FIX: Added Expanded widget here
            Expanded(
              child: BlocBuilder<AddAdBloc, AddAdState>(
                buildWhen: (p, c) => p.storage != c.storage,
                builder: (context, state) {
                  return DropdownButtonFormField<int>(
                    initialValue: state.storage,
                    decoration: _inputDecoration(
                        label: 'السعة', prefixIcon: const Icon(Icons.storage)),
                    items: _storageOptions
                        .map((s) =>
                            DropdownMenuItem(value: s, child: Text('$s GB')))
                        .toList(),
                    onChanged: (val) =>
                        context.read<AddAdBloc>().add(AddAdStorageChanged(val)),
                    validator: (val) => val == null ? 'الحقل مطلوب' : null,
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            // ✅ FIX: Added Expanded widget here
            Expanded(
              child: BlocBuilder<AddAdBloc, AddAdState>(
                buildWhen: (p, c) => p.color != c.color,
                builder: (context, state) {
                  return DropdownButtonFormField<String>(
                    initialValue: state.color,
                    decoration: _inputDecoration(
                        label: 'اللون',
                        prefixIcon: const Icon(Icons.color_lens_outlined)),
                    items: _colorOptions
                        .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(c, overflow: TextOverflow.ellipsis)))
                        .toList(),
                    onChanged: (val) =>
                        context.read<AddAdBloc>().add(AddAdColorChanged(val)),
                    validator: (val) => val == null ? 'الحقل مطلوب' : null,
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        BlocBuilder<AddAdBloc, AddAdState>(
          buildWhen: (p, c) => p.condition != c.condition,
          builder: (context, state) {
            return DropdownButtonFormField<String>(
              initialValue: state.condition,
              decoration: _inputDecoration(
                  label: 'الحالة', prefixIcon: const Icon(Icons.info_outline)),
              items: _conditionOptions
                  .map((c) => DropdownMenuItem(
                      value: c,
                      child: Text(c, overflow: TextOverflow.ellipsis)))
                  .toList(),
              onChanged: (val) =>
                  context.read<AddAdBloc>().add(AddAdConditionChanged(val)),
              validator: (val) => val == null ? 'الحقل مطلوب' : null,
            );
          },
        ),
        const SizedBox(height: 16),
        BlocBuilder<AddAdBloc, AddAdState>(
          buildWhen: (p, c) => p.city != c.city,
          builder: (context, state) {
            return DropdownButtonFormField<String>(
              initialValue: state.city,
              decoration: _inputDecoration(
                  label: 'المدينة',
                  prefixIcon: const Icon(Icons.location_city)),
              items: _cityOptions
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) =>
                  context.read<AddAdBloc>().add(AddAdCityChanged(val)),
              validator: (val) => val == null ? 'الحقل مطلوب' : null,
            );
          },
        ),
      ],
    );
  }

  /// ويدجت يجمع حقول إدخال النص.
  Widget _buildTextFields() {
    return Column(
      children: [
        TextFormField(
          controller: _priceController,
          onChanged: (value) =>
              context.read<AddAdBloc>().add(AddAdPriceChanged(value)),
          decoration: _inputDecoration(
              label: 'السعر (دينار)',
              prefixIcon: const Icon(Icons.attach_money)),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (val) => val == null || val.isEmpty ? 'الحقل مطلوب' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _phoneNumberController,
          onChanged: (value) =>
              context.read<AddAdBloc>().add(AddAdPhoneNumberChanged(value)),
          decoration: _inputDecoration(
            label: 'رقم الهاتف',
            prefixIcon: const Icon(Icons.phone_android_outlined),
          ).copyWith(
            prefixText: '+962 ',
            hintText: '791234567',
          ),
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(9),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) return 'الحقل مطلوب';
            if (!value.startsWith('7')) return 'يجب أن يبدأ الرقم بالرقم 7';
            if (value.length != 9) return 'يجب أن يتكون الرقم من 9 أرقام';
            return null;
          },
        ),
      ],
    );
  }

  /// ويدجت يعرض قسم الإصلاح بشكل شرطي.
  Widget _buildRepairSection() {
    return BlocBuilder<AddAdBloc, AddAdState>(
      buildWhen: (p, c) =>
          p.condition != c.condition || p.isRepaired != c.isRepaired,
      builder: (context, state) {
        if (state.condition == 'جديد (مغلق بالكرتونة)') {
          return const SizedBox.shrink();
        }
        return Column(
          children: [
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('تم إصلاح الهاتف'),
              value: state.isRepaired,
              onChanged: (val) =>
                  context.read<AddAdBloc>().add(AddAdIsRepairedChanged(val)),
            ),
            if (state.isRepaired)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: TextFormField(
                  controller: _repairedPartsController,
                  onChanged: (value) => context
                      .read<AddAdBloc>()
                      .add(AddAdRepairedPartsChanged(value)),
                  decoration: _inputDecoration(
                      label: 'الأجزاء التي تم إصلاحها',
                      prefixIcon: const Icon(Icons.build)),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'مطلوب' : null,
                ),
              ),
          ],
        );
      },
    );
  }

  /// ويدجت يجمع الحقول المتبقية (صحة البطارية، الملحقات، الوصف).
  Widget _buildAccessorySwitches() {
    return Column(
      children: [
        TextFormField(
          controller: _batteryHealthController,
          onChanged: (value) =>
              context.read<AddAdBloc>().add(AddAdBatteryHealthChanged(value)),
          decoration: _inputDecoration(
              label: 'حالة البطارية (%)',
              prefixIcon: const Icon(Icons.battery_full)),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(3)
          ],
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              final percentage = int.tryParse(value);
              if (percentage == null || percentage < 0 || percentage > 100) {
                return 'أدخل نسبة بين 0 و 100';
              }
            }
            return null;
          },
        ),
        BlocBuilder<AddAdBloc, AddAdState>(
          buildWhen: (p, c) => p.hasBox != c.hasBox,
          builder: (context, state) {
            return SwitchListTile(
              title: const Text('العلبة الأصلية متوفرة'),
              value: state.hasBox,
              onChanged: (val) =>
                  context.read<AddAdBloc>().add(AddAdHasBoxChanged(val)),
            );
          },
        ),
        BlocBuilder<AddAdBloc, AddAdState>(
          buildWhen: (p, c) => p.hasCharger != c.hasCharger,
          builder: (context, state) {
            return SwitchListTile(
              title: const Text('الشاحن الأصلي متوفر'),
              value: state.hasCharger,
              onChanged: (val) =>
                  context.read<AddAdBloc>().add(AddAdHasChargerChanged(val)),
            );
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          onChanged: (value) =>
              context.read<AddAdBloc>().add(AddAdDescriptionChanged(value)),
          maxLines: 4,
          decoration: _inputDecoration(
              label: 'ملاحظات إضافية', prefixIcon: const Icon(Icons.notes)),
        ),
      ],
    );
  }
}

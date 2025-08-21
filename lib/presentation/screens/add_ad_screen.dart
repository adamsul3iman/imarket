import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:imarket/main.dart';
import 'package:imarket/models/ad_model.dart';
import 'package:imarket/presentation/screens/paywall_screen.dart';
import 'package:imarket/presentation/widgets/action_success_dialog.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class AddAdScreen extends StatefulWidget {
  final AdModel? adToEdit;
  const AddAdScreen({super.key, this.adToEdit});

  @override
  State<AddAdScreen> createState() => _AddAdScreenState();
}

class _AddAdScreenState extends State<AddAdScreen> {
  final _formKey = GlobalKey<FormState>();
  final _batteryHealthController = TextEditingController();
  final _priceController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _repairedPartsController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  List<XFile> _selectedImageFiles = [];
  final List<Uint8List> _selectedImageBytes = [];
  String? _selectedModel;
  int? _selectedStorage;
  String? _selectedColor;
  String? _selectedCondition;
  String? _selectedCity;
  bool? _isRepaired;
  bool _isLoading = false;
  bool _hasBox = false;
  bool _hasCharger = false;
  bool get _isEditMode => widget.adToEdit != null;

  static const List<String> _iphoneModels = [
    'iPhone 16 Pro Max',
    'iPhone 16 Pro',
    'iPhone 16 Plus',
    'iPhone 16',
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
    'iPhone 11',
    'iPhone XS Max',
    'iPhone XS',
    'iPhone XR',
    'iPhone X',
    'iPhone 8 Plus',
    'iPhone 8',
    'iPhone SE (3rd generation)',
    'iPhone SE (2nd generation)'
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
  void initState() {
    super.initState();
    _populateFields();
  }

  void _populateFields() {
    final userPhoneNumber =
        supabase.auth.currentUser?.phone?.replaceFirst('+962', '');

// هنا يتم وضع الرقم المنسق في خانة الإدخال
    if (userPhoneNumber != null && userPhoneNumber.isNotEmpty) {
      _phoneNumberController.text = userPhoneNumber;
    }

    if (_isEditMode) {
      final ad = widget.adToEdit!;
      _selectedModel = ad.model;
      _selectedStorage = ad.storage;
      _selectedColor = ad.colorAr;
      _selectedCondition = ad.conditionAr;
      _isRepaired = ad.isRepaired;
      _repairedPartsController.text = ad.repairedParts ?? '';
      _batteryHealthController.text = ad.batteryHealth?.toString() ?? '';
      _hasBox = ad.hasBox ?? false;
      _hasCharger = ad.hasCharger ?? false;
      _selectedCity = ad.city;
      _priceController.text = ad.price.toString();
      _phoneNumberController.text =
          ad.phoneNumber?.replaceFirst('+962', '') ?? userPhoneNumber ?? '';
      _descriptionController.text = ad.description ?? '';
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    _phoneNumberController.dispose();
    _descriptionController.dispose();
    _repairedPartsController.dispose();
    _batteryHealthController.dispose();
    super.dispose();
  }

  Future<(bool, String?)> _canPostAnotherAd() async {
    if (_isEditMode) return (true, null);
    final userId = supabase.auth.currentUser!.id;
    try {
      final subResponse = await supabase
          .from('user_subscriptions')
          .select('*, subscription_plans!inner(max_active_ads)')
          .eq('user_id', userId)
          .eq('status', 'active')
          .gte('ends_at', DateTime.now().toIso8601String())
          .maybeSingle();
      final maxAds =
          subResponse?['subscription_plans']?['max_active_ads'] as int? ?? 3;
      final countResponse =
          await supabase.from('ads').select().eq('user_id', userId).count();

      final currentCount = countResponse.count;
      if (currentCount >= maxAds) {
        return (
          false,
          'لقد وصلت للحد الأقصى للإعلانات في خطتك ($maxAds). قم بالترقية لزيادة الحد.'
        );
      }
      return (true, null);
    } catch (e) {
      return (false, 'حدث خطأ أثناء التحقق من خطة الاشتراك.');
    }
  }

  Future<void> _pickImage() async {
    final pickedImages = await _picker.pickMultiImage(imageQuality: 50);
    if (pickedImages.isNotEmpty) {
      _selectedImageFiles = pickedImages;
      _selectedImageBytes.clear();
      for (var file in pickedImages) {
        final bytes = await file.readAsBytes();
        _selectedImageBytes.add(bytes);
      }
      if (mounted) setState(() {});
    }
  }

  Future<void> _saveAd() async {
    if (!_formKey.currentState!.validate()) return;

    final (canPost, message) = await _canPostAnotherAd();
    if (!canPost && mounted) {
      _showUpgradeSnackbar(message!);
      return;
    }

    if (!_isEditMode && _selectedImageFiles.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('الرجاء اختيار صورة واحدة على الأقل.')));
      }
      return;
    }

    setState(() => _isLoading = true);
    try {
      final userId = supabase.auth.currentUser!.id;
      final List<String> imageUrls = [];
      if (_selectedImageFiles.isNotEmpty) {
        for (int i = 0; i < _selectedImageFiles.length; i++) {
          final file = _selectedImageFiles[i];
          final imageId = const Uuid().v4();
          final imagePath = '$userId/$imageId.jpg';

          if (kIsWeb) {
            await supabase.storage.from('ad_images').uploadBinary(
                  imagePath,
                  _selectedImageBytes[i],
                  fileOptions: const FileOptions(contentType: 'image/jpeg'),
                );
          } else {
            await supabase.storage.from('ad_images').upload(
                  imagePath,
                  File(file.path),
                  fileOptions: const FileOptions(contentType: 'image/jpeg'),
                );
          }

          imageUrls
              .add(supabase.storage.from('ad_images').getPublicUrl(imagePath));
        }
      } else if (_isEditMode) {
        imageUrls.addAll(widget.adToEdit!.imageUrls);
      }

      final adData = {
        'user_id': userId,
        'title': '$_selectedModel - $_selectedStorage GB',
        'price': int.parse(_priceController.text),
        'phone_number': '+962${_phoneNumberController.text.trim()}',
        'description': _descriptionController.text.trim(),
        'image_urls': imageUrls,
        'model': _selectedModel,
        'storage': _selectedStorage,
        'color_ar': _selectedColor,
        'condition_ar': _selectedCondition,
        'city': _selectedCity,
        'is_repaired':
            _selectedCondition != 'جديد (مغلق بالكرتونة)' ? _isRepaired : false,
        'repaired_parts':
            _isRepaired == true ? _repairedPartsController.text.trim() : null,
        'battery_health': _batteryHealthController.text.isNotEmpty
            ? int.parse(_batteryHealthController.text)
            : null,
        'has_box': _hasBox,
        'has_charger': _hasCharger,
      };

      if (_isEditMode) {
        await supabase.from('ads').update(adData).eq('id', widget.adToEdit!.id);
      } else {
        await supabase.from('ads').insert(adData);
      }

      if (!mounted) return;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => ActionSuccessDialog(
          title: _isEditMode ? 'تم التعديل بنجاح!' : 'تم النشر بنجاح!',
          message: 'إعلانك الآن ظاهر لجميع المستخدمين في التطبيق.',
          onButtonPressed: () {
            Navigator.of(dialogContext).pop();
          },
        ),
      );

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('حدث خطأ غير متوقع: $e')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showUpgradeSnackbar(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 5),
      action: SnackBarAction(
        label: 'ترقية الآن',
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const PaywallScreen()));
        },
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  InputDecoration _inputDecoration(
      {required String label, required IconData icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool showRepairSection =
        _selectedCondition != 'جديد (مغلق بالكرتونة)';
    return Scaffold(
      appBar: AppBar(
          title: Text(_isEditMode ? 'تعديل الإعلان' : 'إضافة إعلان جديد')),
      body: _isLoading
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
                    if (showRepairSection) ...[
                      const SizedBox(height: 16),
                      _buildRepairSection(),
                    ],
                    const SizedBox(height: 16),
                    _buildAccessorySwitches(),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _saveAd,
                      child:
                          Text(_isEditMode ? 'تحديث الإعلان' : 'نشر الإعلان'),
                    )
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildImagePicker() {
    return InkWell(
      onTap: _pickImage,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(12)),
        child: _selectedImageBytes.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: kIsWeb
                    ? Image.memory(_selectedImageBytes[0], fit: BoxFit.cover)
                    : Image.file(File(_selectedImageFiles[0].path),
                        fit: BoxFit.cover))
            : (_isEditMode && widget.adToEdit!.imageUrls.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(widget.adToEdit!.imageUrls[0],
                        fit: BoxFit.cover))
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo_outlined,
                          size: 50, color: Colors.grey.shade600),
                      const SizedBox(height: 8),
                      const Text('أضف صورة أو أكثر')
                    ],
                  )),
      ),
    );
  }

  Widget _buildDropdowns() {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          initialValue: _selectedModel,
          decoration:
              _inputDecoration(label: 'نوع الآيفون', icon: Icons.phone_iphone),
          items: _iphoneModels
              .map((m) => DropdownMenuItem(value: m, child: Text(m)))
              .toList(),
          onChanged: (val) => setState(() => _selectedModel = val),
          validator: (val) => val == null ? 'الحقل مطلوب' : null,
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 350) {
              return Column(
                children: [
                  DropdownButtonFormField<int>(
                    initialValue: _selectedStorage,
                    decoration:
                        _inputDecoration(label: 'السعة', icon: Icons.storage),
                    items: _storageOptions
                        .map((s) =>
                            DropdownMenuItem(value: s, child: Text('$s GB')))
                        .toList(),
                    onChanged: (val) => setState(() => _selectedStorage = val),
                    validator: (val) => val == null ? 'الحقل مطلوب' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedColor,
                    decoration: _inputDecoration(
                        label: 'اللون', icon: Icons.color_lens_outlined),
                    items: _colorOptions
                        .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(c, overflow: TextOverflow.ellipsis)))
                        .toList(),
                    onChanged: (val) => setState(() => _selectedColor = val),
                    validator: (val) => val == null ? 'الحقل مطلوب' : null,
                  ),
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: DropdownButtonFormField<int>(
                    initialValue: _selectedStorage,
                    decoration:
                        _inputDecoration(label: 'السعة', icon: Icons.storage),
                    items: _storageOptions
                        .map((s) =>
                            DropdownMenuItem(value: s, child: Text('$s GB')))
                        .toList(),
                    onChanged: (val) => setState(() => _selectedStorage = val),
                    validator: (val) => val == null ? 'الحقل مطلوب' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Flexible(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedColor,
                    decoration: _inputDecoration(
                        label: 'اللون', icon: Icons.color_lens_outlined),
                    items: _colorOptions
                        .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(c, overflow: TextOverflow.ellipsis)))
                        .toList(),
                    onChanged: (val) => setState(() => _selectedColor = val),
                    validator: (val) => val == null ? 'الحقل مطلوب' : null,
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: _selectedCondition,
          decoration:
              _inputDecoration(label: 'الحالة', icon: Icons.info_outline),
          items: _conditionOptions
              .map((c) => DropdownMenuItem(
                  value: c, child: Text(c, overflow: TextOverflow.ellipsis)))
              .toList(),
          onChanged: (val) => setState(() => _selectedCondition = val),
          validator: (val) => val == null ? 'الحقل مطلوب' : null,
        ),
      ],
    );
  }

  Widget _buildTextFields() {
    return Column(
      children: [
        TextFormField(
          controller: _priceController,
          decoration: _inputDecoration(
              label: 'السعر (دينار)', icon: Icons.attach_money),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (val) => val == null || val.isEmpty ? 'الحقل مطلوب' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _phoneNumberController,
          decoration: _inputDecoration(
            label: 'رقم الهاتف',
            icon: Icons.phone_android_outlined,
          ).copyWith(
            prefixText: '+962 ',
            hintText: '791234567',
            hintStyle: TextStyle(
              color: Theme.of(context).hintColor.withAlpha((255 * 0.5).round()),
            ),
          ),
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(9),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'الحقل مطلوب';
            }
            if (!value.startsWith('7')) {
              return 'يجب أن يبدأ الرقم بالرقم 7';
            }
            if (value.length != 9) {
              return 'يجب أن يتكون الرقم من 9 أرقام';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: _selectedCity,
          decoration:
              _inputDecoration(label: 'المدينة', icon: Icons.location_city),
          items: _cityOptions
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: (val) => setState(() => _selectedCity = val),
          validator: (val) => val == null ? 'مطلوب' : null,
        ),
      ],
    );
  }

  Widget _buildRepairSection() {
    return Column(
      children: [
        SwitchListTile(
          title: const Text('تم إصلاح الهاتف'),
          value: _isRepaired ?? false,
          onChanged: (val) => setState(() => _isRepaired = val),
        ),
        if (_isRepaired == true)
          TextFormField(
            controller: _repairedPartsController,
            decoration: _inputDecoration(
                label: 'الأجزاء التي تم إصلاحها', icon: Icons.build),
            validator: (val) => val == null || val.isEmpty ? 'مطلوب' : null,
          ),
      ],
    );
  }

  Widget _buildAccessorySwitches() {
    return Column(
      children: [
        TextFormField(
          controller: _batteryHealthController,
          decoration: _inputDecoration(
              label: 'حالة البطارية (%)', icon: Icons.battery_full),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(3),
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
        SwitchListTile(
          title: const Text('العلبة الأصلية متوفرة'),
          value: _hasBox,
          onChanged: (val) => setState(() => _hasBox = val),
        ),
        SwitchListTile(
          title: const Text('الشاحن الأصلي متوفر'),
          value: _hasCharger,
          onChanged: (val) => setState(() => _hasCharger = val),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          maxLines: 4,
          decoration:
              _inputDecoration(label: 'ملاحظات إضافية', icon: Icons.notes),
        ),
      ],
    );
  }
}

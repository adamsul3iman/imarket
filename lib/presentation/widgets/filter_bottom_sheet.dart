import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FilterBottomSheet extends StatefulWidget {
  final Map<String, dynamic> initialFilters;

  /// Creates a [FilterBottomSheet].
  const FilterBottomSheet({super.key, required this.initialFilters});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late TextEditingController _minPriceController;
  late TextEditingController _maxPriceController;
  String? _selectedCity;
  String? _selectedCondition;
  String? _selectedModel;
  int? _selectedStorage;
  String? _selectedColor;
  bool _hasBox = false;
  bool _hasCharger = false;
  int? _selectedMinBattery;

  // Static const lists for performance optimization
  static const List<String> _iphoneModels = [
    'iPhone 16 Pro Max', 'iPhone 16 Pro', 'iPhone 16 Plus',
    'iPhone 16', // Added new models
    'iPhone 15 Pro Max', 'iPhone 15 Pro', 'iPhone 15 Plus', 'iPhone 15',
    'iPhone 14 Pro Max', 'iPhone 14 Pro', 'iPhone 14 Plus', 'iPhone 14',
    'iPhone 13 Pro Max', 'iPhone 13 Pro', 'iPhone 13', 'iPhone 13 mini',
    'iPhone 12 Pro Max', 'iPhone 12 Pro', 'iPhone 12', 'iPhone 12 mini',
    'iPhone 11 Pro Max', 'iPhone 11 Pro', 'iPhone 11',
    'iPhone XS Max', 'iPhone XS', 'iPhone XR', 'iPhone X',
    'iPhone 8 Plus', 'iPhone 8', 'iPhone SE (3rd generation)',
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
    'جديد ( بالكرتونة)',
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
  static const Map<String, int> _batteryOptions = {
    '%95 فما فوق': 95,
    '%90 فما فوق': 90,
    '%85 فما فوق': 85,
    '%80 فما فوق': 80,
    '%75 فما فوق': 75,
    '%70 فما فوق': 70,
  };

  @override
  void initState() {
    super.initState();
    // Initialize state from the passed-in filters
    _selectedCity = widget.initialFilters['city'];
    _selectedCondition = widget.initialFilters['condition'];
    _selectedModel = widget.initialFilters['model'];
    _selectedStorage = widget.initialFilters['storage'];
    _selectedColor = widget.initialFilters['color'];
    _hasBox = widget.initialFilters['hasBox'] ?? false;
    _hasCharger = widget.initialFilters['hasCharger'] ?? false;
    _selectedMinBattery = widget.initialFilters['minBattery'];
    _minPriceController = TextEditingController(
        text: widget.initialFilters['minPrice']?.toString() ?? '');
    _maxPriceController = TextEditingController(
        text: widget.initialFilters['maxPrice']?.toString() ?? '');
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  /// Resets all filters and closes the bottom sheet.
  void _resetFilters() {
    Navigator.pop(context, <String, dynamic>{});
  }

  /// Applies the selected filters and closes the bottom sheet.
  void _applyFilters() {
    final filters = {
      'city': _selectedCity,
      'condition': _selectedCondition,
      'model': _selectedModel,
      'storage': _selectedStorage,
      'color': _selectedColor,
      'hasBox': _hasBox,
      'hasCharger': _hasCharger,
      'minPrice': int.tryParse(_minPriceController.text),
      'maxPrice': int.tryParse(_maxPriceController.text),
      'minBattery': _selectedMinBattery,
    };
    // Remove null values to keep the filter map clean
    filters.removeWhere((key, value) => value == null);
    Navigator.pop(context, filters);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: Scaffold(
            appBar: AppBar(
              title: const Text('فلترة النتائج'),
              automaticallyImplyLeading: false,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
            body: ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildSectionTitle('المحافظة', Icons.location_city_outlined),
                _buildHorizontalChipList<String>(_cityOptions, _selectedCity,
                    (val) => setState(() => _selectedCity = val)),
                const SizedBox(height: 24),
                _buildSectionTitle('نوع الجهاز', Icons.phone_iphone_outlined),
                _buildHorizontalChipList<String>(_iphoneModels, _selectedModel,
                    (val) => setState(() => _selectedModel = val)),
                const SizedBox(height: 24),
                _buildSectionTitle('السعة', Icons.storage_outlined),
                _buildHorizontalChipList<int>(
                    _storageOptions,
                    _selectedStorage,
                    (val) => setState(() => _selectedStorage = val),
                    (item) => '$item GB'),
                const SizedBox(height: 24),
                _buildSectionTitle('اللون', Icons.color_lens_outlined),
                _buildHorizontalChipList<String>(_colorOptions, _selectedColor,
                    (val) => setState(() => _selectedColor = val)),
                const SizedBox(height: 24),
                _buildSectionTitle(
                    'حالة الجهاز', Icons.bookmark_border_outlined),
                _buildHorizontalChipList<String>(
                    _conditionOptions,
                    _selectedCondition,
                    (val) => setState(() => _selectedCondition = val)),
                const SizedBox(height: 24),
                _buildSectionTitle(
                    'أقل صحة للبطارية', Icons.battery_charging_full_outlined),
                _buildHorizontalChipList<int>(
                    _batteryOptions.values.toList(),
                    _selectedMinBattery,
                    (val) => setState(() => _selectedMinBattery = val),
                    (item) => _batteryOptions.entries
                        .firstWhere((e) => e.value == item)
                        .key),
                const SizedBox(height: 24),
                _buildSectionTitle('الملحقات', Icons.extension_outlined),
                Row(
                  children: [
                    _buildFilterChip('مع العلبة', _hasBox,
                        (val) => setState(() => _hasBox = val)),
                    const SizedBox(width: 8),
                    _buildFilterChip('مع الشاحن', _hasCharger,
                        (val) => setState(() => _hasCharger = val)),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSectionTitle(
                    'السعر (دينار)', Icons.attach_money_outlined),
                Row(
                  children: [
                    Expanded(
                        child: _buildPriceTextField(
                            _minPriceController, 'أدنى سعر')),
                    const SizedBox(width: 16, child: Center(child: Text('-'))),
                    Expanded(
                        child: _buildPriceTextField(
                            _maxPriceController, 'أعلى سعر')),
                  ],
                ),
              ],
            ),
            bottomNavigationBar: _buildActionButtons(),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(top: BorderSide(color: Colors.grey.shade200))),
      child: Row(
        children: [
          Expanded(
              child: TextButton(
                  onPressed: _resetFilters,
                  child: const Text('إعادة تعيين الكل'))),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _applyFilters,
              icon: const Icon(Icons.check),
              label: const Text('تطبيق'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade700),
          const SizedBox(width: 8),
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildHorizontalChipList<T>(
      List<T> items, T? selectedValue, ValueChanged<T?> onSelected,
      [String Function(T)? labelBuilder]) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length + 1, // +1 for the "All" chip
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            return ChoiceChip(
              label: const Text('الكل'),
              selected: selectedValue == null,
              onSelected: (isSelected) => onSelected(null),
            );
          }
          final item = items[index - 1];
          return ChoiceChip(
            label: Text(
                labelBuilder != null ? labelBuilder(item) : item.toString()),
            selected: selectedValue == item,
            onSelected: (isSelected) => onSelected(isSelected ? item : null),
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(
      String label, bool isSelected, ValueChanged<bool> onSelected) {
    return FilterChip(
        label: Text(label), selected: isSelected, onSelected: onSelected);
  }

  Widget _buildPriceTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    );
  }
}

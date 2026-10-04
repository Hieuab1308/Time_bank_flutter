import 'package:flutter/material.dart';

class ServiceFilter extends StatefulWidget {
  final Function(String?) onCategoryChanged;
  final Function(String?) onLocationChanged;
  final Function(RangeValues?) onTimeCreditsChanged;

  const ServiceFilter({
    super.key,
    required this.onCategoryChanged,
    required this.onLocationChanged,
    required this.onTimeCreditsChanged,
  });

  @override
  State<ServiceFilter> createState() => _ServiceFilterState();
}

class _ServiceFilterState extends State<ServiceFilter> {
  String? selectedCategory;
  String? selectedLocation;
  RangeValues? timeCreditsRange;

  final List<String> categories = [
    'Tất cả',
    'Giáo dục',
    'Chăm sóc sức khỏe',
    'Công nghệ',
    'Vận chuyển',
    'Gia đình',
    'Khác'
  ];

  final List<String> locations = [
    'Tất cả',
    'Quận 1',
    'Quận 3',
    'Quận 5',
    'Quận 7',
    'Quận 10',
    'Quận Bình Thạnh'
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bộ lọc',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF003E77),
            ),
          ),
          const SizedBox(height: 16),

          // Category filter
          const Text(
            'Danh mục',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: selectedCategory,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: categories.map((category) {
              return DropdownMenuItem(
                value: category == 'Tất cả' ? null : category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedCategory = value;
              });
              widget.onCategoryChanged(value);
            },
          ),
          const SizedBox(height: 16),

          // Location filter
          const Text(
            'Địa điểm',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: selectedLocation,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: locations.map((location) {
              return DropdownMenuItem(
                value: location == 'Tất cả' ? null : location,
                child: Text(location),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedLocation = value;
              });
              widget.onLocationChanged(value);
            },
          ),
          const SizedBox(height: 16),

          // Time Credits filter
          const Text(
            'Số Time Credits',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          RangeSlider(
            values: timeCreditsRange ?? const RangeValues(0, 50),
            min: 0,
            max: 50,
            divisions: 10,
            labels: RangeLabels(
              '${(timeCreditsRange?.start ?? 0).round()}',
              '${(timeCreditsRange?.end ?? 50).round()}',
            ),
            onChanged: (values) {
              setState(() {
                timeCreditsRange = values;
              });
              widget.onTimeCreditsChanged(values);
            },
          ),
          Text(
            'Từ ${(timeCreditsRange?.start ?? 0).round()} đến ${(timeCreditsRange?.end ?? 50).round()} credits',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

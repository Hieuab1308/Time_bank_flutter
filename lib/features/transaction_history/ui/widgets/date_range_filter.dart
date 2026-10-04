import 'package:flutter/material.dart';

class DateRangeFilter extends StatelessWidget {
  const DateRangeFilter({super.key, required this.from, required this.to, this.onPickFrom, this.onPickTo});
  final DateTime from;
  final DateTime to;
  final VoidCallback? onPickFrom;
  final VoidCallback? onPickTo;

  String _fmt(DateTime d) => '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _DateBox(label: _fmt(from), icon: Icons.calendar_month, onTap: onPickFrom),
        const SizedBox(width: 12),
        _DateBox(label: _fmt(to), icon: Icons.calendar_month, onTap: onPickTo),
      ],
    );
  }
}

class _DateBox extends StatelessWidget {
  const _DateBox({required this.label, required this.icon, this.onTap});
  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE4E6EB)),
            boxShadow: const [
              BoxShadow(color: Color(0x14000000), blurRadius: 6, offset: Offset(0,2)),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0A3D66)),
                ),
              ),
              Icon(icon, size: 20, color: const Color(0xFF0A3D66)),
            ],
          ),
        ),
      ),
    );
  }
}

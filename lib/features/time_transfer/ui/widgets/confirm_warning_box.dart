import 'package:flutter/material.dart';

class ConfirmWarningBox extends StatelessWidget {
  const ConfirmWarningBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        border: Border.all(color: const Color(0xFFFFD54F)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.info_outline, color: Color(0xFFFFA000)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Vui lòng kiểm tra chính xác thông tin trước khi giao dịch',
              style: TextStyle(color: Colors.black87, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

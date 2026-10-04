import 'package:flutter/material.dart';

class MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onAttach; // <-- 1. THÊM DÒNG NÀY

  const MessageInput({
    Key? key,
    required this.controller,
    required this.onSend,
    required this.onAttach, // <-- 2. THÊM VÀO CONSTRUCTOR
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          IconButton(
            onPressed: onAttach, // <-- 3. SỬA DÒNG NÀY (thay vì () {})
            icon: const Icon(Icons.attachment, color: Color(0xFF9AA7B2)),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Color(0xFFDEE3EB), width: 1),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'Type something',
                  border: InputBorder.none,
                ),
                minLines: 1,
                maxLines: 6,
              ),
            ),
          ),
          IconButton(onPressed: onSend, icon: const Icon(Icons.send, color: Color(0xFF003E77))),
        ],
      ),
    );
  }
}
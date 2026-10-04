import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TimePickerDialogCustom extends StatefulWidget {
  const TimePickerDialogCustom({super.key});

  @override
  State<TimePickerDialogCustom> createState() => _TimePickerDialogCustomState();
}

class _TimePickerDialogCustomState extends State<TimePickerDialogCustom> {
  final colorPrimary = const Color(0xFF003E77);

  final TextEditingController _hourController = TextEditingController(text: '');
  final TextEditingController _minuteController = TextEditingController(text: '');
  final TextEditingController _secondController = TextEditingController(text: '');

  int _focusedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Nhập thời gian cần chuyển:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildInputBox(controller: _hourController, label: 'Giờ', maxValue: 23, index: 0),
                const Text(':', style: TextStyle(fontSize: 26, color: Colors.black54)),
                _buildInputBox(controller: _minuteController, label: 'Phút', maxValue: 59, index: 1),
                const Text(':', style: TextStyle(fontSize: 26, color: Colors.black54)),
                _buildInputBox(controller: _secondController, label: 'Giây', maxValue: 59, index: 2),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.access_time, color: colorPrimary),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        final hours = int.tryParse(_hourController.text) ?? 0;
                        final minutes = int.tryParse(_minuteController.text) ?? 0;
                        final seconds = int.tryParse(_secondController.text) ?? 0;
                        Navigator.pop(
                          context,
                          Duration(hours: hours, minutes: minutes, seconds: seconds),
                        );
                      },
                      child: Text(
                        'OK',
                        style: TextStyle(color: colorPrimary, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInputBox({
    required TextEditingController controller,
    required String label,
    required int maxValue,
    required int index,
  }) {
    final bool isFocused = _focusedIndex == index;

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _focusedIndex = index;
              controller.clear();
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 70,
            height: 70,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: isFocused ? const Color(0xFF003E77) : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isFocused
                    ? const Color(0xFF003E77)
                    : const Color(0xFF003E77).withAlpha((0.3 * 255).toInt()),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((0.1 * 255).toInt()),
                  blurRadius: isFocused ? 8 : 4,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: TextField(
              controller: controller,
              textAlign: TextAlign.center,
              cursorColor: Colors.white,
              style: TextStyle(
                color: isFocused ? Colors.white : const Color(0xFF003E77),
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(2),
              ],
              onTap: () => setState(() => _focusedIndex = index),
              onChanged: (value) {
                int num = int.tryParse(value) ?? 0;
                if (num > maxValue) {
                  num = maxValue;
                  controller.text = num.toString().padLeft(2, '0');
                  controller.selection = TextSelection.fromPosition(
                    TextPosition(offset: controller.text.length),
                  );
                }

                if (value.length == 2) {
                  if (index < 2) {
                    FocusScope.of(context).nextFocus();
                    setState(() => _focusedIndex = index + 1);
                  } else {
                    FocusScope.of(context).unfocus();
                    setState(() => _focusedIndex = -1);
                  }
                }
              },
              onEditingComplete: () {
                if (controller.text.isEmpty) {
                  controller.text = '00';
                }
              },
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
              color: Colors.black54, fontWeight: FontWeight.w500, fontSize: 13),
        ),
      ],
    );
  }
}

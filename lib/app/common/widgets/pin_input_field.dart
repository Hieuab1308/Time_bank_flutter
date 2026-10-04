import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PinInputField extends StatefulWidget {
  final TextEditingController controller;
  final int length;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscure;
  final bool showIndex; // show index (1..n) under each circle
  final bool showDigits; // show actual digit inside circle instead of solid dot
  final void Function(String)? onChanged;
  final FocusNode? focusNode;
  final void Function(String)? onCompleted;

  const PinInputField({
    Key? key,
    required this.controller,
    this.length = 6,
    this.inputFormatters,
    this.obscure = true,
    this.showIndex = false,
    this.showDigits = false,
    this.onChanged,
    this.focusNode,
    this.onCompleted,
  }) : super(key: key);

  @override
  State<PinInputField> createState() => _PinInputFieldState();
}

class _PinInputFieldState extends State<PinInputField> {
  late FocusNode _focusNode;
  bool _createdFocus = false;
  bool _completedCalled = false;
  late TextEditingController _controller;
  void _onFocusChanged() => setState(() {});

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _controller.addListener(_onTextChanged);
    // use external focusNode if provided, otherwise create one we dispose
    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
      _createdFocus = false;
    } else {
      _focusNode = FocusNode();
      _createdFocus = true;
    }
    _focusNode.addListener(_onFocusChanged);
  }

  void _onTextChanged() {
    setState(() {});
    widget.onChanged?.call(_controller.text);
    final len = _controller.text.length;
    if (len >= widget.length && !_completedCalled) {
      _completedCalled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onCompleted?.call(_controller.text);
      });
    }
    if (len < widget.length) {
      _completedCalled = false;
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    if (_createdFocus) _focusNode.dispose();
    super.dispose();
  }

  Widget _buildBox(int index, bool filled, bool active, String? digit) {
    final double size = 22;
    if (filled) {
      if (widget.showDigits && digit != null && digit.isNotEmpty) {
        return Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF003E77)),
          child: Text(digit, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
        );
      }

      return Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF003E77)),
      );
    }

    // Render active highlight when this box is the first empty and the field has focus.
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.transparent,
        border: Border.all(
            color: active ? const Color(0xFF003E77) : Colors.grey,
            width: active ? 2 : 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = _controller.text;
    final chars = text.split('');
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(_focusNode),
      child: Column(
          children: [
            SizedBox(
              height: widget.showIndex ? 56 : 40,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 40,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(widget.length, (i) {
                        final filled = i < chars.length;
                        // active when this is the first empty box AND this field has focus
                        final active = (i == chars.length) && _focusNode.hasFocus;
                        final digit = i < chars.length ? chars[i] : null;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0),
                          child: _buildBox(i, filled, active, digit),
                        );
                      }),
                    ),
                  ),
                  if (widget.showIndex) const SizedBox(height: 6),
                  if (widget.showIndex)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(widget.length, (i) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0),
                          child: Text('${i + 1}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                        );
                      }),
                    ),
                ],
              ),
            ),
          // invisible TextField to collect input
          // make the TextField tiny (1x1) so it can receive focus reliably
          SizedBox(
            height: 1,
            width: 1,
            child: Opacity(
              opacity: 0.0,
              child: TextField(
                focusNode: _focusNode,
                controller: _controller,
                keyboardType: TextInputType.number,
                inputFormatters: widget.inputFormatters,
                obscureText: widget.obscure,
                maxLength: widget.length,
                enableSuggestions: false,
                autocorrect: false,
                decoration: const InputDecoration(counterText: ''),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

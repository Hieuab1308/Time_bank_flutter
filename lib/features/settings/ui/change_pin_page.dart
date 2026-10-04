import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import 'package:time_bank_flutter/features/settings/data/api_settings_repository.dart';
import 'package:time_bank_flutter/app/common/widgets/pin_input_field.dart';

class ChangePinPage extends ConsumerStatefulWidget {
  const ChangePinPage({Key? key}) : super(key: key);

  static Future<void> open(BuildContext context) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChangePinPage()));
  }

  @override
  ConsumerState<ChangePinPage> createState() => _ChangePinPageState();
}

class _ChangePinPageState extends ConsumerState<ChangePinPage> {
  bool _loading = false;
  final TextEditingController _pinCurrentController = TextEditingController();
  final TextEditingController _pinNewController = TextEditingController();
  final TextEditingController _pinConfirmController = TextEditingController();
  final FocusNode _focusCurrent = FocusNode();
  final FocusNode _focusNew = FocusNode();
  final FocusNode _focusConfirm = FocusNode();
  String? _currentPinError;
  String? _confirmPinError;

  @override
  void initState() {
    super.initState();
    _pinCurrentController.addListener(_onControllersChanged);
    _pinNewController.addListener(_onControllersChanged);
    _pinConfirmController.addListener(_onControllersChanged);
    _pinCurrentController.addListener(() {
      if (_currentPinError != null) setState(() => _currentPinError = null);
    });
    _pinNewController.addListener(() {
      if (_confirmPinError != null) setState(() => _confirmPinError = null);
    });
    _pinConfirmController.addListener(() {
      if (_confirmPinError != null) setState(() => _confirmPinError = null);
    });
  }

  void _onControllersChanged() => setState(() {});

  @override
  void dispose() {
    _pinCurrentController.removeListener(_onControllersChanged);
    _pinNewController.removeListener(_onControllersChanged);
    _pinConfirmController.removeListener(_onControllersChanged);
    _pinCurrentController.dispose();
    _pinNewController.dispose();
    _pinConfirmController.dispose();
    _focusCurrent.dispose();
    _focusNew.dispose();
    _focusConfirm.dispose();
    super.dispose();
  }

  bool get _canSubmit {
    final n = _pinNewController.text.trim();
    final c = _pinConfirmController.text.trim();
    return n.length == 6 && c.length == 6 && !_loading;
  }

  Future<void> _onSubmit() async {
    final repo = ref.read(settingsRepoProvider);
    final current = _pinCurrentController.text.trim();
    final newPin = _pinNewController.text.trim();
    final confirm = _pinConfirmController.text.trim();
    if (newPin.length == 6 && confirm.length == 6 && newPin != confirm) {
      setState(() {
        _confirmPinError = 'Mã PIN xác nhận không khớp';
        _currentPinError = null;
      });
      _focusConfirm.requestFocus();
      return;
    }
    setState(() {
      _loading = true;
      _currentPinError = null;
    });
    try {
      await repo.changePin(currentPin: current.isEmpty ? null : current, newPin: newPin);
      if (!mounted) return;
      await _showSuccessDialog('Đổi mã PIN thành công');
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString();
      if (msg.contains('Thiếu current_pin') || msg.contains('current_pin') || msg.contains('PIN hiện tại')) {
        setState(() {
          _currentPinError = 'Mã PIN hiện tại không đúng';
        });
        _focusCurrent.requestFocus();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_extractMessage(msg))));
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  String _extractMessage(String raw) {
    final r = raw.replaceFirst('Exception: ', '').trim();
    return r.isEmpty ? 'Đã có lỗi xảy ra' : r;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D1B4C), Color(0xFF0F58A1)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Text('CẬP NHẬT', style: TextStyle(fontSize: 28, color: Colors.white)),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: CircleAvatar(radius: 28, backgroundColor: const Color(0xFF003E77).withOpacity(0.12), child: const Icon(Icons.vpn_key_outlined, color: Color(0xFF003E77))),
                      ),
                      const SizedBox(height: 16),
                      Center(child: Text('Đổi Mã PIN', style: Theme.of(context).textTheme.titleLarge)),
                      const SizedBox(height: 8),
                      const Text('Vui lòng nhập mã PIN hiện tại và mã PIN mới', style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 20),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                          alignment: Alignment.center,
                          child: const Text('Nhập mã PIN hiện tại', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: PinInputField(
                            controller: _pinCurrentController,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            length: 6,
                            showIndex: false,
                            focusNode: _focusCurrent,
                            onCompleted: (_) => _focusNew.requestFocus(),
                          ),
                        ),
                        const SizedBox(height: 6),
                        if (_currentPinError != null)
                          Center(
                            child: Text(
                              _currentPinError!,
                              style: const TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                      const SizedBox(height: 12),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                          alignment: Alignment.center,
                          child: const Text('Nhập mã PIN mới', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: PinInputField(
                            controller: _pinNewController,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            length: 6,
                            showIndex: false,
                            focusNode: _focusNew,
                            onCompleted: (_) => _focusConfirm.requestFocus(),
                          ),
                        ),
                      const SizedBox(height: 12),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                          alignment: Alignment.center,
                          child: const Text('Nhập lại mã PIN mới', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: PinInputField(
                            controller: _pinConfirmController,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            length: 6,
                            showIndex: false,
                            focusNode: _focusConfirm,
                            onCompleted: (_) => _focusConfirm.unfocus(),
                          ),
                        ),
                        const SizedBox(height: 6),
                        if (_confirmPinError != null)
                          Center(
                            child: Text(
                              _confirmPinError!,
                              style: const TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),

                      const SizedBox(height: 18),
                      Row(children: [
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(backgroundColor: Colors.white, side: const BorderSide(color: Color(0xFF003E77))),
                              child: const Text('Hủy', style: TextStyle(color: Color(0xFF003E77))),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            height: 48,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: const LinearGradient(colors: [Color(0xFF0D1B4C), Color(0xFF0F58A1)])),
                            child: ElevatedButton(
                              onPressed: _canSubmit ? _onSubmit : null,
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
                              child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Xác nhận', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ),
                      ])
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showSuccessDialog(String message) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Future.delayed(const Duration(milliseconds: 800), () {
            if (Navigator.of(ctx).canPop()) Navigator.of(ctx).pop();
          });
        });

        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 64),
              const SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
            ],
          ),
        );
      },
    );
  }
}

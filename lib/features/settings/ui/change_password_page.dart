import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/ui/page_transitions.dart';
import '../providers/providers.dart';

class ChangePasswordPage extends ConsumerStatefulWidget {
  const ChangePasswordPage({Key? key}) : super(key: key);

  static Future<void> open(BuildContext context) {
    return Navigator.of(context).push(slideFromBottomRoute(const ChangePasswordPage()));
  }

  String _extractMessage(String raw) {
    final r = raw.replaceFirst('Exception: ', '').trim();
    return r.isEmpty ? 'Đã có lỗi xảy ra' : r;
  }

  @override
  ConsumerState<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _oldController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  final FocusNode _focusOld = FocusNode();
  final FocusNode _focusNew = FocusNode();
  final FocusNode _focusConfirm = FocusNode();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  String? _currentPasswordError;

  String? _passwordValidator(String? v) {
    if (v == null || v.isEmpty) return 'Vui lòng nhập mật khẩu';
    if (v.length < 8) return 'Mật khẩu phải có ít nhất 8 ký tự';
    final hasUpper = RegExp(r'[A-Z]').hasMatch(v);
    final hasSpecial = RegExp(r'[^A-Za-z0-9]').hasMatch(v);
    final hasDigit = RegExp(r'[0-9]').hasMatch(v);
    if (!hasUpper) return 'Mật khẩu phải chứa ít nhất 1 chữ hoa';
    if (!hasSpecial) return 'Mật khẩu phải chứa ít nhất 1 ký tự đặc biệt';
    if (!hasDigit) return 'Mật khẩu phải chứa ít nhất 1 chữ số';
    return null;
  }

  @override
  void dispose() {
    _oldController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    _focusOld.dispose();
    _focusNew.dispose();
    _focusConfirm.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _focusOld.addListener(() => setState(() {}));
    _focusNew.addListener(() => setState(() {}));
    _focusConfirm.addListener(() => setState(() {}));
    _oldController.addListener(() {
      if (_currentPasswordError != null) setState(() => _currentPasswordError = null);
    });
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: CircleAvatar(radius: 28, backgroundColor: const Color(0xFF003E77).withOpacity(0.12), child: const Icon(Icons.lock_outline, color: Color(0xFF003E77))),
                        ),
                        const SizedBox(height: 16),
                        Text('Đổi Mật Khẩu', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 8),
                        const Text('Vui lòng nhập mật khẩu hiện tại và mật khẩu mới', style: TextStyle(color: Colors.grey)),
                        const SizedBox(height: 20),

                        // old password
                          TextFormField(
                          controller: _oldController,
                          focusNode: _focusOld,
                          cursorColor: const Color(0xFF003E77),
                          selectionControls: null,
                          obscureText: _obscureOld,
                          decoration: InputDecoration(
                            labelText: 'Mật khẩu hiện tại',
                            hintText: 'Nhập mật khẩu hiện tại',
                            suffixIcon: IconButton(icon: Icon(_obscureOld ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscureOld = !_obscureOld)),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF003E77), width: 2.0)),
                            labelStyle: TextStyle(color: Colors.grey[700]),
                            floatingLabelStyle: const TextStyle(color: Color(0xFF003E77)),
                          ),
                          validator: (v) => (v == null || v.isEmpty) ? 'Vui lòng điền mật khẩu hiện tại' : null,
                        ),
                        const SizedBox(height: 6),
                        if (_currentPasswordError != null)
                          Text(_currentPasswordError!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: _newController,
                          focusNode: _focusNew,
                          cursorColor: const Color(0xFF003E77),
                          selectionControls: null,
                          obscureText: _obscureNew,
                          decoration: InputDecoration(
                            labelText: 'Mật khẩu mới',
                            hintText: 'Nhập mật khẩu mới',
                            suffixIcon: IconButton(icon: Icon(_obscureNew ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscureNew = !_obscureNew)),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF003E77), width: 2.0)),
                            labelStyle: TextStyle(color: Colors.grey[700]),
                            floatingLabelStyle: const TextStyle(color: Color(0xFF003E77)),
                          ),
                          validator: _passwordValidator,
                        ),
                        const SizedBox(height: 12),

                        // confirm
                        TextFormField(
                          controller: _confirmController,
                          focusNode: _focusConfirm,
                          cursorColor: const Color(0xFF003E77),
                          selectionControls: null,
                          obscureText: _obscureConfirm,
                          decoration: InputDecoration(
                            labelText: 'Xác nhận mật khẩu mới',
                            hintText: 'Nhập lại mật khẩu mới',
                            suffixIcon: IconButton(icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm)),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF003E77), width: 2.0)),
                            labelStyle: TextStyle(color: Colors.grey[700]),
                            floatingLabelStyle: const TextStyle(color: Color(0xFF003E77)),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Vui lòng xác nhận mật khẩu';
                            if (v != _newController.text) return 'Mật khẩu xác nhận không khớp';
                            return null;
                          },
                        ),

                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                          child: Row(children: const [Icon(Icons.info_outline, color: Colors.black54), SizedBox(width: 8), Expanded(child: Text('Mật khẩu phải có ít nhất 8 ký tự, chứa 1 chữ hoa và 1 ký tự đặc biệt.'))]),
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
                                onPressed: () async {
                                  if (!_formKey.currentState!.validate()) return;
                                  setState(() => _loading = true);
                                  final repo = ref.read(settingsRepoProvider);
                                    try {
                                      await repo.changePassword(currentPassword: _oldController.text, newPassword: _newController.text);
                                      await _showSuccessDialog('Đổi mật khẩu thành công');
                                      Navigator.of(context).pop();
                                    } catch (e) {
                                      final msg = e.toString();
                                      if (msg.contains('current_password') || msg.contains('Mật khẩu hiện tại') || msg.contains('Thiếu current_password')) {
                                        setState(() {
                                          _currentPasswordError = 'Mật khẩu hiện tại không đúng';
                                        });
                                        _focusOld.requestFocus();
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi đổi mật khẩu: ${widget._extractMessage(msg)}')));
                                      }
                                    } finally {
                                      setState(() => _loading = false);
                                    }
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
                                child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Xác nhận', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ),
                        ])
                      ],
                    ),
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

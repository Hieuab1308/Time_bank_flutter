class Validators {
  static String? phoneVN(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Vui lòng nhập số điện thoại';
    // VN: 10 digits, bắt đầu 0 (đơn giản). Tuỳ quy tắc dự án.
    final reg = RegExp(r'^0\d{9}$');
    if (!reg.hasMatch(s)) return 'Số điện thoại không hợp lệ';
    return null;
  }

  static String? password(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Vui lòng nhập mật khẩu';
    if (s.length < 8) return 'Mật khẩu tối thiểu 8 ký tự';
    return null;
  }
}

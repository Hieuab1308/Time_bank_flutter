class OnboardingValidators {
  static String? notEmpty(String? v, {String label = 'Trường này'}) {
    if (v == null || v.trim().isEmpty) return '$label không được để trống';
    return null;
  }

  static String? phone(String? v) {
    if (v == null || v.trim().isEmpty) return 'SĐT không được để trống';
    final ok = RegExp(r'^(0|\+84)\d{9}$').hasMatch(v.trim());
    return ok ? null : 'SĐT không hợp lệ';
  }

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email không được để trống';
    final ok = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v.trim());
    return ok ? null : 'Email không hợp lệ';
  }

  static String? password(String? v) {
    if (v == null || v.length < 8) return 'Mật khẩu tối thiểu 8 ký tự';
    return null;
  }

  static String? pin(String? v) {
    if (v == null) return 'PIN không được để trống';
    final ok = RegExp(r'^\d{4,6}$').hasMatch(v);
    return ok ? null : 'PIN phải 4–6 chữ số';
  }
}

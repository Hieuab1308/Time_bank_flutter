String toE164VN(String input) {
  final digits = input.replaceAll(RegExp(r'\D'), '');
  if (digits.startsWith('0') && (digits.length == 10 || digits.length == 11)) {
    return '+84${digits.substring(1)}';
  }

  if (RegExp(r'^\+\d{8,15}$').hasMatch(input)) return input;
  throw ArgumentError('Số điện thoại không đúng định dạng VN (09...) hoặc E.164');
}

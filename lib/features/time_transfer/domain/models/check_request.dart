class CheckRequest {
  final String toPhone;
  final int secs;

  CheckRequest({required this.toPhone, required this.secs});

  Map<String, dynamic> toMap() => {
    'to_phone': toPhone,
    'secs': secs,
  };
}
class CreateTransferRequest {
  final String toPhone;
  final int secs;
  final String? note;
  final String pin;

  CreateTransferRequest({
    required this.toPhone,
    required this.secs,
    this.note,
    required this.pin,
  });

  Map<String, dynamic> toMap() => {
    'to_phone': toPhone,
    'secs': secs,
    if (note != null) 'note': note,
    'pin': pin,
  };
}
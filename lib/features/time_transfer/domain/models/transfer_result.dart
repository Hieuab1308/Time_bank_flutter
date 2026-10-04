class TransferResult {
  final String id;
  final String status;
  final int secs;
  final String? note;
  final DateTime createdAt;
  final DateTime? completedAt;

  TransferResult({
    required this.id,
    required this.status,
    required this.secs,
    this.note,
    required this.createdAt,
    this.completedAt,
  });

  factory TransferResult.fromJson(Map<String, dynamic> json) {
    return TransferResult(
      id: json['id'],
      status: json['status'],
      secs: json['secs'],
      note: json['note'],
      createdAt: DateTime.parse(json['created_at']),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
    );
  }
}
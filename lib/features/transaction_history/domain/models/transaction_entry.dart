import 'package:equatable/equatable.dart';


class TransactionEntry extends Equatable {
  const TransactionEntry({
    required this.id,
    required this.direction,
    this.status,
    required this.deltaSecs,
    this.balanceAfterSecs,
    required this.occurredAt,
    this.senderName,
    this.senderAccount,
    this.receiverName,
    this.receiverAccount,
    this.note,
  });

  final String id;
  final TransactionDirection direction;
  final TransferStatus? status;
  final int deltaSecs;
  final int? balanceAfterSecs;
  final DateTime occurredAt;
  final String? senderName;
  final String? senderAccount;
  final String? receiverName;
  final String? receiverAccount;
  final String? note;

  bool get isOut => direction == TransactionDirection.out;
  bool get isIn => direction == TransactionDirection.incoming;
  bool get isCompleted => status == TransferStatus.completed;

  String get formattedDelta => _formatSignedHms(deltaSecs);
  String? get formattedBalanceAfter => balanceAfterSecs == null ? null : _formatUnsignedHms(balanceAfterSecs!.abs());
  String get formattedTime => '${_pad2(occurredAt.hour)}:${_pad2(occurredAt.minute)}:${_pad2(occurredAt.second)}';
  String get formattedDate => '${_pad2(occurredAt.day)}/${_pad2(occurredAt.month)}/${occurredAt.year}';

  static String _pad2(int v) => v.toString().padLeft(2, '0');
  static String _formatSignedHms(int secs) {
    final sign = secs < 0 ? '-' : '+';
    return sign + _formatUnsignedHms(secs.abs());
  }
  static String _formatUnsignedHms(int secs) {
    final h = secs ~/ 3600;
    final m = (secs % 3600) ~/ 60;
    final s = secs % 60;
    return [h, m, s].map(_pad2).join(':');
  }

  @override
  List<Object?> get props => [id, direction, status, deltaSecs, balanceAfterSecs, occurredAt];
}

enum TransactionDirection { out, incoming }
enum TransferStatus { pending, completed, cancelled, failed }
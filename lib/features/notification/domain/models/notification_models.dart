import 'package:intl/intl.dart';

enum NotificationType {
  transferOut,
  transferIn,
  systemAlert,
  offerReceived,
  offerAccepted,
  offerRejected,
}

NotificationType _mapType(String s) {
  switch (s) {
    case 'TRANSFER_OUT':
      return NotificationType.transferOut;
    case 'TRANSFER_IN':
      return NotificationType.transferIn;
    default:
      return NotificationType.systemAlert;
  }
}

class AppNotification {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime createdAt;
  final bool read;
  final Map<String, dynamic> data;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    required this.read,
    required this.data,
  });

  factory AppNotification.fromJson(Map<String, dynamic> j) {
    final d = (j['data'] as Map?)?.map((k, v) => MapEntry('$k', v)) ?? <String, dynamic>{};
    return AppNotification(
      id: j['id'] as String,
      title: j['title'] as String,
      body: j['body'] as String,
      type: _mapType(j['type'] as String),
      createdAt: DateTime.parse(j['created_at'] as String).toLocal(),
      read: (j['read'] as bool?) ?? false,
      data: d,
    );
  }


  String get message => body;

  static final _dateFormatter = DateFormat('dd/MM/yyyy');
  String get dateText {
    return _dateFormatter.format(createdAt);
  }

  static final _timeFormatter = DateFormat('HH:mm');
  String get timeText {
    return _timeFormatter.format(createdAt);
  }


  String? get note => data['memo'] as String?;

  String get change {
    final String sign = (type == NotificationType.transferIn) ? '+' : '-';
    final String amount = data['amountHms'] as String? ?? '0:00:00';
    return '$sign $amount';
  }

  String get account => data['accountPhone'] as String? ?? '';
  String get balance => data['postBalanceHms'] as String? ?? '';

  static final _dataDateTimeFormatter = DateFormat('d-M-yyyy HH:mm:ss');
  String get dataDateTime {
    final createdAtString = data['createdAt'] as String?;
    if (createdAtString == null) return '';
    try {
      final utcTime = DateTime.parse(createdAtString);
      final localTime = utcTime.toLocal();
      return _dataDateTimeFormatter.format(localTime);
    } catch (e) {
      return '';
    }
  }


  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    DateTime? createdAt,
    bool? read,
    Map<String, dynamic>? data,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      read: read ?? this.read,
      data: data ?? this.data,
    );
  }
}
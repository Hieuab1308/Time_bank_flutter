// import 'dart:math';
// import '../../notification/domain/models/notification_models.dart';
// import 'notification_repository.dart';
//
// class MockNotificationRepository implements NotificationRepository {
//   final _rng = Random();
//
//   @override
//   Future<List<AppNotification>> fetch(AppNotificationType type) async {
//     await Future.delayed(const Duration(milliseconds: 250));
//
//     if (type == AppNotificationType.activity) {
//       return List.generate(5, (i) {
//         final now = DateTime.now().subtract(Duration(minutes: _rng.nextInt(6000)));
//         final sign = _rng.nextBool() ? '+' : '-';
//         final hh = _rng.nextInt(2).toString().padLeft(2, '0');
//         final mm = _rng.nextInt(59).toString().padLeft(2, '0');
//         return AppNotification(
//           id: 'act_$i',
//           type: AppNotificationType.activity,
//           title: 'Biến động số dư thời gian',
//           message: 'Giao dịch #${i + 1}',
//           createdAt: now,
//           account: 'TK 00787xxx6${_rng.nextInt(9)}7',
//           change: '$sign${hh}H:${mm}M',
//           balance: '${_rng.nextInt(59)}M',
//           note: 'Ghi chú giao dịch #${i + 1}',
//           timeText: '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
//           dateText: '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}',
//         );
//       });
//     } else {
//       return List.generate(4, (i) {
//         final now = DateTime.now().subtract(Duration(minutes: _rng.nextInt(6000)));
//         return AppNotification(
//           id: 'gen_$i',
//           type: AppNotificationType.general,
//           title: 'Thông báo chung',
//           message: 'Nội dung thông báo mẫu #${i + 1}.',
//           createdAt: now,
//           timeText: '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
//           dateText: '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}',
//         );
//       });
//     }
//   }
// }

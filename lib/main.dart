import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'app/app.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

// Kênh thông báo cho Android 8.0+
final AndroidNotificationChannel channel = AndroidNotificationChannel(
  'time_bank_transfers',
  'Giao dịch Time Bank',
  description: 'Thông báo về biến động số dư.',
  importance: Importance.max,
);

// ===== (Hàm background handler ) =====
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
  // Khi app ở nền, Firebase tự hiển thị, không cần làm gì thêm
}


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseDatabase.instance.databaseURL = 'https://timebanking-7e3b5-default-rtdb.asia-southeast1.firebasedatabase.app/';

  // ===== 3. KHỞI TẠO FLUTTER LOCAL NOTIFICATIONS =====
  // Dùng icon app mặc định
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );


  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {
      print('Local notification tapped: ${notificationResponse.payload}');
    },
  );

  // Tạo Kênh thông báo (channel) trên Android
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);


  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: false,
    badge: false,
    sound: false,
  );

  runApp(const ProviderScope(child: App()));
}
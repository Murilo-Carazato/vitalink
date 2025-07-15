import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class LocalNotificationHelper {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description: 'This channel is used for important notifications.', // description
    importance: Importance.max,
  );

  static Future<void> initialize() async {
    // Initialization settings for Android
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: AndroidInitializationSettings("@mipmap/ic_launcher"),
      iOS: DarwinInitializationSettings(),
    );

    await _notificationsPlugin.initialize(initializationSettings);

    // Create the notification channel on initialization
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  static void showNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;

    // Tenta obter o título e o corpo do payload da notificação primeiro.
    String? title = notification?.title;
    String? body = notification?.body;

    // Se estiverem nulos, tenta obtê-los do payload de dados.
    if (title == null || body == null) {
      title = message.data['title'] ?? message.data['gcm.notification.title'];
      body = message.data['body'] ?? message.data['gcm.notification.body'];
    }

    // Mostra a notificação apenas se tivermos um título e um corpo.
    if (title != null && body != null) {
      _notificationsPlugin.show(
        message.hashCode,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            icon: '@mipmap/ic_launcher', // Ícone padrão
          ),
        ),
      );
    }
  }
} 
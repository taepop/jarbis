import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';
import '../models/alarm_model.dart';

class NotificationService {
  static const String _channelId = 'jarvis_alarm_channel';
  static const String _channelName = 'J.A.R.V.I.S Alarm';
  static const String _channelDescription = 'Iron Man style alarm notifications';

  static Future<void> initialize(
    FlutterLocalNotificationsPlugin plugin,
  ) async {
    // Android initialization settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
      onDidReceiveBackgroundNotificationResponse: _onBackgroundNotification,
    );

    // Create notification channel
    await _createNotificationChannel(plugin);
  }

  static Future<void> _createNotificationChannel(
    FlutterLocalNotificationsPlugin plugin,
  ) async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.max,
      playSound: false, // We handle audio separately
      enableVibration: true,
      enableLights: true,
      ledColor: Color(0xFF00D4FF),
    );

    await plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  static void _onNotificationTap(NotificationResponse response) {
    // Navigate to alarm ring screen
    navigatorKey.currentState?.pushNamed('/alarm-ring', arguments: response.payload);
  }

  @pragma('vm:entry-point')
  static void _onBackgroundNotification(NotificationResponse response) {
    // Handle background notification tap
  }

  static Future<void> showAlarmNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.max,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      visibility: NotificationVisibility.public,
      playSound: false,
      enableVibration: true,
      ongoing: true,
      autoCancel: false,
      actions: [
        AndroidNotificationAction(
          'dismiss',
          'DISMISS',
          showsUserInterface: true,
          cancelNotification: true,
        ),
        AndroidNotificationAction(
          'snooze',
          'SNOOZE',
          showsUserInterface: true,
        ),
      ],
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  static Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  static Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}

// Color class for ledColor (simplified)
class Color {
  final int value;
  const Color(this.value);
}

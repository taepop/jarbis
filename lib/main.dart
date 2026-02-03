import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/jarvis_theme.dart';
import 'core/services/notification_service.dart';
import 'core/services/alarm_service.dart';
import 'features/home/home_screen.dart';
import 'features/alarm_ring/alarm_ring_screen.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Global navigator key for navigation from notifications
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style for immersive experience
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: JarvisColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize services
  await NotificationService.initialize(flutterLocalNotificationsPlugin);
  
  // Initialize timezone for iOS alarm scheduling
  await AlarmService.initializeTimezone();
  
  // Initialize Android Alarm Manager (Android only)
  if (Platform.isAndroid) {
    await AndroidAlarmManager.initialize();
  }

  runApp(const JarvisAlarmApp());
}

class JarvisAlarmApp extends StatelessWidget {
  const JarvisAlarmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'J.A.R.V.I.S Alarm',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: JarvisTheme.darkTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/alarm-ring': (context) => const AlarmRingScreen(),
      },
    );
  }
}

import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/alarm_model.dart';
import 'notification_service.dart';

class AlarmService {
  static const String _alarmsKey = 'jarvis_alarms';
  static const String _portName = 'alarm_port';

  // Save alarm to storage
  static Future<void> saveAlarm(AlarmModel alarm) async {
    final prefs = await SharedPreferences.getInstance();
    final alarms = await getAlarms();
    
    // Remove existing alarm with same ID
    alarms.removeWhere((a) => a.id == alarm.id);
    alarms.add(alarm);
    
    final alarmsJson = alarms.map((a) => a.toJson()).toList();
    await prefs.setString(_alarmsKey, jsonEncode(alarmsJson));
    
    // Schedule the alarm if enabled
    if (alarm.isEnabled) {
      await scheduleAlarm(alarm);
    }
  }

  // Get all alarms
  static Future<List<AlarmModel>> getAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final alarmsString = prefs.getString(_alarmsKey);
    
    if (alarmsString == null) return [];
    
    final List<dynamic> alarmsJson = jsonDecode(alarmsString);
    return alarmsJson.map((json) => AlarmModel.fromJson(json)).toList();
  }

  // Delete alarm
  static Future<void> deleteAlarm(int alarmId) async {
    final prefs = await SharedPreferences.getInstance();
    final alarms = await getAlarms();
    
    alarms.removeWhere((a) => a.id == alarmId);
    
    final alarmsJson = alarms.map((a) => a.toJson()).toList();
    await prefs.setString(_alarmsKey, jsonEncode(alarmsJson));
    
    await cancelAlarm(alarmId);
  }

  // Toggle alarm on/off
  static Future<void> toggleAlarm(int alarmId, bool isEnabled) async {
    final alarms = await getAlarms();
    final index = alarms.indexWhere((a) => a.id == alarmId);
    
    if (index != -1) {
      final alarm = alarms[index].copyWith(isEnabled: isEnabled);
      await saveAlarm(alarm);
      
      if (isEnabled) {
        await scheduleAlarm(alarm);
      } else {
        await cancelAlarm(alarmId);
      }
    }
  }

  // Schedule alarm using Android Alarm Manager
  static Future<void> scheduleAlarm(AlarmModel alarm) async {
    final now = DateTime.now();
    var scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      alarm.hour,
      alarm.minute,
    );

    // If the time has passed today, schedule for tomorrow
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    // Handle repeating days
    if (alarm.repeatDays.isNotEmpty) {
      // Find next occurrence
      while (!alarm.repeatDays.contains(scheduledTime.weekday)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }
    }

    // Save alarm data for callback
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pending_alarm_${alarm.id}', jsonEncode(alarm.toJson()));

    await AndroidAlarmManager.oneShotAt(
      scheduledTime,
      alarm.id,
      alarmCallback,
      exact: true,
      wakeup: true,
      alarmClock: true,
      rescheduleOnReboot: true,
    );
  }

  // Cancel scheduled alarm
  static Future<void> cancelAlarm(int alarmId) async {
    await AndroidAlarmManager.cancel(alarmId);
    await NotificationService.cancelNotification(alarmId);
  }

  // Snooze alarm
  static Future<void> snoozeAlarm(AlarmModel alarm, {int minutes = 5}) async {
    final snoozeTime = DateTime.now().add(Duration(minutes: minutes));
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pending_alarm_${alarm.id}', jsonEncode(alarm.toJson()));

    await AndroidAlarmManager.oneShotAt(
      snoozeTime,
      alarm.id,
      alarmCallback,
      exact: true,
      wakeup: true,
      alarmClock: true,
    );
  }

  // Re-schedule repeating alarm for next occurrence
  static Future<void> rescheduleRepeatingAlarm(AlarmModel alarm) async {
    if (alarm.repeatDays.isEmpty) {
      // One-time alarm, disable it
      await toggleAlarm(alarm.id, false);
    } else {
      // Find next occurrence
      final now = DateTime.now();
      var nextOccurrence = DateTime(
        now.year,
        now.month,
        now.day,
        alarm.hour,
        alarm.minute,
      ).add(const Duration(days: 1));

      while (!alarm.repeatDays.contains(nextOccurrence.weekday)) {
        nextOccurrence = nextOccurrence.add(const Duration(days: 1));
      }

      await scheduleAlarm(alarm);
    }
  }
}

// Top-level callback function for alarm
@pragma('vm:entry-point')
Future<void> alarmCallback(int alarmId) async {
  // Get alarm data
  final prefs = await SharedPreferences.getInstance();
  final alarmJson = prefs.getString('pending_alarm_$alarmId');
  
  if (alarmJson != null) {
    final alarm = AlarmModel.fromJson(jsonDecode(alarmJson));
    
    // Show notification
    await NotificationService.showAlarmNotification(
      id: alarmId,
      title: 'J.A.R.V.I.S ALARM',
      body: alarm.label.isNotEmpty ? alarm.label : 'Good morning, Sir. Time to wake up.',
      payload: alarmJson,
    );

    // Send message to main isolate to open alarm screen
    final SendPort? sendPort = IsolateNameServer.lookupPortByName('alarm_port');
    sendPort?.send(alarmJson);
  }
}

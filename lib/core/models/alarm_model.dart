import 'dart:convert';

class AlarmModel {
  final int id;
  final int hour;
  final int minute;
  final String label;
  final bool isEnabled;
  final List<int> repeatDays; // 1 = Monday, 7 = Sunday
  final String? soundPath; // Path to user's audio file
  final bool weatherBriefing;
  final bool newsBriefing;
  final double volume;
  final int snoozeMinutes;

  AlarmModel({
    required this.id,
    required this.hour,
    required this.minute,
    this.label = '',
    this.isEnabled = true,
    this.repeatDays = const [],
    this.soundPath,
    this.weatherBriefing = true,
    this.newsBriefing = true,
    this.volume = 0.8,
    this.snoozeMinutes = 5,
  });

  String get formattedTime {
    final hourStr = hour.toString().padLeft(2, '0');
    final minuteStr = minute.toString().padLeft(2, '0');
    return '$hourStr:$minuteStr';
  }

  String get period {
    return hour >= 12 ? 'PM' : 'AM';
  }

  String get formattedTime12Hour {
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final minuteStr = minute.toString().padLeft(2, '0');
    return '$displayHour:$minuteStr';
  }

  String get repeatDaysString {
    if (repeatDays.isEmpty) return 'Once';
    if (repeatDays.length == 7) return 'Every day';
    if (repeatDays.length == 5 && 
        !repeatDays.contains(6) && 
        !repeatDays.contains(7)) {
      return 'Weekdays';
    }
    if (repeatDays.length == 2 && 
        repeatDays.contains(6) && 
        repeatDays.contains(7)) {
      return 'Weekends';
    }
    
    const dayNames = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final sortedDays = List<int>.from(repeatDays)..sort();
    return sortedDays.map((d) => dayNames[d]).join(', ');
  }

  DateTime get nextOccurrence {
    final now = DateTime.now();
    var scheduled = DateTime(now.year, now.month, now.day, hour, minute);

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    if (repeatDays.isNotEmpty) {
      while (!repeatDays.contains(scheduled.weekday)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }
    }

    return scheduled;
  }

  String get timeUntilAlarm {
    final diff = nextOccurrence.difference(DateTime.now());
    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  AlarmModel copyWith({
    int? id,
    int? hour,
    int? minute,
    String? label,
    bool? isEnabled,
    List<int>? repeatDays,
    String? soundPath,
    bool? weatherBriefing,
    bool? newsBriefing,
    double? volume,
    int? snoozeMinutes,
  }) {
    return AlarmModel(
      id: id ?? this.id,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      label: label ?? this.label,
      isEnabled: isEnabled ?? this.isEnabled,
      repeatDays: repeatDays ?? this.repeatDays,
      soundPath: soundPath ?? this.soundPath,
      weatherBriefing: weatherBriefing ?? this.weatherBriefing,
      newsBriefing: newsBriefing ?? this.newsBriefing,
      volume: volume ?? this.volume,
      snoozeMinutes: snoozeMinutes ?? this.snoozeMinutes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hour': hour,
      'minute': minute,
      'label': label,
      'isEnabled': isEnabled,
      'repeatDays': repeatDays,
      'soundPath': soundPath,
      'weatherBriefing': weatherBriefing,
      'newsBriefing': newsBriefing,
      'volume': volume,
      'snoozeMinutes': snoozeMinutes,
    };
  }

  factory AlarmModel.fromJson(Map<String, dynamic> json) {
    return AlarmModel(
      id: json['id'] as int,
      hour: json['hour'] as int,
      minute: json['minute'] as int,
      label: json['label'] as String? ?? '',
      isEnabled: json['isEnabled'] as bool? ?? true,
      repeatDays: (json['repeatDays'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
      soundPath: json['soundPath'] as String?,
      weatherBriefing: json['weatherBriefing'] as bool? ?? true,
      newsBriefing: json['newsBriefing'] as bool? ?? true,
      volume: (json['volume'] as num?)?.toDouble() ?? 0.8,
      snoozeMinutes: json['snoozeMinutes'] as int? ?? 5,
    );
  }

  @override
  String toString() {
    return 'AlarmModel(id: $id, time: $formattedTime, label: $label, enabled: $isEnabled)';
  }
}

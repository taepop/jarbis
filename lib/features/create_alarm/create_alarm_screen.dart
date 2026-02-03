import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/jarvis_theme.dart';
import '../../core/models/alarm_model.dart';
import '../../core/services/alarm_service.dart';
import '../../core/services/audio_service.dart';
import '../../core/widgets/jarvis_widgets.dart';

class CreateAlarmScreen extends StatefulWidget {
  final AlarmModel? alarm;

  const CreateAlarmScreen({super.key, this.alarm});

  @override
  State<CreateAlarmScreen> createState() => _CreateAlarmScreenState();
}

class _CreateAlarmScreenState extends State<CreateAlarmScreen> {
  late int _selectedHour;
  late int _selectedMinute;
  late String _label;
  late List<int> _repeatDays;
  late bool _weatherBriefing;
  late bool _newsBriefing;
  late String? _soundPath;
  late double _volume;
  late int _snoozeMinutes;

  final TextEditingController _labelController = TextEditingController();
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.alarm != null;
    
    if (widget.alarm != null) {
      _selectedHour = widget.alarm!.hour;
      _selectedMinute = widget.alarm!.minute;
      _label = widget.alarm!.label;
      _repeatDays = List.from(widget.alarm!.repeatDays);
      _weatherBriefing = widget.alarm!.weatherBriefing;
      _newsBriefing = widget.alarm!.newsBriefing;
      _soundPath = widget.alarm!.soundPath;
      _volume = widget.alarm!.volume;
      _snoozeMinutes = widget.alarm!.snoozeMinutes;
    } else {
      final now = DateTime.now();
      _selectedHour = (now.hour + 1) % 24;
      _selectedMinute = 0;
      _label = '';
      _repeatDays = [];
      _weatherBriefing = true;
      _newsBriefing = true;
      _soundPath = null;
      _volume = 0.8;
      _snoozeMinutes = 5;
    }
    
    _labelController.text = _label;
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: JarvisColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close, color: JarvisColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditing ? 'EDIT ALARM' : 'CREATE ALARM',
          style: JarvisTextStyles.headlineMedium,
        ),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete, color: JarvisColors.error),
              onPressed: _deleteAlarm,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTimePicker(),
            const SizedBox(height: 24),
            _buildLabelInput(),
            const SizedBox(height: 24),
            _buildRepeatDays(),
            const SizedBox(height: 24),
            _buildSoundPicker(),
            const SizedBox(height: 24),
            _buildBriefingOptions(),
            const SizedBox(height: 24),
            _buildVolumeSlider(),
            const SizedBox(height: 24),
            _buildSnoozeOptions(),
            const SizedBox(height: 32),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker() {
    return JarvisCard(
      child: Column(
        children: [
          Text(
            'SET TIME',
            style: JarvisTextStyles.labelLarge,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTimeWheel(
                value: _selectedHour,
                maxValue: 23,
                onChanged: (value) => setState(() => _selectedHour = value),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  ':',
                  style: JarvisTextStyles.displayLarge.copyWith(
                    color: JarvisColors.primary,
                  ),
                ),
              ),
              _buildTimeWheel(
                value: _selectedMinute,
                maxValue: 59,
                onChanged: (value) => setState(() => _selectedMinute = value),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _getAlarmTimeDescription(),
            style: JarvisTextStyles.bodyMedium.copyWith(
              color: JarvisColors.textSecondary,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1);
  }

  Widget _buildTimeWheel({
    required int value,
    required int maxValue,
    required ValueChanged<int> onChanged,
  }) {
    return Container(
      width: 100,
      height: 150,
      decoration: BoxDecoration(
        border: Border.all(color: JarvisColors.primary.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListWheelScrollView.useDelegate(
        controller: FixedExtentScrollController(initialItem: value),
        itemExtent: 50,
        perspective: 0.005,
        diameterRatio: 1.2,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: onChanged,
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: maxValue + 1,
          builder: (context, index) {
            final isSelected = index == value;
            return Center(
              child: Text(
                index.toString().padLeft(2, '0'),
                style: JarvisTextStyles.displayMedium.copyWith(
                  color: isSelected ? JarvisColors.primary : JarvisColors.textMuted,
                  fontSize: isSelected ? 32 : 24,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _getAlarmTimeDescription() {
    final now = DateTime.now();
    var alarmTime = DateTime(now.year, now.month, now.day, _selectedHour, _selectedMinute);
    
    if (alarmTime.isBefore(now)) {
      alarmTime = alarmTime.add(const Duration(days: 1));
    }
    
    final diff = alarmTime.difference(now);
    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;
    
    if (hours > 0) {
      return 'Alarm in ${hours}h ${minutes}m';
    }
    return 'Alarm in ${minutes}m';
  }

  Widget _buildLabelInput() {
    return JarvisCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('LABEL', style: JarvisTextStyles.labelLarge),
          const SizedBox(height: 12),
          TextField(
            controller: _labelController,
            style: JarvisTextStyles.bodyLarge.copyWith(color: JarvisColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'e.g., Wake up, Meeting...',
              hintStyle: JarvisTextStyles.bodyLarge.copyWith(color: JarvisColors.textMuted),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: JarvisColors.primary),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: JarvisColors.primary.withOpacity(0.5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: JarvisColors.primary, width: 2),
              ),
              filled: true,
              fillColor: JarvisColors.surfaceLight,
            ),
            onChanged: (value) => _label = value,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1);
  }

  Widget _buildRepeatDays() {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    
    return JarvisCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('REPEAT', style: JarvisTextStyles.labelLarge),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(7, (index) {
              final dayNum = index + 1;
              final isSelected = _repeatDays.contains(dayNum);
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _repeatDays.remove(dayNum);
                    } else {
                      _repeatDays.add(dayNum);
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? JarvisColors.primary : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? JarvisColors.primary : JarvisColors.textMuted,
                      width: 2,
                    ),
                    boxShadow: isSelected
                        ? [BoxShadow(color: JarvisColors.primary.withOpacity(0.4), blurRadius: 8)]
                        : [],
                  ),
                  child: Center(
                    child: Text(
                      days[index],
                      style: TextStyle(
                        color: isSelected ? JarvisColors.background : JarvisColors.textMuted,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              _getRepeatDescription(),
              style: JarvisTextStyles.caption,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1);
  }

  String _getRepeatDescription() {
    if (_repeatDays.isEmpty) return 'Once (will not repeat)';
    if (_repeatDays.length == 7) return 'Every day';
    if (_repeatDays.length == 5 && !_repeatDays.contains(6) && !_repeatDays.contains(7)) {
      return 'Weekdays';
    }
    if (_repeatDays.length == 2 && _repeatDays.contains(6) && _repeatDays.contains(7)) {
      return 'Weekends';
    }
    return 'Custom schedule';
  }

  Widget _buildSoundPicker() {
    return JarvisCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ALARM SOUND', style: JarvisTextStyles.labelLarge),
          const SizedBox(height: 12),
          InkWell(
            onTap: _pickSound,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: JarvisColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: JarvisColors.primary.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  Icon(
                    _soundPath != null ? Icons.music_note : Icons.music_off,
                    color: JarvisColors.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _soundPath != null 
                          ? _soundPath!.split('/').last 
                          : 'Select your MP3 file',
                      style: JarvisTextStyles.bodyMedium.copyWith(
                        color: _soundPath != null 
                            ? JarvisColors.textPrimary 
                            : JarvisColors.textMuted,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: JarvisColors.primary),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select your own audio file (e.g., "Back in Black")',
            style: JarvisTextStyles.caption,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1);
  }

  Future<void> _pickSound() async {
    final path = await AudioService.pickAudioFile();
    if (path != null) {
      setState(() => _soundPath = path);
    }
  }

  Widget _buildBriefingOptions() {
    return JarvisCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('MORNING BRIEFING', style: JarvisTextStyles.labelLarge),
          const SizedBox(height: 12),
          _buildToggleOption(
            icon: Icons.wb_sunny_outlined,
            label: 'Weather Report',
            description: 'Current conditions and forecast',
            value: _weatherBriefing,
            color: JarvisColors.secondary,
            onChanged: (value) => setState(() => _weatherBriefing = value),
          ),
          const Divider(color: JarvisColors.surfaceLight, height: 24),
          _buildToggleOption(
            icon: Icons.newspaper_outlined,
            label: 'News Briefing',
            description: 'AI-summarized world news',
            value: _newsBriefing,
            color: JarvisColors.tertiary,
            onChanged: (value) => setState(() => _newsBriefing = value),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1);
  }

  Widget _buildToggleOption({
    required IconData icon,
    required String label,
    required String description,
    required bool value,
    required Color color,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: JarvisTextStyles.bodyLarge.copyWith(color: JarvisColors.textPrimary)),
              Text(description, style: JarvisTextStyles.caption),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildVolumeSlider() {
    return JarvisCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('VOLUME', style: JarvisTextStyles.labelLarge),
              Text('${(_volume * 100).round()}%', style: JarvisTextStyles.labelLarge),
            ],
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
              activeTrackColor: JarvisColors.primary,
              inactiveTrackColor: JarvisColors.surfaceLight,
              thumbColor: JarvisColors.primary,
              overlayColor: JarvisColors.primary.withOpacity(0.2),
            ),
            child: Slider(
              value: _volume,
              onChanged: (value) => setState(() => _volume = value),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1);
  }

  Widget _buildSnoozeOptions() {
    return JarvisCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SNOOZE DURATION', style: JarvisTextStyles.labelLarge),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [5, 10, 15, 20].map((minutes) {
              final isSelected = _snoozeMinutes == minutes;
              return GestureDetector(
                onTap: () => setState(() => _snoozeMinutes = minutes),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? JarvisColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? JarvisColors.primary : JarvisColors.textMuted,
                    ),
                  ),
                  child: Text(
                    '${minutes}m',
                    style: TextStyle(
                      color: isSelected ? JarvisColors.background : JarvisColors.textMuted,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1);
  }

  Widget _buildSaveButton() {
    return JarvisButton(
      label: _isEditing ? 'UPDATE ALARM' : 'SET ALARM',
      icon: Icons.check,
      isLoading: _isSaving,
      onPressed: _saveAlarm,
    ).animate().fadeIn(delay: 700.ms).scale();
  }

  Future<void> _saveAlarm() async {
    setState(() => _isSaving = true);

    final alarm = AlarmModel(
      id: widget.alarm?.id ?? DateTime.now().millisecondsSinceEpoch,
      hour: _selectedHour,
      minute: _selectedMinute,
      label: _label,
      isEnabled: true,
      repeatDays: _repeatDays,
      soundPath: _soundPath,
      weatherBriefing: _weatherBriefing,
      newsBriefing: _newsBriefing,
      volume: _volume,
      snoozeMinutes: _snoozeMinutes,
    );

    await AlarmService.saveAlarm(alarm);

    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.pop(context, true);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Alarm ${_isEditing ? 'updated' : 'set'} for ${alarm.formattedTime}',
            style: const TextStyle(color: JarvisColors.textPrimary),
          ),
          backgroundColor: JarvisColors.surface,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _deleteAlarm() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: JarvisColors.surface,
        title: Text('Delete Alarm', style: JarvisTextStyles.headlineMedium),
        content: const Text(
          'Are you sure you want to delete this alarm?',
          style: TextStyle(color: JarvisColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL', style: TextStyle(color: JarvisColors.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('DELETE', style: TextStyle(color: JarvisColors.error)),
          ),
        ],
      ),
    );

    if (confirm == true && widget.alarm != null) {
      await AlarmService.deleteAlarm(widget.alarm!.id);
      if (mounted) Navigator.pop(context, true);
    }
  }
}

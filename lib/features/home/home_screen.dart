import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/theme/jarvis_theme.dart';
import '../../core/models/alarm_model.dart';
import '../../core/services/alarm_service.dart';
import '../../core/widgets/jarvis_widgets.dart';
import '../create_alarm/create_alarm_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  List<AlarmModel> _alarms = [];
  bool _isLoading = true;
  late AnimationController _pulseController;
  late Timer _clockTimer;
  String _currentTime = '';
  String _currentDate = '';

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _updateTime();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
    
    _loadAlarms();
    _requestPermissions();
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      _currentDate = _formatDate(now);
    });
  }

  String _formatDate(DateTime date) {
    const days = ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY'];
    const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.notification,
      Permission.scheduleExactAlarm,
      Permission.location,
    ].request();
  }

  Future<void> _loadAlarms() async {
    setState(() => _isLoading = true);
    final alarms = await AlarmService.getAlarms();
    setState(() {
      _alarms = alarms;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _clockTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: JarvisColors.background,
      body: Stack(
        children: [
          // Animated background
          _buildBackground(),
          
          // Main content
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildTimeDisplay(),
                Expanded(child: _buildAlarmsList()),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFab(),
    );
  }

  Widget _buildBackground() {
    return Stack(
      children: [
        // Grid pattern
        CustomPaint(
          size: Size.infinite,
          painter: GridPainter(),
        ),
        // Gradient overlay
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topCenter,
              radius: 1.5,
              colors: [
                JarvisColors.primary.withOpacity(0.1),
                JarvisColors.background,
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'J.A.R.V.I.S',
                style: JarvisTextStyles.headlineLarge.copyWith(
                  color: JarvisColors.primary,
                  shadows: [
                    Shadow(
                      color: JarvisColors.primary.withOpacity(0.5),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2),
              const SizedBox(height: 4),
              Text(
                'ALARM SYSTEM ONLINE',
                style: JarvisTextStyles.caption.copyWith(
                  color: JarvisColors.textSecondary,
                  letterSpacing: 2,
                ),
              ).animate().fadeIn(delay: 300.ms, duration: 600.ms),
            ],
          ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ).then((_) => _loadAlarms()),
            icon: const Icon(Icons.settings, color: JarvisColors.primary),
          ).animate().fadeIn(delay: 500.ms).scale(),
        ],
      ),
    );
  }

  Widget _buildTimeDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          // Large time display
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Text(
                _currentTime,
                style: JarvisTextStyles.displayLarge.copyWith(
                  fontSize: 72,
                  color: JarvisColors.textPrimary,
                  shadows: [
                    Shadow(
                      color: JarvisColors.primary.withOpacity(0.3 + 0.2 * _pulseController.value),
                      blurRadius: 20 + 10 * _pulseController.value,
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            _currentDate,
            style: JarvisTextStyles.labelLarge.copyWith(
              color: JarvisColors.textSecondary,
              letterSpacing: 3,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms).scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildAlarmsList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: JarvisColors.primary),
      );
    }

    if (_alarms.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _alarms.length,
      itemBuilder: (context, index) {
        return _buildAlarmCard(_alarms[index], index);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.alarm_off,
            size: 80,
            color: JarvisColors.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'NO ALARMS CONFIGURED',
            style: JarvisTextStyles.headlineMedium.copyWith(
              color: JarvisColors.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to create your first alarm',
            style: JarvisTextStyles.bodyMedium.copyWith(
              color: JarvisColors.textMuted,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms);
  }

  Widget _buildAlarmCard(AlarmModel alarm, int index) {
    return Dismissible(
      key: Key(alarm.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: JarvisColors.error.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: JarvisColors.error),
      ),
      onDismissed: (_) async {
        await AlarmService.deleteAlarm(alarm.id);
        _loadAlarms();
      },
      child: JarvisCard(
        glowColor: alarm.isEnabled ? JarvisColors.primary : JarvisColors.textMuted,
        animate: alarm.isEnabled,
        padding: const EdgeInsets.all(0),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _editAlarm(alarm),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Time display
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            alarm.formattedTime12Hour,
                            style: JarvisTextStyles.displayMedium.copyWith(
                              color: alarm.isEnabled 
                                  ? JarvisColors.textPrimary 
                                  : JarvisColors.textMuted,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              alarm.period,
                              style: JarvisTextStyles.labelLarge.copyWith(
                                color: alarm.isEnabled 
                                    ? JarvisColors.primary 
                                    : JarvisColors.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        alarm.label.isNotEmpty ? alarm.label : alarm.repeatDaysString,
                        style: JarvisTextStyles.bodyMedium.copyWith(
                          color: JarvisColors.textSecondary,
                        ),
                      ),
                      if (alarm.isEnabled) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              size: 14,
                              color: JarvisColors.primary.withOpacity(0.7),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'In ${alarm.timeUntilAlarm}',
                              style: JarvisTextStyles.caption.copyWith(
                                color: JarvisColors.primary.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                  const Spacer(),
                  // Features icons
                  Row(
                    children: [
                      if (alarm.weatherBriefing)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Icon(
                            Icons.wb_sunny_outlined,
                            size: 18,
                            color: alarm.isEnabled 
                                ? JarvisColors.secondary 
                                : JarvisColors.textMuted,
                          ),
                        ),
                      if (alarm.newsBriefing)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Icon(
                            Icons.newspaper_outlined,
                            size: 18,
                            color: alarm.isEnabled 
                                ? JarvisColors.tertiary 
                                : JarvisColors.textMuted,
                          ),
                        ),
                    ],
                  ),
                  // Toggle switch
                  Switch(
                    value: alarm.isEnabled,
                    onChanged: (value) async {
                      await AlarmService.toggleAlarm(alarm.id, value);
                      _loadAlarms();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ).animate(delay: (100 * index).ms).fadeIn().slideX(begin: 0.1),
    ).animate().then().shimmer(
      duration: 2000.ms,
      color: alarm.isEnabled ? JarvisColors.primary.withOpacity(0.05) : Colors.transparent,
    );
  }

  Widget _buildFab() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: JarvisColors.primary.withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: _createNewAlarm,
        backgroundColor: JarvisColors.primary,
        child: const Icon(Icons.add, color: JarvisColors.background, size: 32),
      ),
    ).animate().scale(delay: 500.ms, duration: 400.ms, curve: Curves.elasticOut);
  }

  void _createNewAlarm() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateAlarmScreen()),
    );
    if (result == true) {
      _loadAlarms();
    }
  }

  void _editAlarm(AlarmModel alarm) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CreateAlarmScreen(alarm: alarm)),
    );
    if (result == true) {
      _loadAlarms();
    }
  }
}

/// Grid pattern painter for background
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = JarvisColors.primary.withOpacity(0.05)
      ..strokeWidth = 0.5;

    const spacing = 30.0;

    // Vertical lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Horizontal lines
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/jarvis_theme.dart';
import '../../core/models/alarm_model.dart';
import '../../core/models/weather_model.dart';
import '../../core/services/alarm_service.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/weather_service.dart';
import '../../core/services/news_service.dart';
import '../../core/services/tts_service.dart';
import '../../core/widgets/jarvis_widgets.dart';

class AlarmRingScreen extends StatefulWidget {
  const AlarmRingScreen({super.key});

  @override
  State<AlarmRingScreen> createState() => _AlarmRingScreenState();
}

class _AlarmRingScreenState extends State<AlarmRingScreen>
    with TickerProviderStateMixin {
  AlarmModel? _alarm;
  WeatherData? _weather;
  String _newsBriefing = '';
  bool _isLoadingBriefing = true;
  bool _isBriefingPlaying = false;
  String _currentTime = '';
  
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Timer _clockTimer;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _updateTime();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAlarm();
    });
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    });
  }

  Future<void> _initializeAlarm() async {
    // Get alarm data from route arguments
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String) {
      _alarm = AlarmModel.fromJson(jsonDecode(args));
    }

    // Start playing alarm sound
    await AudioService.playAlarm(_alarm?.soundPath);

    // Load weather and news in background
    _loadBriefingData();
  }

  Future<void> _loadBriefingData() async {
    try {
      // Load weather
      if (_alarm?.weatherBriefing ?? true) {
        _weather = await WeatherService.getCurrentWeather();
      }

      // Load news
      if (_alarm?.newsBriefing ?? true) {
        _newsBriefing = await NewsService.getNewsBriefing();
      }

      setState(() => _isLoadingBriefing = false);
    } catch (e) {
      print('Error loading briefing: $e');
      setState(() => _isLoadingBriefing = false);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    _clockTimer.cancel();
    AudioService.stopAlarm();
    TtsService.stop();
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
          
          // Content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40),
                _buildTimeDisplay(),
                const Spacer(),
                _buildCenterDisplay(),
                const Spacer(),
                _buildBriefingStatus(),
                const SizedBox(height: 20),
                _buildActions(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(
      children: [
        // Pulsing glow
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, _) {
            return Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.5 + 0.5 * _pulseController.value,
                  colors: [
                    JarvisColors.primary.withOpacity(0.2 + 0.1 * _pulseController.value),
                    JarvisColors.background,
                  ],
                ),
              ),
            );
          },
        ),
        
        // Grid pattern
        CustomPaint(
          size: Size.infinite,
          painter: _GridPainter(),
        ),
      ],
    );
  }

  Widget _buildTimeDisplay() {
    return Column(
      children: [
        Text(
          'ALARM',
          style: JarvisTextStyles.labelLarge.copyWith(
            color: JarvisColors.secondary,
            letterSpacing: 8,
          ),
        ).animate(onPlay: (c) => c.repeat(reverse: true))
            .fadeIn().then()
            .shimmer(duration: 1500.ms, color: JarvisColors.secondary),
        const SizedBox(height: 8),
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, _) {
            return Text(
              _currentTime,
              style: JarvisTextStyles.displayLarge.copyWith(
                fontSize: 64,
                shadows: [
                  Shadow(
                    color: JarvisColors.primary.withOpacity(0.5 + 0.3 * _pulseController.value),
                    blurRadius: 30,
                  ),
                ],
              ),
            );
          },
        ),
        if (_alarm?.label.isNotEmpty ?? false) ...[
          const SizedBox(height: 8),
          Text(
            _alarm!.label,
            style: JarvisTextStyles.bodyLarge.copyWith(
              color: JarvisColors.textSecondary,
            ),
          ),
        ],
      ],
    ).animate().fadeIn().slideY(begin: -0.2);
  }

  Widget _buildCenterDisplay() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Rotating HUD rings
        AnimatedBuilder(
          animation: _rotationController,
          builder: (context, _) {
            return Transform.rotate(
              angle: _rotationController.value * 2 * math.pi,
              child: CustomPaint(
                size: const Size(280, 280),
                painter: _HudRingsPainter(
                  color: JarvisColors.primary,
                  pulse: _pulseController.value,
                ),
              ),
            );
          },
        ),
        
        // Counter-rotating inner ring
        AnimatedBuilder(
          animation: _rotationController,
          builder: (context, _) {
            return Transform.rotate(
              angle: -_rotationController.value * 2 * math.pi * 0.5,
              child: CustomPaint(
                size: const Size(200, 200),
                painter: _HudRingsPainter(
                  color: JarvisColors.secondary,
                  pulse: _pulseController.value,
                  ringCount: 1,
                ),
              ),
            );
          },
        ),
        
        // Center icon
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: JarvisColors.surface,
            border: Border.all(color: JarvisColors.primary, width: 3),
            boxShadow: [
              BoxShadow(
                color: JarvisColors.primary.withOpacity(0.5),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Icon(
            _isBriefingPlaying ? Icons.graphic_eq : Icons.alarm,
            size: 50,
            color: JarvisColors.primary,
          ),
        ).animate(onPlay: (c) => c.repeat(reverse: true))
            .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.05, 1.05), duration: 1000.ms),
      ],
    );
  }

  Widget _buildBriefingStatus() {
    if (_isLoadingBriefing) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: JarvisColors.primary.withOpacity(0.7),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'PREPARING BRIEFING...',
            style: JarvisTextStyles.caption.copyWith(
              color: JarvisColors.textSecondary,
              letterSpacing: 2,
            ),
          ),
        ],
      ).animate().fadeIn();
    }

    if (_isBriefingPlaying) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: JarvisColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: JarvisColors.primary.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.volume_up, color: JarvisColors.primary, size: 20),
            const SizedBox(width: 12),
            Text(
              'BRIEFING IN PROGRESS',
              style: JarvisTextStyles.labelLarge.copyWith(
                fontSize: 12,
              ),
            ),
          ],
        ),
      ).animate().fadeIn().slideY(begin: 0.2);
    }

    return JarvisButton(
      label: 'START BRIEFING',
      icon: Icons.play_arrow,
      color: JarvisColors.tertiary,
      onPressed: _startBriefing,
    ).animate().fadeIn().scale();
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Snooze button
          _ActionButton(
            icon: Icons.snooze,
            label: 'SNOOZE',
            color: JarvisColors.secondary,
            onTap: _snoozeAlarm,
          ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2),
          
          // Dismiss button
          _ActionButton(
            icon: Icons.close,
            label: 'DISMISS',
            color: JarvisColors.error,
            onTap: _dismissAlarm,
            isLarge: true,
          ).animate().fadeIn(delay: 100.ms).scale(),
          
          // Skip briefing (if playing)
          _ActionButton(
            icon: _isBriefingPlaying ? Icons.skip_next : Icons.volume_off,
            label: _isBriefingPlaying ? 'SKIP' : 'MUTE',
            color: JarvisColors.textMuted,
            onTap: _isBriefingPlaying ? _skipBriefing : _muteAlarm,
          ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.2),
        ],
      ),
    );
  }

  Future<void> _startBriefing() async {
    setState(() => _isBriefingPlaying = true);
    
    // Lower music volume
    await AudioService.lowerVolumeForBriefing();

    // Build briefing text
    String weatherBriefing = '';
    if (_weather != null && (_alarm?.weatherBriefing ?? true)) {
      weatherBriefing = _weather!.getSpokenBriefing();
    }

    // Speak the briefing
    await TtsService.speakMorningBriefing(
      weatherBriefing: weatherBriefing,
      newsBriefing: _newsBriefing,
      onComplete: () {
        // Restore volume after briefing
        AudioService.restoreVolume();
        if (mounted) {
          setState(() => _isBriefingPlaying = false);
        }
      },
    );
  }

  void _skipBriefing() {
    TtsService.stop();
    AudioService.restoreVolume();
    setState(() => _isBriefingPlaying = false);
  }

  void _muteAlarm() {
    if (AudioService.isPlaying) {
      AudioService.pauseAlarm();
    } else {
      AudioService.resumeAlarm();
    }
  }

  Future<void> _snoozeAlarm() async {
    await AudioService.stopAlarm();
    await TtsService.stop();
    
    if (_alarm != null) {
      await AlarmService.snoozeAlarm(_alarm!, minutes: _alarm!.snoozeMinutes);
    }
    
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Alarm snoozed for ${_alarm?.snoozeMinutes ?? 5} minutes',
            style: const TextStyle(color: JarvisColors.textPrimary),
          ),
          backgroundColor: JarvisColors.surface,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _dismissAlarm() async {
    await AudioService.stopAlarm();
    await TtsService.stop();
    
    if (_alarm != null) {
      await AlarmService.rescheduleRepeatingAlarm(_alarm!);
    }
    
    if (mounted) {
      Navigator.pop(context);
    }
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isLarge;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = isLarge ? 80.0 : 60.0;
    
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.1),
              border: Border.all(color: color, width: 2),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(icon, color: color, size: isLarge ? 36 : 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: JarvisTextStyles.caption.copyWith(
              color: color,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = JarvisColors.primary.withOpacity(0.03)
      ..strokeWidth = 1;

    const spacing = 40.0;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HudRingsPainter extends CustomPainter {
  final Color color;
  final double pulse;
  final int ringCount;

  _HudRingsPainter({
    required this.color,
    required this.pulse,
    this.ringCount = 2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    for (int i = 0; i < ringCount; i++) {
      final ringRadius = radius - (i * 20);
      
      // Glow
      final glowPaint = Paint()
        ..color = color.withOpacity(0.1 + 0.1 * pulse)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 8);
      canvas.drawCircle(center, ringRadius, glowPaint);

      // Main ring
      final ringPaint = Paint()
        ..color = color.withOpacity(0.4 + 0.2 * pulse)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(center, ringRadius, ringPaint);

      // Arc segments
      final arcPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;

      for (int j = 0; j < 4; j++) {
        canvas.save();
        canvas.translate(center.dx, center.dy);
        canvas.rotate(j * math.pi / 2);
        canvas.translate(-center.dx, -center.dy);
        
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: ringRadius),
          0.2,
          0.8,
          false,
          arcPaint,
        );
        
        canvas.restore();
      }
    }

    // Tick marks
    for (int i = 0; i < 24; i++) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(i * math.pi / 12);
      
      final tickPaint = Paint()
        ..color = color.withOpacity(i % 6 == 0 ? 0.8 : 0.3)
        ..strokeWidth = i % 6 == 0 ? 2 : 1;
      
      canvas.drawLine(
        Offset(0, -radius + 5),
        Offset(0, -radius + (i % 6 == 0 ? 15 : 10)),
        tickPaint,
      );
      
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _HudRingsPainter oldDelegate) {
    return oldDelegate.pulse != pulse;
  }
}

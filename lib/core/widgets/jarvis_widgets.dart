import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/jarvis_theme.dart';

/// JARVIS-style glowing card
class JarvisCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color glowColor;
  final bool animate;

  const JarvisCard({
    super.key,
    required this.child,
    this.padding,
    this.glowColor = JarvisColors.primary,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: JarvisColors.surface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: glowColor.withOpacity(0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: child,
    );

    if (animate) {
      card = card
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .shimmer(
            duration: 3000.ms,
            color: glowColor.withOpacity(0.1),
          );
    }

    return card;
  }
}

/// JARVIS-style button with glow effect
class JarvisButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color color;
  final bool isOutlined;
  final bool isLoading;

  const JarvisButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.color = JarvisColors.primary,
    this.isOutlined = false,
    this.isLoading = false,
  });

  @override
  State<JarvisButton> createState() => _JarvisButtonState();
}

class _JarvisButtonState extends State<JarvisButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: widget.isOutlined
              ? Colors.transparent
              : (_isPressed ? widget.color.withOpacity(0.8) : widget.color),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.color,
            width: 2,
          ),
          boxShadow: _isPressed
              ? []
              : [
                  BoxShadow(
                    color: widget.color.withOpacity(0.4),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
        ),
        child: widget.isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: widget.isOutlined ? widget.color : JarvisColors.background,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      size: 20,
                      color: widget.isOutlined ? widget.color : JarvisColors.background,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    widget.label.toUpperCase(),
                    style: JarvisTextStyles.labelLarge.copyWith(
                      color: widget.isOutlined ? widget.color : JarvisColors.background,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// JARVIS-style circular button (like arc reactor)
class JarvisCircularButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color color;
  final double size;
  final String? tooltip;

  const JarvisCircularButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.color = JarvisColors.primary,
    this.size = 60,
    this.tooltip,
  });

  @override
  State<JarvisCircularButton> createState() => _JarvisCircularButtonState();
}

class _JarvisCircularButtonState extends State<JarvisCircularButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: JarvisColors.surface,
              border: Border.all(
                color: widget.color,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(0.3 + 0.2 * _controller.value),
                  blurRadius: 15 + 5 * _controller.value,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              widget.icon,
              color: widget.color,
              size: widget.size * 0.5,
            ),
          );
        },
      ),
    );
  }
}

/// Animated builder helper
class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext, Widget?) builder;
  final Widget? child;

  const AnimatedBuilder({
    super.key,
    required Animation<double> animation,
    required this.builder,
    this.child,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    return builder(context, child);
  }
}

/// JARVIS-style HUD circle decoration
class HudCircle extends StatefulWidget {
  final double size;
  final Color color;
  final Widget? child;

  const HudCircle({
    super.key,
    this.size = 200,
    this.color = JarvisColors.primary,
    this.child,
  });

  @override
  State<HudCircle> createState() => _HudCircleState();
}

class _HudCircleState extends State<HudCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: HudCirclePainter(
            color: widget.color,
            rotation: _controller.value * 2 * 3.14159,
          ),
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: Center(child: widget.child),
          ),
        );
      },
    );
  }
}

class HudCirclePainter extends CustomPainter {
  final Color color;
  final double rotation;

  HudCirclePainter({required this.color, required this.rotation});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer glow ring
    final glowPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 10);
    canvas.drawCircle(center, radius - 10, glowPaint);

    // Main ring
    final ringPaint = Paint()
      ..color = color.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius - 10, ringPaint);

    // Inner ring
    final innerPaint = Paint()
      ..color = color.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius - 30, innerPaint);

    // Rotating arc
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    canvas.translate(-center.dx, -center.dy);

    final arcPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 10),
      0,
      1.5,
      false,
      arcPaint,
    );

    canvas.restore();

    // Tick marks
    for (int i = 0; i < 12; i++) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(i * 3.14159 / 6);
      
      final tickPaint = Paint()
        ..color = color.withOpacity(i % 3 == 0 ? 0.8 : 0.4)
        ..strokeWidth = i % 3 == 0 ? 2 : 1;
      
      canvas.drawLine(
        Offset(0, -radius + 15),
        Offset(0, -radius + (i % 3 == 0 ? 25 : 20)),
        tickPaint,
      );
      
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant HudCirclePainter oldDelegate) {
    return oldDelegate.rotation != rotation;
  }
}

/// Scanning line animation
class ScanningLine extends StatefulWidget {
  final double height;
  final Color color;

  const ScanningLine({
    super.key,
    this.height = 200,
    this.color = JarvisColors.primary,
  });

  @override
  State<ScanningLine> createState() => _ScanningLineState();
}

class _ScanningLineState extends State<ScanningLine>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            children: [
              Positioned(
                top: _controller.value * widget.height,
                left: 0,
                right: 0,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        widget.color,
                        Colors.transparent,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

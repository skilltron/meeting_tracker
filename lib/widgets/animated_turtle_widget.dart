import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../providers/calendar_provider.dart';
import '../models/calendar_event.dart';

class AnimatedTurtleWidget extends StatefulWidget {
  final Color textColor;
  final Color accentColor;
  
  const AnimatedTurtleWidget({
    super.key,
    required this.textColor,
    required this.accentColor,
  });

  @override
  State<AnimatedTurtleWidget> createState() => _AnimatedTurtleWidgetState();
}

class _AnimatedTurtleWidgetState extends State<AnimatedTurtleWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _homeStretchController;
  late Animation<double> _breatheAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Main animation for turtle movement and breathing
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    
    // Home stretch animation (faster when time is running low)
    _homeStretchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    // Breathing animation (subtle up/down)
    _breatheAnimation = Tween<double>(begin: 0, end: 3).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.5, curve: Curves.easeInOut),
      ),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    _homeStretchController.dispose();
    super.dispose();
  }
  
  // Calculate progress percentage (0.0 to 1.0) based on meeting time
  double _calculateProgress(CalendarEvent? currentEvent) {
    if (currentEvent == null) return 0.0;
    
    final now = DateTime.now();
    final totalDuration = currentEvent.end.difference(currentEvent.start);
    final elapsed = now.difference(currentEvent.start);
    
    if (elapsed.isNegative) return 0.0; // Meeting hasn't started
    if (elapsed >= totalDuration) return 1.0; // Meeting is over
    
    return elapsed.inMilliseconds / totalDuration.inMilliseconds;
  }
  
  // Check if we're in "home stretch" (last 15% of meeting)
  bool _isHomeStretch(double progress) {
    return progress >= 0.85;
  }
  
  // Calculate border position based on progress
  // Border path: top (0-0.25) → right (0.25-0.5) → bottom (0.5-0.75) → left (0.75-1.0)
  Offset _calculateBorderPosition(double progress, Size screenSize) {
    final turtleSize = const Size(80, 60);
    final padding = 10.0;
    
    // In home stretch, run left-to-right on top edge
    if (_isHomeStretch(progress)) {
      final homeStretchProgress = (progress - 0.85) / 0.15; // 0 to 1 within home stretch
      final x = padding + (screenSize.width - padding * 2 - turtleSize.width) * homeStretchProgress;
      return Offset(x, padding);
    }
    
    // Normal border traversal
    final perimeter = 2 * (screenSize.width + screenSize.height);
    final currentDistance = progress * perimeter;
    
    // Top edge (left to right)
    if (currentDistance < screenSize.width) {
      return Offset(currentDistance, padding);
    }
    
    // Right edge (top to bottom)
    final rightEdgeStart = screenSize.width;
    if (currentDistance < rightEdgeStart + screenSize.height) {
      final y = currentDistance - rightEdgeStart;
      return Offset(screenSize.width - turtleSize.width - padding, y);
    }
    
    // Bottom edge (right to left)
    final bottomEdgeStart = rightEdgeStart + screenSize.height;
    if (currentDistance < bottomEdgeStart + screenSize.width) {
      final x = screenSize.width - (currentDistance - bottomEdgeStart);
      return Offset(x, screenSize.height - turtleSize.height - padding);
    }
    
    // Left edge (bottom to top)
    final leftEdgeStart = bottomEdgeStart + screenSize.width;
    final y = screenSize.height - (currentDistance - leftEdgeStart);
    return Offset(padding, y);
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<CalendarProvider>(
      builder: (context, calendarProvider, child) {
        final currentEvent = calendarProvider.currentEvent;
        final progress = _calculateProgress(currentEvent);
        final isHomeStretch = _isHomeStretch(progress);
        
        // Start home stretch animation if needed
        if (isHomeStretch && !_homeStretchController.isAnimating) {
          _homeStretchController.repeat();
        } else if (!isHomeStretch && _homeStretchController.isAnimating) {
          _homeStretchController.stop();
          _homeStretchController.reset();
        }
        
        // If no meeting, hide turtle or show in default position
        if (currentEvent == null) {
          return const SizedBox.shrink();
        }
        
        return LayoutBuilder(
          builder: (context, constraints) {
            final screenSize = Size(constraints.maxWidth, constraints.maxHeight);
            final borderPosition = _calculateBorderPosition(progress, screenSize);
            
            return AnimatedBuilder(
              animation: Listenable.merge([_controller, _homeStretchController]),
              builder: (context, child) {
                // Add subtle movement animation for home stretch
                double homeStretchOffset = 0;
                if (isHomeStretch && _homeStretchController.isAnimating) {
                  homeStretchOffset = math.sin(_homeStretchController.value * 2 * math.pi) * 2;
                }
                
                return Positioned(
                  left: borderPosition.dx + homeStretchOffset,
                  top: borderPosition.dy - _breatheAnimation.value,
                  child: Opacity(
                    opacity: 0.7,
                    child: CustomPaint(
                      size: const Size(80, 60),
                      painter: TurtlePainter(
                        textColor: widget.textColor,
                        accentColor: widget.accentColor,
                        animationValue: _controller.value,
                        isHomeStretch: isHomeStretch,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class TurtlePainter extends CustomPainter {
  final Color textColor;
  final Color accentColor;
  final double animationValue;
  final bool isHomeStretch;
  
  TurtlePainter({
    required this.textColor,
    required this.accentColor,
    required this.animationValue,
    this.isHomeStretch = false,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Shell (main body) - rounded hexagon
    final shellPath = Path();
    final shellRadius = size.width * 0.3;
    final shellPoints = 6;
    
    for (int i = 0; i < shellPoints; i++) {
      final angle = (i * 2 * math.pi / shellPoints) - (math.pi / 2);
      final x = center.dx + shellRadius * math.cos(angle);
      final y = center.dy + shellRadius * math.sin(angle);
      if (i == 0) {
        shellPath.moveTo(x, y);
      } else {
        shellPath.lineTo(x, y);
      }
    }
    shellPath.close();
    
    // Draw shell with gradient effect
    final shellPaint = Paint()
      ..color = accentColor.withOpacity(0.4)
      ..style = PaintingStyle.fill;
    canvas.drawPath(shellPath, shellPaint);
    
    final shellBorderPaint = Paint()
      ..color = accentColor.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(shellPath, shellBorderPaint);
    
    // Shell pattern (hexagonal segments)
    for (int i = 0; i < 6; i++) {
      final angle = (i * 2 * math.pi / 6) - (math.pi / 2);
      final segmentPath = Path();
      segmentPath.moveTo(center.dx, center.dy);
      final x1 = center.dx + shellRadius * math.cos(angle);
      final y1 = center.dy + shellRadius * math.sin(angle);
      final x2 = center.dx + shellRadius * math.cos(angle + 2 * math.pi / 6);
      final y2 = center.dy + shellRadius * math.sin(angle + 2 * math.pi / 6);
      segmentPath.lineTo(x1, y1);
      segmentPath.lineTo(x2, y2);
      segmentPath.close();
      
      final segmentPaint = Paint()
        ..color = accentColor.withOpacity(0.2)
        ..style = PaintingStyle.fill;
      canvas.drawPath(segmentPath, segmentPaint);
    }
    
    // Head (animated - slight movement)
    final headOffset = Offset(
      center.dx + shellRadius * 0.6 * math.cos(animationValue * 2 * math.pi),
      center.dy + shellRadius * 0.6 * math.sin(animationValue * 2 * math.pi),
    );
    final headPaint = Paint()
      ..color = accentColor.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(headOffset, size.width * 0.12, headPaint);
    
    // Eyes
    final eyePaint = Paint()
      ..color = textColor.withOpacity(0.8)
      ..style = PaintingStyle.fill;
    final leftEye = Offset(headOffset.dx - size.width * 0.04, headOffset.dy - size.width * 0.02);
    final rightEye = Offset(headOffset.dx + size.width * 0.04, headOffset.dy - size.width * 0.02);
    canvas.drawCircle(leftEye, size.width * 0.03, eyePaint);
    canvas.drawCircle(rightEye, size.width * 0.03, eyePaint);
    
    // Legs (4 legs, faster animation in home stretch)
    final legLength = size.width * 0.15;
    final legPaint = Paint()
      ..color = accentColor.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    
    // Faster leg movement in home stretch
    final legSpeed = isHomeStretch ? 4.0 : 2.0;
    
    // Front left leg
    final frontLeftAngle = -math.pi / 4 + math.sin(animationValue * legSpeed * math.pi) * 0.2;
    final frontLeftEnd = Offset(
      center.dx + shellRadius * 0.7 * math.cos(frontLeftAngle),
      center.dy + shellRadius * 0.7 * math.sin(frontLeftAngle),
    );
    canvas.drawLine(
      Offset(center.dx + shellRadius * 0.5 * math.cos(frontLeftAngle),
             center.dy + shellRadius * 0.5 * math.sin(frontLeftAngle)),
      frontLeftEnd,
      legPaint,
    );
    
    // Front right leg
    final frontRightAngle = math.pi / 4 - math.sin(animationValue * legSpeed * math.pi) * 0.2;
    final frontRightEnd = Offset(
      center.dx + shellRadius * 0.7 * math.cos(frontRightAngle),
      center.dy + shellRadius * 0.7 * math.sin(frontRightAngle),
    );
    canvas.drawLine(
      Offset(center.dx + shellRadius * 0.5 * math.cos(frontRightAngle),
             center.dy + shellRadius * 0.5 * math.sin(frontRightAngle)),
      frontRightEnd,
      legPaint,
    );
    
    // Back left leg
    final backLeftAngle = -3 * math.pi / 4 + math.sin(animationValue * legSpeed * math.pi) * 0.2;
    final backLeftEnd = Offset(
      center.dx + shellRadius * 0.7 * math.cos(backLeftAngle),
      center.dy + shellRadius * 0.7 * math.sin(backLeftAngle),
    );
    canvas.drawLine(
      Offset(center.dx + shellRadius * 0.5 * math.cos(backLeftAngle),
             center.dy + shellRadius * 0.5 * math.sin(backLeftAngle)),
      backLeftEnd,
      legPaint,
    );
    
    // Back right leg
    final backRightAngle = 3 * math.pi / 4 - math.sin(animationValue * legSpeed * math.pi) * 0.2;
    final backRightEnd = Offset(
      center.dx + shellRadius * 0.7 * math.cos(backRightAngle),
      center.dy + shellRadius * 0.7 * math.sin(backRightAngle),
    );
    canvas.drawLine(
      Offset(center.dx + shellRadius * 0.5 * math.cos(backRightAngle),
             center.dy + shellRadius * 0.5 * math.sin(backRightAngle)),
      backRightEnd,
      legPaint,
    );
    
    // Tail (faster wag in home stretch)
    final tailSpeed = isHomeStretch ? 8.0 : 4.0;
    final tailAngle = math.pi + math.sin(animationValue * tailSpeed * math.pi) * 0.3;
    final tailPaint = Paint()
      ..color = accentColor.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final tailStart = Offset(
      center.dx + shellRadius * 0.6 * math.cos(tailAngle),
      center.dy + shellRadius * 0.6 * math.sin(tailAngle),
    );
    final tailEnd = Offset(
      center.dx + shellRadius * 1.1 * math.cos(tailAngle),
      center.dy + shellRadius * 1.1 * math.sin(tailAngle),
    );
    canvas.drawLine(tailStart, tailEnd, tailPaint);
  }
  
  @override
  bool shouldRepaint(TurtlePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.textColor != textColor ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.isHomeStretch != isHomeStretch;
  }
}

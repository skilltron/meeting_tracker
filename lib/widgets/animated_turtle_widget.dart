import 'package:flutter/material.dart';
import 'dart:math' as math;

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
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _swimAnimation;
  late Animation<double> _breatheAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Main swimming animation (slow, gentle)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    
    // Swimming motion (horizontal movement)
    _swimAnimation = Tween<double>(begin: -20, end: 20).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
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
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_swimAnimation.value, -_breatheAnimation.value),
          child: CustomPaint(
            size: const Size(80, 60),
            painter: TurtlePainter(
              textColor: widget.textColor,
              accentColor: widget.accentColor,
              animationValue: _controller.value,
            ),
          ),
        );
      },
    );
  }
}

class TurtlePainter extends CustomPainter {
  final Color textColor;
  final Color accentColor;
  final double animationValue;
  
  TurtlePainter({
    required this.textColor,
    required this.accentColor,
    required this.animationValue,
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
    
    // Legs (4 legs, subtle animation)
    final legLength = size.width * 0.15;
    final legPaint = Paint()
      ..color = accentColor.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    
    // Front left leg
    final frontLeftAngle = -math.pi / 4 + math.sin(animationValue * 2 * math.pi) * 0.2;
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
    final frontRightAngle = math.pi / 4 - math.sin(animationValue * 2 * math.pi) * 0.2;
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
    final backLeftAngle = -3 * math.pi / 4 + math.sin(animationValue * 2 * math.pi) * 0.2;
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
    final backRightAngle = 3 * math.pi / 4 - math.sin(animationValue * 2 * math.pi) * 0.2;
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
    
    // Tail (subtle wag)
    final tailAngle = math.pi + math.sin(animationValue * 4 * math.pi) * 0.3;
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
        oldDelegate.accentColor != accentColor;
  }
}

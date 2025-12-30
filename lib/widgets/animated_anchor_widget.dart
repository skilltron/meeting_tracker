import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Animated anchor widget that shows dropping/raising animation
/// Simulates a GIF-like animation of an anchor dropping or raising
class AnimatedAnchorWidget extends StatefulWidget {
  final bool isAnchored;
  final double size;
  final Color color;
  
  const AnimatedAnchorWidget({
    super.key,
    required this.isAnchored,
    this.size = 32.0,
    this.color = const Color(0xFFA8D5BA),
  });

  @override
  State<AnimatedAnchorWidget> createState() => _AnimatedAnchorWidgetState();
}

class _AnimatedAnchorWidgetState extends State<AnimatedAnchorWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _dropAnimation;
  late Animation<double> _swingAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    // Drop/raise animation (vertical movement)
    _dropAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    // Swing animation (pendulum motion)
    _swingAnimation = Tween<double>(
      begin: -0.3,
      end: 0.3,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    // Start animation when state changes
    if (widget.isAnchored) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }
  
  @override
  void didUpdateWidget(AnimatedAnchorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isAnchored != widget.isAnchored) {
      if (widget.isAnchored) {
        // Dropping anchor
        _controller.forward();
      } else {
        // Raising anchor
        _controller.reverse();
      }
    }
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
        // Calculate position based on animation
        final dropProgress = _dropAnimation.value;
        final swingAngle = _swingAnimation.value * math.pi;
        
        // When dropping: anchor moves down and swings
        // When raising: anchor moves up and swings less
        final verticalOffset = widget.isAnchored 
            ? dropProgress * 8.0  // Drop down 8 pixels
            : (1.0 - dropProgress) * 8.0;  // Raise up
        
        return Transform.translate(
          offset: Offset(0, verticalOffset),
          child: Transform.rotate(
            angle: swingAngle * (1.0 - dropProgress * 0.5), // Less swing when fully dropped
            child: CustomPaint(
              size: Size(widget.size, widget.size * 1.2),
              painter: _AnchorPainter(
                color: widget.color,
                progress: dropProgress,
                isAnchored: widget.isAnchored,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AnchorPainter extends CustomPainter {
  final Color color;
  final double progress;
  final bool isAnchored;
  
  _AnchorPainter({
    required this.color,
    required this.progress,
    required this.isAnchored,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    
    final fillPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    final centerX = size.width / 2;
    final topY = size.height * 0.1;
    final bottomY = size.height * 0.9;
    
    // Draw anchor ring (top)
    final ringRadius = size.width * 0.15;
    canvas.drawCircle(
      Offset(centerX, topY),
      ringRadius,
      paint,
    );
    canvas.drawCircle(
      Offset(centerX, topY),
      ringRadius,
      fillPaint,
    );
    
    // Draw anchor shank (vertical line)
    final shankTop = topY + ringRadius;
    final shankBottom = bottomY - size.width * 0.2;
    canvas.drawLine(
      Offset(centerX, shankTop),
      Offset(centerX, shankBottom),
      paint,
    );
    
    // Draw anchor arms (curved)
    final armLength = size.width * 0.25;
    final armStartY = shankBottom;
    
    // Left arm
    final leftPath = Path();
    leftPath.moveTo(centerX, armStartY);
    leftPath.quadraticBezierTo(
      centerX - armLength * 0.5,
      armStartY + armLength * 0.3,
      centerX - armLength,
      armStartY + armLength * 0.6,
    );
    canvas.drawPath(leftPath, paint);
    
    // Right arm
    final rightPath = Path();
    rightPath.moveTo(centerX, armStartY);
    rightPath.quadraticBezierTo(
      centerX + armLength * 0.5,
      armStartY + armLength * 0.3,
      centerX + armLength,
      armStartY + armLength * 0.6,
    );
    canvas.drawPath(rightPath, paint);
    
    // Draw anchor flukes (points)
    final flukeSize = size.width * 0.1;
    
    // Left fluke
    final leftFlukePath = Path();
    leftFlukePath.moveTo(centerX - armLength, armStartY + armLength * 0.6);
    leftFlukePath.lineTo(centerX - armLength - flukeSize, armStartY + armLength * 0.6 + flukeSize);
    leftFlukePath.lineTo(centerX - armLength, armStartY + armLength * 0.6 + flukeSize * 1.5);
    leftFlukePath.close();
    canvas.drawPath(leftFlukePath, fillPaint);
    canvas.drawPath(leftFlukePath, paint);
    
    // Right fluke
    final rightFlukePath = Path();
    rightFlukePath.moveTo(centerX + armLength, armStartY + armLength * 0.6);
    rightFlukePath.lineTo(centerX + armLength + flukeSize, armStartY + armLength * 0.6 + flukeSize);
    rightFlukePath.lineTo(centerX + armLength, armStartY + armLength * 0.6 + flukeSize * 1.5);
    rightFlukePath.close();
    canvas.drawPath(rightFlukePath, fillPaint);
    canvas.drawPath(rightFlukePath, paint);
    
    // Draw chain/rope when dropping (animated)
    if (progress > 0.1) {
      final chainPaint = Paint()
        ..color = color.withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      
      final chainLength = (topY - size.height * 0.05) * progress;
      final chainSegments = (chainLength / 4).floor();
      
      for (int i = 0; i < chainSegments; i++) {
        final y = topY - (i * 4);
        canvas.drawLine(
          Offset(centerX - 2, y),
          Offset(centerX + 2, y),
          chainPaint,
        );
      }
    }
  }
  
  @override
  bool shouldRepaint(_AnchorPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isAnchored != isAnchored;
  }
}

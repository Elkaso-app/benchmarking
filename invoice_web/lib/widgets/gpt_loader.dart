import 'package:flutter/material.dart';
import 'dart:math' as math;

/// GPT-style rotating logo loader
class GPTLoader extends StatefulWidget {
  final double size;
  final String? message;
  
  const GPTLoader({
    super.key,
    this.size = 60,
    this.message,
  });

  @override
  State<GPTLoader> createState() => _GPTLoaderState();
}

class _GPTLoaderState extends State<GPTLoader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: widget.size,
          height: widget.size,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.rotate(
                angle: _controller.value * 2 * math.pi,
                child: CustomPaint(
                  painter: GPTLogoPainter(),
                ),
              );
            },
          ),
        ),
        if (widget.message != null) ...[
          const SizedBox(height: 16),
          Text(
            widget.message!,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

/// Custom painter for GPT-style logo with gradient segments
class GPTLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    // Define gradient colors similar to ChatGPT logo
    final colors = [
      const Color(0xFF10A37F), // Green
      const Color(0xFF1A7F64), // Darker green
      const Color(0xFF19C37D), // Light green
      const Color(0xFF74AA9C), // Teal
    ];
    
    // Draw 4 segments with gaps
    const segments = 4;
    const gapAngle = math.pi / 12; // Gap between segments
    final segmentAngle = (2 * math.pi - (gapAngle * segments)) / segments;
    
    for (int i = 0; i < segments; i++) {
      final startAngle = (i * (segmentAngle + gapAngle)) - math.pi / 2;
      
      final paint = Paint()
        ..shader = SweepGradient(
          colors: [colors[i], colors[(i + 1) % colors.length]],
          startAngle: startAngle,
          endAngle: startAngle + segmentAngle,
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.15
        ..strokeCap = StrokeCap.round;
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius * 0.7),
        startAngle,
        segmentAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}







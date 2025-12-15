import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Magical wand loader with sparkles and particles
class MagicWandLoader extends StatefulWidget {
  final double size;
  final String? message;
  
  const MagicWandLoader({
    super.key,
    this.size = 80,
    this.message,
  });

  @override
  State<MagicWandLoader> createState() => _MagicWandLoaderState();
}

class _MagicWandLoaderState extends State<MagicWandLoader> 
    with TickerProviderStateMixin {
  late AnimationController _wandController;
  late AnimationController _sparkleController;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    
    // Wand rotation/movement
    _wandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    
    // Sparkle particles
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    
    // Glow pulse
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _wandController.dispose();
    _sparkleController.dispose();
    _glowController.dispose();
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
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Glow effect
              AnimatedBuilder(
                animation: _glowController,
                builder: (context, child) {
                  return Container(
                    width: widget.size * (0.6 + _glowController.value * 0.2),
                    height: widget.size * (0.6 + _glowController.value * 0.2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFFFBBF24).withOpacity(0.4), // Golden
                          const Color(0xFFF59E0B).withOpacity(0.2),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  );
                },
              ),
              
              // Magic sparkles (8 particles orbiting)
              ...List.generate(8, (index) {
                return AnimatedBuilder(
                  animation: _sparkleController,
                  builder: (context, child) {
                    final progress = (_sparkleController.value + (index / 8)) % 1.0;
                    final angle = progress * 2 * math.pi;
                    final radius = widget.size * 0.35;
                    final x = math.cos(angle) * radius;
                    final y = math.sin(angle) * radius;
                    
                    // Fade in and out
                    final opacity = (math.sin(progress * math.pi * 2) + 1) / 2;
                    final scale = 0.5 + (opacity * 0.5);
                    
                    return Transform.translate(
                      offset: Offset(x, y),
                      child: Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Color.lerp(
                                  const Color(0xFFFBBF24), // Gold
                                  const Color(0xFFF59E0B), // Amber
                                  index / 8,
                                )!.withOpacity(opacity),
                                Colors.transparent,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFBBF24).withOpacity(opacity * 0.6),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
              
              // Star sparkles (random twinkling)
              ...List.generate(6, (index) {
                return AnimatedBuilder(
                  animation: _sparkleController,
                  builder: (context, child) {
                    final progress = (_sparkleController.value * 2 + (index / 6)) % 1.0;
                    final angle = (index / 6) * 2 * math.pi + (_sparkleController.value * math.pi / 4);
                    final radius = widget.size * 0.25;
                    final x = math.cos(angle) * radius;
                    final y = math.sin(angle) * radius;
                    
                    // Twinkle effect
                    final opacity = progress < 0.5 
                        ? progress * 2 
                        : (1 - progress) * 2;
                    
                    return Transform.translate(
                      offset: Offset(x, y),
                      child: Transform.rotate(
                        angle: _sparkleController.value * 2 * math.pi,
                        child: Icon(
                          Icons.star,
                          size: 10,
                          color: const Color(0xFFFBBF24).withOpacity(opacity),
                        ),
                      ),
                    );
                  },
                );
              }),
              
              // Center magic wand icon with rotation
              AnimatedBuilder(
                animation: _wandController,
                builder: (context, child) {
                  final wobble = math.sin(_wandController.value * 2 * math.pi) * 0.3;
                  return Transform.rotate(
                    angle: wobble,
                    child: Container(
                      width: widget.size * 0.4,
                      height: widget.size * 0.4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFFBBF24), // Gold
                            Color(0xFFF59E0B), // Amber
                            Color(0xFFD97706), // Dark amber
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFBBF24).withOpacity(0.5),
                            blurRadius: 15,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.auto_fix_high,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  );
                },
              ),
              
              // Additional sparkle trails
              ...List.generate(4, (index) {
                return AnimatedBuilder(
                  animation: _wandController,
                  builder: (context, child) {
                    final progress = (_wandController.value + (index / 4)) % 1.0;
                    final angle = progress * 2 * math.pi + (index * math.pi / 2);
                    final radius = widget.size * 0.15 * (1 - progress);
                    final x = math.cos(angle) * radius;
                    final y = math.sin(angle) * radius;
                    final opacity = 1 - progress;
                    
                    return Transform.translate(
                      offset: Offset(x, y),
                      child: Container(
                        width: 6 * (1 - progress * 0.5),
                        height: 6 * (1 - progress * 0.5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFFBBF24).withOpacity(opacity),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFBBF24).withOpacity(opacity * 0.5),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ],
          ),
        ),
        
        if (widget.message != null) ...[
          const SizedBox(height: 20),
          AnimatedBuilder(
            animation: _glowController,
            builder: (context, child) {
              return Opacity(
                opacity: 0.7 + (_glowController.value * 0.3),
                child: Text(
                  widget.message!,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}






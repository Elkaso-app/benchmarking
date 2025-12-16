import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Magical AI-themed loader with particle effects
class AILoader extends StatefulWidget {
  final String? message;
  final double size;
  
  const AILoader({
    super.key,
    this.message,
    this.size = 80,
  });

  @override
  State<AILoader> createState() => _AILoaderState();
}

class _AILoaderState extends State<AILoader> with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _particleController;

  @override
  void initState() {
    super.initState();
    
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _particleController.dispose();
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
              // Outer rotating ring with gradient
              AnimatedBuilder(
                animation: _rotationController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotationController.value * 2 * math.pi,
                    child: Container(
                      width: widget.size,
                      height: widget.size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SweepGradient(
                          colors: [
                            const Color(0xFF1A237E).withOpacity(0.0),
                            const Color(0xFF1A237E),
                            const Color(0xFF3949AB),
                            const Color(0xFF5C6BC0).withOpacity(0.0),
                          ],
                          stops: const [0.0, 0.3, 0.6, 1.0],
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              // Pulsing center glow
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final scale = 0.4 + (_pulseController.value * 0.2);
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: widget.size * 0.5,
                      height: widget.size * 0.5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF5C6BC0),
                            const Color(0xFF5C6BC0).withOpacity(0.5),
                            const Color(0xFF5C6BC0).withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              // Center icon with sparkle
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    width: widget.size * 0.35,
                    height: widget.size * 0.35,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF1A237E),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF5C6BC0).withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: _pulseController.value * 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 24,
                    ),
                  );
                },
              ),
              
              // Orbiting particles
              ...List.generate(3, (index) {
                return AnimatedBuilder(
                  animation: _particleController,
                  builder: (context, child) {
                    final angle = (_particleController.value * 2 * math.pi) + 
                                 (index * 2 * math.pi / 3);
                    final radius = widget.size * 0.4;
                    final x = math.cos(angle) * radius;
                    final y = math.sin(angle) * radius;
                    
                    return Transform.translate(
                      offset: Offset(x, y),
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF5C6BC0),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF5C6BC0).withOpacity(0.8),
                              blurRadius: 4,
                              spreadRadius: 1,
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
          const SizedBox(height: 24),
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Opacity(
                opacity: 0.7 + (_pulseController.value * 0.3),
                child: Text(
                  widget.message!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A237E),
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

/// Processing stages indicator
class ProcessingStages extends StatelessWidget {
  final int currentStage;
  final List<String> stages = const [
    'Uploading files',
    'AI scanning documents',
    'Extracting data',
    'Analyzing costs',
    'Calculating savings',
  ];

  const ProcessingStages({
    super.key,
    required this.currentStage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF1A237E).withOpacity(0.1),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A237E).withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: List.generate(stages.length, (index) {
          final isActive = index == currentStage;
          final isDone = index < currentStage;
          
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                // Stage indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDone 
                        ? const Color(0xFF4CAF50) 
                        : isActive 
                            ? const Color(0xFF1A237E)
                            : Colors.grey.shade200,
                    boxShadow: isActive ? [
                      BoxShadow(
                        color: const Color(0xFF1A237E).withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ] : null,
                  ),
                  child: Center(
                    child: isDone
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : isActive
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(Colors.white),
                                ),
                              )
                            : Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Stage text
                Expanded(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      color: isDone 
                          ? const Color(0xFF4CAF50)
                          : isActive 
                              ? const Color(0xFF1A237E)
                              : Colors.grey.shade400,
                    ),
                    child: Text(stages[index]),
                  ),
                ),
                
                // Active indicator
                if (isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A237E).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Processing...',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF1A237E),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}







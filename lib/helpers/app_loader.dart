import 'dart:math';

import 'package:flutter/material.dart';

class AppCircularLoader extends StatefulWidget {
  const AppCircularLoader({super.key});

  @override
  State<AppCircularLoader> createState() => _AppCircularLoaderState();
}

class _AppCircularLoaderState extends State<AppCircularLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _animation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Color(0xFF1F7CCD).withOpacity(0.4),
            Colors.white.withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.rotate(
            angle: _animation.value,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer ring with gradient
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Color(0xFF1F7CCD).withOpacity(0.6),
                      width: 4,
                    ),
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF1F7CCD).withOpacity(0.8),
                        Color(0xFF1F7CCD).withOpacity(0.2),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                // Inner dots for animation effect
                for (int i = 0; i < 8; i++)
                  Transform.rotate(
                    angle: i * pi / 4,
                    child: Container(
                      margin: const EdgeInsets.only(top: 20),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.7 - i * 0.05),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

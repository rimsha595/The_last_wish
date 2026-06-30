import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../services/timer_service.dart';
import 'home_screen.dart';
import 'lock_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController glowController;

  @override
  void initState() {
    super.initState();

    glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    checkAccess();
  }

  Future<void> checkAccess() async {
    // Show splash for 5 seconds
    await Future.delayed(const Duration(seconds: 5));

    if (!mounted) return;

    // Check whether the timer is still active
    final canUse = await TimerService.canUseApp();

    if (canUse) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
      );
      return;
    }

    // Timer is active, get its start time
    final startTime = await TimerService.getStartTime();

    // If somehow startTime is null, go to HomeScreen
    if (startTime == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
      );
      return;
    }

    // Open Lock Screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => LockScreen(
          startTime: startTime,
        ),
      ),
    );
  }

  @override
  void dispose() {
    glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          /// Floating Particles
          const ParticleLayer(),

          /// Red Glow
          Center(
            child: AnimatedBuilder(
              animation: glowController,
              builder: (_, __) {
                return Container(
                  width: 260 + (glowController.value * 80),
                  height: 260 + (glowController.value * 80),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(.35),
                        blurRadius: 120,
                        spreadRadius: 30,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          /// Main UI
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/images/logo.png",
                  width: 220,
                ).animate().fadeIn(duration: 1200.ms).scale(
                      begin: const Offset(.5, .5),
                      end: const Offset(1, 1),
                      curve: Curves.easeOutBack,
                    ),
                const SizedBox(height: 25),
                const Text(
                  "THE LAST WISH",
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 5,
                  ),
                ).animate(delay: 800.ms).fadeIn().slideY(begin: .6),
                const SizedBox(height: 12),
                const Text(
                  "Every Wish Has A Price",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    letterSpacing: 2,
                  ),
                ).animate(delay: 1300.ms).fadeIn(),
                const SizedBox(height: 45),
                SizedBox(
                  width: 45,
                  height: 45,
                  child: CircularProgressIndicator(
                    color: Colors.redAccent,
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Summoning Darkness...",
                  style: TextStyle(
                    color: Colors.white54,
                    letterSpacing: 2,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Floating Red Particles

class ParticleLayer extends StatelessWidget {
  const ParticleLayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(
        40,
        (index) {
          final random = Random(index);

          return Positioned(
            left: random.nextDouble() * MediaQuery.of(context).size.width,
            top: random.nextDouble() * MediaQuery.of(context).size.height,
            child: TweenAnimationBuilder(
              tween: Tween(
                begin: 0.0,
                end: 20.0,
              ),
              duration: Duration(
                seconds: 2 + random.nextInt(4),
              ),
              curve: Curves.easeInOut,
              builder: (_, value, child) {
                return Transform.translate(
                  offset: Offset(
                    0,
                    -(value as double),
                  ),
                  child: child,
                );
              },
              onEnd: () {},
              child: Container(
                width: 3,
                height: 3,
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

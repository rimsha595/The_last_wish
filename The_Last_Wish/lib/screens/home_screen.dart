import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';
import 'wish_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _flickerController;

  // Audio Players
  final AudioPlayer whisperPlayer = AudioPlayer();
  final AudioPlayer heartbeatPlayer = AudioPlayer();
  final AudioPlayer horrorPlayer = AudioPlayer();
  final AudioPlayer endPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _flickerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    )..repeat(reverse: true);

    _playBackgroundSounds();
  }

  Future<void> _playBackgroundSounds() async {
    // Horror Background
    await horrorPlayer.setReleaseMode(ReleaseMode.loop);
    await horrorPlayer.setVolume(0.25); // volume apni marzi se adjust kar lo
    await horrorPlayer.play(AssetSource('sounds/horror.mp3'));

    // Whisper
    await whisperPlayer.setReleaseMode(ReleaseMode.loop);
    await whisperPlayer.setVolume(0.35);
    await whisperPlayer.play(AssetSource('sounds/whisper.mp3'));

    // Heartbeat
    await heartbeatPlayer.setReleaseMode(ReleaseMode.loop);
    await heartbeatPlayer.setVolume(0.5);
    await heartbeatPlayer.play(AssetSource('sounds/heartbeat.mp3'));

    // End sound (plays once)
    await Future.delayed(const Duration(seconds: 2));

    await endPlayer.play(AssetSource('sounds/end.mp3'));
  }

  Future<void> _stopAllSounds() async {
    await horrorPlayer.stop();
    await whisperPlayer.stop();
    await heartbeatPlayer.stop();
    await endPlayer.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/dark_forest.jpg",
              fit: BoxFit.cover,
            ),
          ),

          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.9),
                    Colors.black,
                  ],
                  radius: 1.3,
                ),
              ),
            ),
          ),

          Positioned.fill(
            child: Opacity(
              opacity: 0.12,
              child: Image.asset("assets/images/fog.png", fit: BoxFit.cover),
            ),
          ),

          AnimatedBuilder(
            animation: _flickerController,
            builder: (context, child) {
              return Container(
                color: Colors.black.withOpacity(
                  0.15 + Random().nextDouble() * 0.25,
                ),
              );
            },
          ),

          SafeArea(
            child: Column(
              children: [
                const Spacer(),

                /// TITLE
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    double t = _pulseController.value;

                    return Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.25 + t * 0.3),
                            blurRadius: 30 + t * 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ShaderMask(
                        shaderCallback: (rect) {
                          return const LinearGradient(
                            colors: [
                              Colors.red,
                              Colors.white,
                              Colors.redAccent,
                            ],
                          ).createShader(rect);
                        },
                        child: const Text(
                          "THE LAST\nWISH",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 54,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 6,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 10),

                const Text(
                  "It is already watching you...",
                  style: TextStyle(color: Colors.white70, letterSpacing: 2),
                ),

                const Spacer(),

                /// 🔥 RED NEON BUTTON
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    double t = _pulseController.value;

                    return Transform.scale(
                      scale: 1 + (t * 0.06),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.8),
                              blurRadius: 25 + t * 25,
                              spreadRadius: 1 + t * 4,
                            ),
                            BoxShadow(
                              color: Colors.deepOrange.withOpacity(0.4),
                              blurRadius: 45 + t * 30,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: child,
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: SizedBox(
                      height: 60,
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black.withOpacity(0.9),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(color: Colors.red, width: 2),
                          ),
                        ),
                        onPressed: () async {
                          // Stop all sounds before navigating
                          await _stopAllSounds();

                          if (!mounted) return;

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CameraWishScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "MAKE A WISH",
                          style: TextStyle(
                            fontSize: 18,
                            letterSpacing: 4,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    horrorPlayer.dispose();
    whisperPlayer.dispose();
    heartbeatPlayer.dispose();
    endPlayer.dispose();

    _pulseController.dispose();
    _flickerController.dispose();

    super.dispose();
  }
}

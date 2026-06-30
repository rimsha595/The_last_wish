import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../services/timer_service.dart';
import 'home_screen.dart';

class LockScreen extends StatefulWidget {
  final DateTime startTime;

  const LockScreen({super.key, required this.startTime});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  late Duration remaining;
  Timer? timer;
  bool navigated = false;

  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();

    remaining = TimerService.lockDuration;

    _playClockSound();

    _updateTimer();

    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateTimer();
    });
  }

  Future<void> _playClockSound() async {
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.play(AssetSource('sounds/clock.mp3'));
  }

  Future<void> _stopClockSound() async {
    await _audioPlayer.stop();
  }

  Future<void> _updateTimer() async {
    final endTime = widget.startTime.add(TimerService.lockDuration);
    final diff = endTime.difference(DateTime.now());

    if (!mounted) return;

    if (diff.isNegative || diff.inSeconds <= 0) {
      timer?.cancel();

      setState(() {
        remaining = Duration.zero;
      });

      if (!navigated) {
        navigated = true;

        await _stopClockSound();

        await TimerService.clear();

        if (!mounted) return;

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      }

      return;
    }

    setState(() {
      remaining = diff;
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  String format(Duration duration) {
    String two(int value) => value.toString().padLeft(2, '0');

    final hours = two(duration.inHours);
    final minutes = two(duration.inMinutes % 60);
    final seconds = two(duration.inSeconds % 60);

    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock, color: Colors.red, size: 90),
                const SizedBox(height: 25),
                const Text(
                  "CURSE IS ACTIVE",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  "You cannot use the app until the curse ends.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 45),
                Text(
                  format(remaining),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  "Please wait...",
                  style: TextStyle(color: Colors.white60, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

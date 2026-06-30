import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../services/sound_service.dart';
import '../services/storage_service.dart';
import '../services/firebase_service.dart';
import '../services/curse_engine.dart';
import '../services/timer_service.dart';
import 'lock_screen.dart';

class CameraWishScreen extends StatefulWidget {
  const CameraWishScreen({super.key});

  @override
  State<CameraWishScreen> createState() => _CameraWishScreenState();
}

class _CameraWishScreenState extends State<CameraWishScreen> {
  CameraController? controller;

  List<CameraDescription> cameras = [];
  int selectedCameraIndex = 0;

  bool isRecording = false;
  bool showGlitch = false;
  bool showSubmitButton = false; // ⭐ NEW

  Timer? glitchTimer;

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  Future<void> initCamera() async {
    cameras = await availableCameras();

    // By default back camera use hogi
    selectedCameraIndex = cameras.indexWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
    );

    if (selectedCameraIndex == -1) {
      selectedCameraIndex = 0;
    }

    controller = CameraController(
      cameras[selectedCameraIndex],
      ResolutionPreset.high,
      enableAudio: true,
    );

    await controller!.initialize();

    if (!mounted) return;

    setState(() {});
  }

  Future<void> switchCamera() async {
    if (isRecording) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cannot switch camera while recording.")),
      );
      return;
    }

    if (cameras.length < 2) return;

    if (selectedCameraIndex == 0) {
      selectedCameraIndex = 1;
    } else {
      selectedCameraIndex = 0;
    }

    await controller?.dispose();

    controller = CameraController(
      cameras[selectedCameraIndex],
      ResolutionPreset.high,
      enableAudio: true,
    );

    await controller!.initialize();

    if (!mounted) return;

    setState(() {});
  }

  void startGlitch() {
    glitchTimer?.cancel();
    glitchTimer = Timer.periodic(const Duration(milliseconds: 150), (_) {
      if (!mounted) return;
      setState(() => showGlitch = !showGlitch);
    });
  }

  void stopGlitch() {
    glitchTimer?.cancel();
    setState(() => showGlitch = false);
  }

  Future<void> submitWish() async {
    try {
      // Save timer
      await TimerService.saveWishTime();

      if (!mounted) return;

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.warning_rounded, color: Colors.red, size: 80),
                SizedBox(height: 30),
                Text(
                  "YOUR WISH HAS BEEN ACCEPTED",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 15),
                Text(
                  "The curse has begun...\nYou cannot escape.",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 35),
                CircularProgressIndicator(color: Colors.red),
              ],
            ),
          ),
        ),
      );

      // Wait 5 seconds
      await Future.delayed(const Duration(seconds: 5));

      if (!mounted) return;

      // Close dialog
      Navigator.pop(context);

      // Get timer start time
      final startTime = await TimerService.getStartTime();

      // Go to Lock Screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LockScreen(startTime: startTime!)),
      );
    } catch (e) {
      debugPrint("Submit Error: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red, content: Text(e.toString())),
      );
    }
  }

  Future<void> startRecording() async {
    if (controller == null || !controller!.value.isInitialized) return;

    await controller!.startVideoRecording();

    setState(() {
      isRecording = true;
      showSubmitButton = false;
    });

    startGlitch();
    await SoundService.heartbeat();
    await SoundService.whisper();
  }

  Future<void> stopRecording() async {
    try {
      final XFile file = await controller!.stopVideoRecording();

      setState(() {
        isRecording = false;
        showSubmitButton = true;
      });

      stopGlitch();
      await SoundService.stop();

      print("Recording Stopped");

      final url = await StorageService.uploadVideo(file);
      print("Video Uploaded: $url");

      final curseText = CurseEngine.generate();

      await FirestoreService.addWish({
        "wish": "camera_wish",
        "curse": curseText,
        "videoUrl": url,
        "time": FieldValue.serverTimestamp(),
      });

      print("Firestore Saved Successfully");
    } catch (e) {
      print("ERROR: $e");

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  void dispose() {
    glitchTimer?.cancel();
    controller?.dispose();
    SoundService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.red)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(child: CameraPreview(controller!)),

          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(isRecording ? 0.4 : 0.2),
            ),
          ),

          if (showGlitch)
            Positioned.fill(
              child: Container(color: Colors.red.withOpacity(0.2)),
            ),
          Positioned(
            top: 40,
            right: 20,
            child: SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: IconButton(
                  onPressed: isRecording ? null : switchCamera,
                  icon: const Icon(
                    Icons.flip_camera_ios,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
          ),

          /// WARNING TEXT
          if (isRecording)
            const Positioned(
              top: 80,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  "THE WISH IS LISTENING...",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),

          /// BUTTON AREA
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                /// 🎥 RECORD BUTTON
                FloatingActionButton(
                  backgroundColor: isRecording ? Colors.red : Colors.white,
                  onPressed: isRecording ? stopRecording : startRecording,
                  child: Icon(
                    isRecording ? Icons.stop : Icons.videocam,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 15),

                /// 🔥 SUBMIT BUTTON (NEW)
                if (showSubmitButton)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 14,
                      ),
                    ),
                    onPressed: submitWish,
                    child: const Text(
                      "SUBMIT CURSED WISH",
                      style: TextStyle(letterSpacing: 2, color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flappy_bird/Global/constant.dart';
import 'package:flappy_bird/Global/functions.dart';
import 'package:flappy_bird/Layouts/Pages/page_start_screen.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/foundation.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    init(); // Initialize music and settings
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    try {
      if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
        player.pause();
        print("✅ Paused music: App in background");
      } else if (state == AppLifecycleState.resumed && play) {
        player.resume();
        print("✅ Resumed music: App in foreground");
      }
    } catch (e) {
      print("🔥 Error handling lifecycle music: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen()
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _videoController = kIsWeb
        ? VideoPlayerController.networkUrl(Uri.parse('assets/audio/Splash_screen.mp4'))
        : VideoPlayerController.asset('assets/audio/Splash_screen.mp4');

    await _videoController.initialize();
    setState(() {});
    _videoController.play();

    _videoController.addListener(() {
      if (_videoController.value.position >= _videoController.value.duration &&
          !_videoController.value.isPlaying) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => StartScreen()),
        );
      }
    });
  }


  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _videoController.value.isInitialized
          ? AspectRatio(
        aspectRatio: _videoController.value.aspectRatio,
        child: VideoPlayer(_videoController),
      )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
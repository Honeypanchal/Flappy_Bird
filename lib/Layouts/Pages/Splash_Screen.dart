import 'package:flappy_bird/Global/constant.dart';
import 'package:flappy_bird/Global/functions.dart';
import 'package:flappy_bird/Layouts/Pages/page_start_screen.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

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
      home: const Splashscreen(),
    );
  }
}

class Splashscreen extends StatefulWidget {
  const Splashscreen({Key? key}) : super(key: key);

  @override
  _SplashscreenState createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> with WidgetsBindingObserver {
  late VideoPlayerController _controller;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // 🔇 Pause background music during splash
    try {
      player.pause();
      print("✅ Paused music during splash");
    } catch (e) {
      print("🔥 Error pausing game music: $e");
    }

    _controller = VideoPlayerController.asset("assets/audio/Splash_screen.mp4")
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
        _controller.setVolume(1.0); // Keep video volume ON

        // Navigate to StartScreen after video ends
        Future.delayed(
          _controller.value.duration + const Duration(milliseconds: 300),
              () {
            if (!_navigated) {
              _navigated = true;

              // 🔊 Resume game music after splash
              try {
                if (play) {
                  player.resume();
                  print("✅ Resumed music after splash");
                }
              } catch (e) {
                print("🔥 Error resuming game music: $e");
              }

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const StartScreen()),
              );
            }
          },
        );
      }).catchError((e) {
        print("🔥 Error initializing video player: $e");
        // Fallback navigation if video fails
        if (!_navigated) {
          _navigated = true;
          try {
            if (play) {
              player.resume();
              print("✅ Resumed music after video failure");
            }
          } catch (e) {
            print("🔥 Error resuming game music: $e");
          }
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const StartScreen()),
          );
        }
      });

    _controller.setLooping(false);
  }

  @override
  void dispose() {
    _controller.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    try {
      if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
        _controller.pause(); // Pause video during background
        print("✅ Paused splash video: App in background");
      } else if (state == AppLifecycleState.resumed) {
        _controller.play(); // Resume video when foregrounded
        print("✅ Resumed splash video: App in foreground");
      }
    } catch (e) {
      print("🔥 Error handling splash lifecycle: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _controller.value.isInitialized
          ? AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        child: VideoPlayer(_controller),
      )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: Text("Home Screen")),
    );
  }
}
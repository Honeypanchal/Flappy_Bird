// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:flappy_bird/Layouts/Pages/HomePage.dart';
import 'package:flappy_bird/Layouts/Pages/page_game.dart';
import 'package:flappy_bird/Layouts/Widgets/widget_bird.dart';
import 'package:flappy_bird/Resources/strings.dart';
import 'package:flutter/material.dart';
import '../../Global/constant.dart';
import '../../Global/functions.dart';
import '../Widgets/widget_gradient _button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flappy_bird/Database/database.dart';
import 'package:flappy_bird/Layouts/Widgets/audio_manager.dart'; // ✅ Import AudioManager

class StartScreen extends StatefulWidget {
  const StartScreen({Key? key}) : super(key: key);

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> with WidgetsBindingObserver {
  dynamic score;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    init();
    AudioManager.playBackground(); // ✅ Start music initially
  }

  void playMusicIfNotPlaying() {
    AudioManager.playBackground(); // ✅ Play if not already playing
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print("🔄 App resumed — ensure music is playing");
      playMusicIfNotPlaying();
    } else if (state == AppLifecycleState.paused) {
      print("🏠 App paused — pause music");
      AudioManager.pauseBackground();
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: background('flapp_bg1'),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(
                top: size.height > 900 ? size.height * 0.32 : size.height * 0.26,
              ),
              child: Column(
                children: [
                  SizedBox(height: size.height > 900 ? 15 : 10),
                  Image.asset('assets/pics/Get Ready.png'),
                  SizedBox(height: 50),
                ],
              ),
            ),
            SizedBox(height: 10,),
            Bird(yAxis, birdWidth, birdHeight),
            SizedBox(height: size.height > 900 ? 45 : 45),
            _buttons(context),
            SizedBox(height: MediaQuery.of(context).size.height>900?20:10),
            AboutUs(size: size),
          ],
        ),
      ),
    );
  }
}

Column _buttons(BuildContext context) {
  return Column(
    children: [
      GestureDetector(
        onTap: () async {
          try {
            final user = FirebaseAuth.instance.currentUser;

            if (user == null) {
              await FirebaseAuth.instance.signInAnonymously();
            }

            final uid = FirebaseAuth.instance.currentUser!.uid;
            final snapshot = await FirebaseDatabase.instance.ref("users/$uid/name").get();

            if (!snapshot.exists || snapshot.value.toString().isEmpty) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => GamePage()),
              );
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error navigating to game: $e")),
            );
          }
        },
        child: Container(
          width: 278,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.black),
            gradient: const LinearGradient(
              colors: [Colors.white, Color.fromRGBO(130, 208, 237, 1)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.play_arrow,
            size: 55,
            color: Colors.green,
            shadows: [
              BoxShadow(
                blurRadius: 4,
                offset: Offset(0, 4),
                color: Color.fromRGBO(0, 0, 0, 0.25),
              ),
            ],
          ),
        ),
      ),
      SizedBox(height: MediaQuery.of(context).size.height>900?25:20),
      Button(
        buttonType: "icon",
        width: 278,
        height: 60,
        icon: const Icon(
          Icons.settings,
          size: 40,
          color: Colors.black,
          shadows: [
            BoxShadow(
              color: Color.fromRGBO(255, 255, 255, 0.2),
              offset: Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        page: Str.settings,
      ),
    ],
  );
}

class AboutUs extends StatelessWidget {
  final Size size;
  AboutUs({required this.size, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => dialog(context),
        );
      },
      child: Text(
        'ABOUT GAME',
        style: TextStyle(
          fontSize: 26,
          fontFamily: 'JungleAdventurer',
          fontWeight: FontWeight.w400,
          color: Colors.white,
        ),
      ),
    );
  }
}

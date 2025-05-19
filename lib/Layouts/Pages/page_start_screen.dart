// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_const_constructors_in_immutables
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
class StartScreen extends StatefulWidget {
  const StartScreen({Key? key}) : super(key: key);

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  dynamic score;
 // final myBox = Hive.box('user');

  @override
  void initState() {
    // Todo : initialize the database  <---
    super.initState();

    init();
   // loadBoxValues();
  }
  // void loadBoxValues() async {
  //   var value = await read("score"); // Use your own read()
  //   setState(() {
  //     score = value;
  //   });
  // }

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
            // Flappy bird text
            Container(
                margin: EdgeInsets.only(top: size.height * 0.25),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/pics/Flappy Bird.png',
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Image.asset('assets/pics/Get Ready.png'),
                    SizedBox(
                      height: 50,
                    ),
                  ],
                )),
            Bird(yAxis, birdWidth, birdHeight),
            SizedBox(
              height: 25,
            ),
            _buttons(context),
            AboutUs(
              size: size,
            )
          ],
        ),
      ),
    );
  }
}

// three buttons
Column _buttons(BuildContext context) {
  return Column(
    children: [
      GestureDetector(
        onTap: () async {
          try {
            final user = FirebaseAuth.instance.currentUser;

            if (user == null) {
              print("No user found, signing in anonymously...");
              await FirebaseAuth.instance.signInAnonymously();
            }

            final uid = FirebaseAuth.instance.currentUser!.uid;
            final snapshot = await FirebaseDatabase.instance.ref("users/$uid/name").get();

            if (!snapshot.exists || snapshot.value.toString().isEmpty) {
              print("No nickname found, navigating to HomePage...");
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            } else {
              print("Nickname exists, navigating to GamePage...");
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) =>  GamePage()),
              );
            }
          } catch (e) {
            print("🔥 Navigation error: $e");
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
      const SizedBox(height: 20),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Button(
            buttonType: "icon",
            height: 60,
            width: 110,
            icon: const Icon(
              Icons.settings,
              shadows: [
                BoxShadow(
                  color: Color.fromRGBO(255, 255, 255, 0.2),
                  offset: Offset(0, -2),
                  blurRadius: 4,
                  spreadRadius: 0,
                ),
              ],
              size: 40,
              color: Colors.black,
            ),
            page: Str.settings,
          ),
          Button(
            buttonType: "icon",
            height: 60,
            width: 110,
            icon: const Icon(
              Icons.star,
              size: 40,
              color: Color.fromRGBO(255, 0, 0, 1),
              shadows: [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.25),
                  blurRadius: 4,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            page: Str.rateUs,
          ),
        ],
      ),
    ],
  );
}
class AboutUs extends StatelessWidget {
  final Size size;

  AboutUs({required this.size, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                return dialog(context);
              },
            );
          },
          child: Text(
            'About Us',
            style: TextStyle(
                fontSize: 26,
                fontFamily: 'JungleAdventurer',
                fontWeight: FontWeight.w400,
                color: Colors.white),
          )),
    );
  }
}

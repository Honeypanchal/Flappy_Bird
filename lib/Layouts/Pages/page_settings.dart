// ignore_for_file: prefer_const_constructors, sized_box_for_whitespace
// ignore_for_file: prefer_const_literals_to_create_immutables, avoid_unnecessary_containers

import 'package:flappy_bird/Layouts/Pages/page_start_screen.dart';
import 'package:flappy_bird/Layouts/Widgets/widget_difficulty_settings.dart';
import 'package:flappy_bird/Layouts/Widgets/widget_music_settings.dart';
import 'package:flappy_bird/Resources/strings.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../Global/functions.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  // Use a generic GlobalKey for DifficultySettings state
  final GlobalKey<State<StatefulWidget>> _difficultySettingsKey = GlobalKey<State<StatefulWidget>>();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: background(Str.image),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: size.height * 0.06, left: 12, bottom: 10),
              alignment: Alignment(-1, 0),
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back, size: 40, color: Colors.white),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height>900? 60 :20,),
            Container(
              width: size.width * 0.9,
              height: MediaQuery.of(context).size.height>900? size.height*0.5 : size.height * 0.6,
              margin: EdgeInsets.symmetric(horizontal: 16),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      "Setting",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 40,
                        fontFamily: 'JungleAdventurer',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 15),
                    // BirdSettings(),
                    // ThemesSettings(),
                    MusicSettings(),
                    SizedBox(height: 15),
                    DifficultySettings(key: _difficultySettingsKey),
                    SizedBox(height: 15),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromRGBO(89, 216, 224, 1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () async {
                        try {
                          final user = FirebaseAuth.instance.currentUser;
                          if (user == null) {
                            print("🔥 No user signed in");
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Please sign in to save settings")),
                            );
                            return;
                          }

                          // Get selected difficulty from DifficultySettings
                          final difficultyState = _difficultySettingsKey.currentState;
                          if (difficultyState != null) {
                            // Access selectedDifficulty dynamically with fallback
                            final selectedDifficulty = (difficultyState as dynamic).selectedDifficulty ?? 'easy';
                            // Save to Firebase
                            final ref = FirebaseDatabase.instance.ref("users/${user.uid}");
                            await ref.update({
                              "difficulty_mode": selectedDifficulty,
                            });
                            print("✅ Difficulty mode saved to Firebase: $selectedDifficulty");
                          } else {
                            print("🔥 DifficultySettings state not found");
                          }

                          // Navigate to StartScreen
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const StartScreen()),
                          );
                        } catch (e) {
                          print("🔥 Error saving difficulty to Firebase: $e");
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Error saving settings: $e")),
                          );
                        }
                      },
                      child: Text(
                        "Apply",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'JungleAdventurer',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
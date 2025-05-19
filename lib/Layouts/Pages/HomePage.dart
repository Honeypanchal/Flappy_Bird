import 'package:flappy_bird/Layouts/Pages/page_game.dart';
import 'package:flappy_bird/Layouts/Pages/page_start_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _nicknameController = TextEditingController();

  Future<void> _saveNicknameAndProceed() async {
    final nickname = _nicknameController.text.trim();

    if (nickname.isEmpty) {
      print("Nickname is empty, not proceeding.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a nickname")),
      );
      return;
    }

    print("Nickname entered: $nickname");

    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print("No user found, signing in anonymously...");
      try {
        UserCredential result = await FirebaseAuth.instance.signInAnonymously();
        user = result.user;
      } catch (e) {
        print("🔥 Anonymous sign-in error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Sign-in failed: $e")),
        );
        return;
      }
    } else {
      print("User already signed in: ${user.uid}");
    }

    if (user != null) {
      try {
        // Save to Firebase
        final ref = FirebaseDatabase.instance.ref("users/${user.uid}");
        await ref.set({
          "name": nickname,
          "createdAt": DateTime.now().toIso8601String(),
          "uid": user.uid,
          "difficulty_mode" : "easy",
          "rating": 0,


        });
        print("Data saved to Firebase");

        // Save to Hive (optional, proceed even if it fails)
        try {
          if (!Hive.isBoxOpen('user')) {
            await Hive.openBox('user');
            print("✅ Opened 'user' box in HomePage");
          }
          final box = Hive.box('user');
          await box.put('nickname', nickname);
          print("Nickname saved locally");
        } catch (e) {
          print("🔥 Hive error: $e");
          // Continue to navigation even if Hive fails, since Firebase succeeded
        }

        // Navigate to StartScreen
        print("Navigating to StartScreen...");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => GamePage()),
        );
      } catch (e) {
        print("🔥 Error saving data: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving data: $e")),
        );
      }
    } else {
      print("Failed to sign in user.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to sign in user")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/pics/flapp_bg1.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 100),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/pics/Homepage_image.png'),
                  const SizedBox(height: 40),
                  Container(
                    width: 251,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(0, 0, 0, 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: TextField(
                      controller: _nicknameController,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 26,
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'JungleAdventurer',
                      ),
                      decoration: const InputDecoration(
                        hintText: 'NICKNAME',
                        hintStyle: TextStyle(
                          fontSize: 26,
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'JungleAdventurer',
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      cursorColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 50),
                  GestureDetector(
                    onTap: _saveNicknameAndProceed,
                    child: Image.asset('assets/pics/play_button.png'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
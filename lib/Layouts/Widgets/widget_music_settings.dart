// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../../Global/constant.dart';
import '../../Layouts/Widgets//audio_manager.dart'; // ✅ Import AudioManager

class MusicSettings extends StatefulWidget {
  const MusicSettings({Key? key}) : super(key: key);

  @override
  State<MusicSettings> createState() => _MusicSettingsState();
}

class _MusicSettingsState extends State<MusicSettings> with WidgetsBindingObserver {
  bool isPlaying = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    checkAudio();
  }

  Future<void> checkAudio() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final snapshot = await FirebaseDatabase.instance.ref("users/${user.uid}/audio").get();
        setState(() {
          isPlaying = snapshot.exists ? snapshot.value as bool : true;
        });
        if (isPlaying) {
          await AudioManager.playBackground();
        } else {
          await AudioManager.pauseBackground();
        }
        print("✅ Loaded audio setting from Firebase: $isPlaying");
      } catch (e) {
        print("🔥 Error loading audio: $e");
        setState(() => isPlaying = true);
        await AudioManager.playBackground();
      }
    } else {
      setState(() => isPlaying = true);
      await AudioManager.playBackground();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    debugPrint("📱 App lifecycle changed: $state");

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      await AudioManager.pauseBackground();
      debugPrint("⏸️ Music paused via AudioManager");
    } else if (state == AppLifecycleState.resumed && isPlaying) {
      await AudioManager.playBackground(); // Ensure it replays with loop
      debugPrint("▶️ Music resumed via AudioManager");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            child: Text(
              "Music",
              style: TextStyle(
                color: Colors.black,
                fontSize: 26,
                fontWeight: FontWeight.w400,
                fontFamily: 'JungleAdventurer',
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () async {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    await FirebaseDatabase.instance.ref("users/${user.uid}/audio").set(true);
                  }
                  await AudioManager.playBackground();
                  setState(() => isPlaying = true);
                  print("✅ Music turned ON");
                },
                child: Image.asset('assets/pics/music_on.png'),
              ),
              GestureDetector(
                onTap: () async {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    await FirebaseDatabase.instance.ref("users/${user.uid}/audio").set(false);
                  }
                  await AudioManager.pauseBackground();
                  setState(() => isPlaying = false);
                  print("✅ Music turned OFF");
                },
                child: Image.asset('assets/pics/music_off.png'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

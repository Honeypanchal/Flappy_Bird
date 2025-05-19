// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../../Global/constant.dart';
import '../../Global/functions.dart';

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

  void checkAudio() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final snapshot = await FirebaseDatabase.instance.ref("users/${user.uid}/audio").get();
        setState(() {
          isPlaying = snapshot.exists ? snapshot.value as bool : true;
          play = isPlaying; // Sync global play variable
        });
        if (isPlaying) {
          await player.resume();
        } else {
          await player.pause();
        }
        print("✅ Loaded audio setting from Firebase: $isPlaying");
      } catch (e) {
        print("🔥 Error loading audio from Firebase: $e");
        setState(() {
          isPlaying = true; // Default to true on error
          play = isPlaying;
        });
        await player.resume();
      }
    } else {
      setState(() {
        isPlaying = true; // Default to true if no user
        play = isPlaying;
      });
      await player.resume();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      player.pause();
    } else if (state == AppLifecycleState.resumed && isPlaying) {
      player.resume();
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
                  await player.resume();
                  setState(() {
                    isPlaying = true;
                    play = true;
                  });
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
                  await player.pause();
                  setState(() {
                    isPlaying = false;
                    play = false;
                  });
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
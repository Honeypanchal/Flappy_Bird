// ignore_for_file: prefer_const_constructors
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flappy_bird/Resources/strings.dart';
import 'package:flutter/material.dart';
import '../Global/constant.dart';

Text myText(String txt, Color? color, double size) {
  return Text(
    txt,
    style: TextStyle(
      fontSize: size,
      fontFamily: "JungleAdventurer",
      color: color,
    ),
  );
}

Widget gameButton(VoidCallback? onPress, String txt, Color color, {bool isSelected = false, Color? highlightColor}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 2.0),
    child: SizedBox(
      width: 95,
      height: 45,
      child: ElevatedButton(
        onPressed: onPress,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shadowColor: isSelected ? Colors.black : Colors.transparent, // Glow effect
          elevation: isSelected ? 5 : 0, // Elevation for glow
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: isSelected && highlightColor != null
                ? BorderSide(color: highlightColor, width: 3)
                : BorderSide.none, // Use highlightColor for border if selected
          ),

        ),
        child: Text(
          txt,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontFamily: 'JungleAdventurer',
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    ),
  );
}
BoxDecoration frame() {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(10),
    border: Border.all(color: Colors.black, width: 2),
    color: Colors.white54,
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.6),
        blurRadius: 1.0,
        offset: Offset(5, 5),
      )
    ],
  );
}

BoxDecoration background(String y) {
  return BoxDecoration(
    image: DecorationImage(
      image: AssetImage("assets/pics/flapp_bg1.png"),
      fit: BoxFit.fill,
    ),
  );
}

AlertDialog dialog(BuildContext context) {
  return AlertDialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    actionsPadding: EdgeInsets.only(right: 24, bottom: 25),
    title: myText("About Flappy Bird", Colors.black, 28),
    content: Text(
      Str.about,
      style: TextStyle(
        fontFamily: "JungleAdventurer",
        fontWeight: FontWeight.w400,
        fontSize: 20,
      ),
    ),
    actions: [
      gameButton(() {
        Navigator.pop(context);
      }, "Okay", Color.fromRGBO(180, 40, 0, 1), isSelected: false), // Pass isSelected as false
    ],
  );
}

Future<void> init() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final ref = FirebaseDatabase.instance.ref("users/${user.uid}");
    try {
      // Load audio setting
      final audioSnapshot = await ref.child("audio").get();
      if (audioSnapshot.exists) {
        play = audioSnapshot.value as bool? ?? true;
      } else {
        await ref.child("audio").set(play); // Default to true
      }

      // Load other settings (replace Database/database.dart)
      final scoreSnapshot = await ref.child("best_score").get();
      if (scoreSnapshot.exists) {
        topScore = scoreSnapshot.value as int? ?? 0;
      } else {
        await ref.child("best_score").set(topScore);
      }

      final backgroundSnapshot = await ref.child("background").get();
      if (backgroundSnapshot.exists) {
        Str.image = backgroundSnapshot.value as String? ?? Str.image;
      } else {
        await ref.child("background").set(Str.image);
      }

      final birdSnapshot = await ref.child("bird").get();
      if (birdSnapshot.exists) {
        Str.bird = birdSnapshot.value as String? ?? Str.bird;
      } else {
        await ref.child("bird").set(Str.bird);
      }

      final levelSnapshot = await ref.child("level").get();
      if (levelSnapshot.exists) {
        barrierMovement = (levelSnapshot.value as num?)?.toDouble() ?? barrierMovement;
      } else {
        await ref.child("level").set(barrierMovement);
      }

      print("✅ Initialized settings from Firebase: audio=$play, topScore=$topScore");
    } catch (e) {
      print("🔥 Error initializing settings from Firebase: $e");
    }
  }

  // Initialize player
  try {
    await player.setSource(AssetSource("audio/Flappy_Bird.mp3"));
    await player.setReleaseMode(ReleaseMode.loop);
    if (play) {
      await player.resume();
    } else {
      await player.stop();
    }
  } catch (e) {
    print("🔥 Error initializing audio player: $e");
  }
}

void navigate(context, navigate) {
  switch (navigate) {
    case Str.gamePage:
      Navigator.pushNamed(context, Str.gamePage);
      break;
    case Str.settings:
      Navigator.pushNamed(context, Str.settings);
      break;
    case Str.rateUs:
      Navigator.pushNamed(context, Str.rateUs);
      break;
  }
}
// ignore_for_file: prefer_const_constructors, prefer_const_constructors_in_immutables, avoid_unnecessary_containers, avoid_print
import 'dart:async';
import 'package:flappy_bird/Layouts/Pages/page_start_screen.dart';
import 'package:flappy_bird/Layouts/Widgets/widget_bird.dart';
import 'package:flappy_bird/Layouts/Widgets/widget_barrier.dart';
import 'package:flappy_bird/Layouts/Widgets/widget_cover.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../Global/constant.dart';
import '../../Global/functions.dart';
import '../../Resources/strings.dart';

class GamePage extends StatefulWidget {
  GamePage({Key? key}) : super(key: key);
  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  double _barrierMovement = 0.05; // Default to Easy
  bool _barrier0Passed = false; // Track if barrier 0 has been passed
  bool _barrier1Passed = false; // Track if barrier 1 has been passed

  @override
  void initState() {
    super.initState();
    loadDifficultyFromFirebase();
    loadBestScoreFromFirebase();
  }

  void loadDifficultyFromFirebase() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final snapshot = await FirebaseDatabase.instance.ref("users/${user.uid}/difficulty_mode").get();
        if (snapshot.exists) {
          final difficulty = snapshot.value as String;
          setState(() {
            switch (difficulty) {
              case 'easy':
                _barrierMovement = 0.05;
                break;
              case 'medium':
                _barrierMovement = 0.08;
                break;
              case 'hard':
                _barrierMovement = 0.1;
                break;
              default:
                _barrierMovement = 0.05; // Fallback to easy
            }
          });
          print("✅ Loaded difficulty from Firebase: $difficulty, barrierMovement: $_barrierMovement");
        }
      }
    } catch (e) {
      print("🔥 Error loading difficulty from Firebase: $e");
    }
  }

  void loadBestScoreFromFirebase() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final snapshot = await FirebaseDatabase.instance.ref("users/${user.uid}/best_score").get();
        if (snapshot.exists) {
          setState(() {
            topScore = snapshot.value as int? ?? 0;
          });
          print("✅ Loaded best score from Firebase: $topScore");
        }
      }
    } catch (e) {
      print("🔥 Error loading best score from Firebase: $e");
    }
  }

  void saveBestScoreToFirebase() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && score > topScore) {
        setState(() {
          topScore = score;
        });
        await FirebaseDatabase.instance.ref("users/${user.uid}/best_score").set(topScore);
        print("✅ Best score updated in Firebase: $topScore");
      }
    } catch (e) {
      print("🔥 Error saving best score to Firebase: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: gameHasStarted ? jump : startGame,
      child: Scaffold(
        body: Column(children: [
          Expanded(
            flex: 3,
            child: Container(
              decoration: background(Str.image),
              child: Stack(
                children: [
                  Bird(yAxis, birdWidth, birdHeight),
                  Barrier(barrierHeight[0][0], barrierWidth, barrierX[0], true),
                  Barrier(barrierHeight[0][1], barrierWidth, barrierX[0], false),
                  Barrier(barrierHeight[1][0], barrierWidth, barrierX[1], true),
                  Barrier(barrierHeight[1][1], barrierWidth, barrierX[1], false),
                  if (!gameHasStarted) ...[
                    Positioned(
                      right: 20,
                      bottom: 100,
                      child: Image.asset(
                        'assets/pics/piller_straight.png',
                        width: 80,
                      ),
                    ),
                    Positioned(
                      right: 20,
                      child: Image.asset(
                        'assets/pics/piller_opposite.png',
                        width: 80,
                      ),
                    ),
                  ],
                  Positioned(
                    bottom: 1,
                    right: 1,
                    left: 1,
                    child: Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            "Score : $score",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontFamily: "Magic4",
                            ),
                          ),
                          Text(
                            "Best : $topScore",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontFamily: "Magic4",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }

  void jump() {
    setState(() {
      time = 0;
      initialHeight = yAxis;
    });
  }

  void startGame() {
    gameHasStarted = true;
    Timer.periodic(Duration(milliseconds: 35), (timer) {
      height = gravity * time * time + velocity * time;
      setState(() {
        yAxis = initialHeight - height;
      });
      setState(() {
        if (barrierX[0] < screenEnd) {
          barrierX[0] += screenStart;
          _barrier0Passed = false; // Reset when barrier resets
        } else {
          barrierX[0] -= _barrierMovement;
          // Increment score when bird passes barrier 0
          if (barrierX[0] < birdWidth && !_barrier0Passed) {
            setState(() {
              score++;
              _barrier0Passed = true;
            });
          }
        }
      });
      setState(() {
        if (barrierX[1] < screenEnd) {
          barrierX[1] += screenStart;
          _barrier1Passed = false; // Reset when barrier resets
        } else {
          barrierX[1] -= _barrierMovement;
          // Increment score when bird passes barrier 1
          if (barrierX[1] < birdWidth && !_barrier1Passed) {
            setState(() {
              score++;
              _barrier1Passed = true;
            });
          }
        }
      });
      if (birdIsDead()) {
        timer.cancel();
        saveBestScoreToFirebase();
        _showDialog();
      }
      time += 0.032;
    });
  }

  bool birdIsDead() {
    if (yAxis > 1.26 || yAxis < -1.1) {
      return true;
    }
    for (int i = 0; i < barrierX.length; i++) {
      if (barrierX[i] <= birdWidth &&
          (barrierX[i] + barrierWidth) >= birdWidth &&
          (yAxis <= -1 + barrierHeight[i][0] || yAxis + birdHeight >= 1 - barrierHeight[i][1])) {
        return true;
      }
    }
    return false;
  }

  void resetGame() {
    saveBestScoreToFirebase(); // Save best score before resetting
    Navigator.pop(context);
    setState(() {
      yAxis = 0;
      gameHasStarted = false;
      time = 0;
      score = 0;
      initialHeight = yAxis;
      barrierX[0] = 2;
      barrierX[1] = 3.4;
      _barrier0Passed = false;
      _barrier1Passed = false;
    });
  }

  void _showDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text(
            "...Opps",
            style: TextStyle(
              color: Color.fromRGBO(181, 50, 0, 1),
              fontFamily: 'JungleAdventurer',
              fontSize: 40,
              fontWeight: FontWeight.w400,
            ),
          ),
          contentPadding: EdgeInsets.zero,
          content: SizedBox(
            width: 324,
            height: 210,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Image.asset('assets/pics/oops_bird.png'),
                ),
              ],
            ),
          ),
          actionsPadding: EdgeInsets.only(right: 8, bottom: 15,top: 15),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(126, 126, 126, 1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                resetGame();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const StartScreen()),
                );
              },
              child: Text(
                "Exit",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontFamily: 'JungleAdventurer',
                  fontSize: 28,
                  color: Colors.white,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(119, 180, 0, 1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                resetGame();
              },
              child: Text(
                'Try Again',
                style: TextStyle(
                  fontSize: 28,
                  fontFamily: 'JungleAdventurer',
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
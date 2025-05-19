// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import '../../Global/functions.dart';

class DifficultySettings extends StatefulWidget {
  const DifficultySettings({Key? key}) : super(key: key);

  @override
  State<DifficultySettings> createState() => _DifficultySettingsState();
}

class _DifficultySettingsState extends State<DifficultySettings> {
  String _selectedDifficulty = 'easy'; // Default difficulty
  double _barrierMovement = 0.05; // Default to Easy

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.026),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            child: Text(
              "Difficulty",
              style: TextStyle(
                color: Colors.black,
                fontSize: 26,
                fontWeight: FontWeight.w400,
                fontFamily: 'JungleAdventurer',
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              gameButton(() {
                setState(() {
                  _selectedDifficulty = 'easy';
                  _barrierMovement = 0.05;
                });
                print("Selected difficulty: Easy, barrierMovement: $_barrierMovement");
              }, "Easy", Color.fromRGBO(119, 180, 0, 1)),
              gameButton(() {
                setState(() {
                  _selectedDifficulty = 'medium';
                  _barrierMovement = 0.08;
                });
                print("Selected difficulty: Medium, barrierMovement: $_barrierMovement");
              }, "Medium", Color.fromRGBO(244, 198, 43, 1)),
              gameButton(() {
                setState(() {
                  _selectedDifficulty = 'hard';
                  _barrierMovement = 0.1;
                });
                print("Selected difficulty: Hard, barrierMovement: $_barrierMovement");
              }, "Hard", Color.fromRGBO(217, 106, 109, 1)),
            ],
          ),
        ],
      ),
    );
  }

  // Getter to access selected difficulty and barrier movement
  String get selectedDifficulty => _selectedDifficulty;
  double get barrierMovement => _barrierMovement;
}
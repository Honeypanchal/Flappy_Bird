// ignore_for_file: prefer_const_constructors, prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';
import 'package:rating_dialog/rating_dialog.dart';
import 'package:share_plus/share_plus.dart';
import '../../Global/functions.dart';
import '../../Resources/strings.dart';

class RateUs extends StatelessWidget {
  RateUs({Key? key}) : super(key: key);
  final double rating = 4.0;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        body: Container(

            width: size.width,
            height: size.height,
            decoration: background(Str.image),
            child: Stack(
              children: [
                Positioned(
                  top: MediaQuery.of(context).size.height>900?115:70,
                    left: MediaQuery.of(context).size.width>400?60:40,

                    child: GestureDetector(
                        onTap:(){
                          Navigator.pop(context);
                        },child: Icon(Icons.arrow_back,color: Colors.white,size: 40,))
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    RatingDialog(
                      title:
                      Text("Rate Us                   ",textAlign: TextAlign.left,
                          style: TextStyle(color:  Colors.blueAccent,
                              fontSize: 26,
                            fontWeight: FontWeight.w400,

                         fontFamily: 'JungleAdventurer')),
                       image: Image.asset(
                        'assets/pics/rateus.png',
                        height: 118,
                        width: 118,
                      ),
                      submitButtonText: 'Submit',
                      onSubmitted: (response) {
                        // handle response
                      },
                    ),


                  ],
                ),
              ],
            ),
        ),
    );
  }
}
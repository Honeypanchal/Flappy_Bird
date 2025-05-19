import 'package:flutter/material.dart';

class Guestloginpopup extends StatefulWidget {
  const Guestloginpopup({super.key});

  @override
  State<Guestloginpopup> createState() => _GuestloginpopupState();
}

class _GuestloginpopupState extends State<Guestloginpopup> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: AlertDialog(
        title: TextField(

        ),
      ),
    );
  }
}

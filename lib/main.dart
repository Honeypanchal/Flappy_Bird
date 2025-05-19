import 'package:flappy_bird/Layouts/Pages/Splash_Screen.dart';
import 'package:flappy_bird/Routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'Layouts/Pages/page_start_screen.dart';
import 'Resources/strings.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyA1XNkETcs-GcCjKCJDgn3O-b_N0eWgZ0c",
            authDomain: "flappyybird-b98e7.firebaseapp.com",
            databaseURL: "https://flappyybird-b98e7-default-rtdb.firebaseio.com",
            projectId: "flappyybird-b98e7",
            storageBucket: "flappyybird-b98e7.firebasestorage.app",
            messagingSenderId: "596503139566",
            appId: "1:596503139566:web:e031ae14fa413fe8fb4fff",
            measurementId: "G-QTNNXLJJSY"
        ),
      );
      print("✅ Firebase initialized!");
    }

    // Initialize Hive with path
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      await Hive.initFlutter(appDocDir.path);
      print("✅ Hive initialized with path: ${appDocDir.path}");

      // Clear previous box to avoid corruption (optional, remove after first run)
      await Hive.deleteBoxFromDisk('user');
      print("✅ Cleared 'user' box to ensure clean state");

      // Open the 'user' box
      if (!Hive.isBoxOpen('user')) {
        await Hive.openBox('user');
        print("✅ Hive 'user' box opened!");
      } else {
        print("✅ Hive 'user' box already open!");
      }
    } catch (e) {
      print("🔥 Hive initialization error: $e");
      // Proceed without Hive if initialization fails (optional fallback)
    }

  } catch (e) {
    print("🔥 General initialization error: $e");
  }

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      home:  Splashscreen(),
      debugShowCheckedModeBanner: false,
      initialRoute: Str.home,
      onGenerateRoute: AppRoute().generateRoute,
    );
  }
}
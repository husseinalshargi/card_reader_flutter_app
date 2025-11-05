import 'package:card_reader_app/Screens/auth_screen.dart';
import 'package:card_reader_app/Screens/background_screen.dart';
import 'package:card_reader_app/Screens/home_screen.dart';
import 'package:card_reader_app/Screens/loadingScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:card_reader_app/Widgets/auth_icons.dart';
import 'package:flutter/material.dart';

class CurrentScreen extends StatefulWidget {
  const CurrentScreen({super.key});

  @override
  State<CurrentScreen> createState() {
    return _CurrentScreenState();
  }
}

class _CurrentScreenState extends State<CurrentScreen> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        //show a loading screen until the user connect to his account
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const BackgroundScreen(scaffoldWidget: Loadingscreen());
        }

        if (snapshot.hasData) {
          return const BackgroundScreen(scaffoldWidget: HomeScreen());
        }

        return const BackgroundScreen(scaffoldWidget: AuthScreen());
      },
    );
  }
}

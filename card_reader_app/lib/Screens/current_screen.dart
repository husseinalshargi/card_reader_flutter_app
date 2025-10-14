import 'package:card_reader_app/Screens/background_screen.dart';
import 'package:card_reader_app/Screens/splash_screen.dart';
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
    return BackgroundScreen(scaffoldWidget: SplashScreen());
  }
}

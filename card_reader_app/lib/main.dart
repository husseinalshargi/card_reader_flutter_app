import 'package:card_reader_app/Data/Enums/global_enums.dart';
import 'package:card_reader_app/Screens/current_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';

var lightScheme = ColorScheme.fromSeed(
  seedColor: const Color.fromARGB(255, 255, 0, 0),
  brightness: Brightness.light,

  //arranged
  surface: const Color.fromARGB(255, 255, 230, 230),
  onPrimary: const Color.fromARGB(255, 255, 184, 184),
  onSecondary: const Color.fromARGB(255, 255, 138, 138),
  tertiary: const Color.fromARGB(255, 255, 92, 92),
  inverseSurface: const Color.fromARGB(255, 255, 46, 46),
  error: const Color.fromARGB(255, 255, 0, 0),
  onInverseSurface: const Color.fromARGB(255, 209, 0, 0),
  onTertiary: const Color.fromARGB(255, 163, 0, 0),
  secondary: const Color.fromARGB(255, 117, 0, 0),
  primary: const Color.fromARGB(255, 71, 0, 0),
  onSurface: const Color.fromARGB(255, 26, 0, 0),
  scrim: const Color.fromARGB(255, 255, 131, 131),
);

// --color-50: #FFE6E6;  rgb(255 230 230);
// --color-100: #FFB8B8; rgb(255 184 184);
// --color-200: #FF8A8A; rgb(255 138 138);
// --color-300: #FF5C5C; rgb(255 92 92);
// --color-400: #FF2E2E; rgb(255 46 46);
// --color-500: #FF0000; rgb(255 0 0);
// --color-600: #D10000; rgb(209 0 0);
// --color-700: #A30000; rgb(163 0 0);
// --color-800: #750000; rgb(117 0 0);
// --color-900: #470000; rgb(71 0 0);
// --color-950: #1A0000; rgb(26 0 0);
// FF8383

//get the current user signed in (it will be null if there isn't any user signed in)
User? currentUser = FirebaseAuth.instance.currentUser;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  //get app the settings (keep me signed in until now)
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  // ensure that the data is updated
  await prefs.reload();

  // if the key isn't there or the user set keep signed in to false and there is a user signed in then log him out before init the app
  if ((!prefs.containsKey("KeepSignedIn") ||
          (prefs.containsKey("KeepSignedIn") &&
              prefs.getBool("KeepSignedIn") == false)) &&
      currentUser != null) {
    //log out based on the type of signing in
    final String? signInMethod = prefs.getString("SignInMethod");

    await FirebaseAuth.instance.signOut();
    if (signInMethod == AuthMethods.google.name) {
      await GoogleSignIn.instance.signOut();
    }
    if (signInMethod == AuthMethods.facebook.name) {
      await FacebookAuth.instance.logOut();
    }
  }

  runApp(
    MaterialApp(
      home: const CurrentScreen(),
      theme: ThemeData(colorScheme: lightScheme, fontFamily: "ProtestStrike"),
      debugShowCheckedModeBanner: false,
    ),
  );
}

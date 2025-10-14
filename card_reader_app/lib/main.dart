import 'package:card_reader_app/Screens/current_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

var lightScheme = ColorScheme.fromSeed(
  seedColor: Color.fromARGB(255, 255, 0, 0),
  brightness: Brightness.light,

  //arranged
  surface: Color.fromARGB(255, 255, 230, 230),
  onPrimary: Color.fromARGB(255, 255, 184, 184),
  onSecondary: Color.fromARGB(255, 255, 138, 138),
  tertiary: Color.fromARGB(255, 255, 92, 92),
  inverseSurface: Color.fromARGB(255, 255, 46, 46),
  error: Color.fromARGB(255, 255, 0, 0),
  onInverseSurface: Color.fromARGB(255, 209, 0, 0),
  onTertiary: Color.fromARGB(255, 163, 0, 0),
  secondary: Color.fromARGB(255, 117, 0, 0),
  primary: Color.fromARGB(255, 71, 0, 0),
  onSurface: Color.fromARGB(255, 26, 0, 0),
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
// f3efec
void main() {
  runApp(
    MaterialApp(
      home: CurrentScreen(),
      theme: ThemeData(
        colorScheme: lightScheme,
        textTheme: GoogleFonts.protestStrikeTextTheme(),
      ),
      debugShowCheckedModeBanner: false,
    ),
  );
}

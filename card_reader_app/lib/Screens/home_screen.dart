import 'package:card_reader_app/Screens/auth_screen.dart';
import 'package:card_reader_app/Screens/background_screen.dart';
import 'package:card_reader_app/Screens/validate_email_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

//get the current user signed in (it will be null if there isn't any user signed in, we could use it to show the auth screen)
User? currentUser = FirebaseAuth.instance.currentUser;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _checkIfUserValidated(BuildContext context) async {
    await currentUser!.reload();
    // check if (not verified)
    if (!currentUser!.emailVerified) {
      await Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => PopScope(
            canPop: false, //user can't go to the home page (hit back button)
            child: BackgroundScreen(
              scaffoldWidget: ValidateEmailScreen(currentUser: currentUser),
            ),
          ),
        ),
      );
    }
  }

  void _checkIfUserAuthenticated(BuildContext context) {
    if (currentUser == null) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const AuthScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final topMargin = MediaQuery.of(context).padding.top;
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
    final colorScheme = Theme.of(context).colorScheme;

    // make sure if the user isn't logged in (he logged out) return the auth page (replace this page). it wont be needed as we have StreamBuilder but just in case
    _checkIfUserAuthenticated(context);

    //check if the user has a valid email (he validate it)
    _checkIfUserValidated(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          width: width,
          height: height - topMargin,
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: Colors.transparent,
            body: Container(
              alignment: Alignment.bottomCenter,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text("Home"),
                  TextButton.icon(
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                    },
                    label: const Text("Log Out"),
                    icon: const FaIcon(FontAwesomeIcons.arrowRightFromBracket),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

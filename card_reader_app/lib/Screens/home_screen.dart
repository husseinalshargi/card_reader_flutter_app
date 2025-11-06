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
    final bottomMargin = MediaQuery.of(context).padding.bottom;
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
    final colorScheme = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme;

    //create a virable to get the height to place a line
    final appbar = AppBar(
      backgroundColor: Colors.transparent,
      centerTitle: true,
      title: Text(
        "Card Reader App",
        style: textStyle.titleLarge!.copyWith(color: colorScheme.secondary),
      ),
      iconTheme: IconThemeData(color: colorScheme.secondary, size: 30),
    );

    // make sure if the user isn't logged in (he logged out) return the auth page (replace this page). it wont be needed as we have StreamBuilder but just in case
    _checkIfUserAuthenticated(context);

    // check if the user has a valid email (he validate it)
    _checkIfUserValidated(context);

    return Scaffold(
      drawer: const Drawer(),
      extendBodyBehindAppBar: true,
      appBar: appbar,
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            height: height - topMargin,
            width: width,
            alignment: Alignment.bottomCenter,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: appbar.preferredSize.height,
                  left: 20,
                  child: Container(
                    width: width - 40,
                    height: 5,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: colorScheme.secondary.withValues(alpha: 0.3),
                    ),
                  ),
                ),

                Align(
                  alignment: AlignmentGeometry.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FaIcon(
                        FontAwesomeIcons.solidFaceSadTear,
                        size: 200,
                        color: colorScheme.primary.withValues(alpha: 0.1),
                      ),
                      Text(
                        "No Cards Scanned",
                        style: textStyle.titleLarge!.copyWith(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          fontSize: 35,
                        ),
                      ),
                    ],
                  ),
                ),

                //bottom navigation bar
                Positioned(
                  bottom: bottomMargin,
                  left: bottomMargin,
                  right: bottomMargin,
                  child: Container(
                    width: width - bottomMargin * 2,
                    height: 50,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          offset: const Offset(0, 4),
                          blurRadius: 4,
                          color: Colors.black.withValues(alpha: 0.25),
                        ),
                      ],
                      color: colorScheme.onPrimary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Material(
                        color: Colors.transparent,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Ink(
                              height: 50,
                              width: 50,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(50),
                                splashColor: colorScheme.onPrimary.withValues(
                                  alpha: 0.4,
                                ),
                                onTap: () {
                                  print("Filter");
                                },
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      FaIcon(
                                        FontAwesomeIcons.filter,
                                        color: colorScheme.onTertiary
                                            .withValues(alpha: 0.5),
                                        size: 20,
                                      ),
                                      Text(
                                        "Filter",
                                        style: textStyle.bodyLarge!.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: colorScheme.onTertiary
                                              .withValues(alpha: 0.5),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            Ink(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: colorScheme.onTertiary.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(50),
                                splashColor: colorScheme.onPrimary.withValues(
                                  alpha: 0.4,
                                ),
                                onTap: () {
                                  print("camera");
                                },
                                child: Center(
                                  child: FaIcon(
                                    FontAwesomeIcons.cameraRetro,
                                    size: 30,
                                    color: colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                            ),
                            Ink(
                              height: 50,
                              width: 50,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(50),
                                splashColor: colorScheme.onPrimary.withValues(
                                  alpha: 0.4,
                                ),
                                onTap: () {
                                  print("Share");
                                },
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      FaIcon(
                                        FontAwesomeIcons.shareNodes,
                                        color: colorScheme.onTertiary
                                            .withValues(alpha: 0.5),
                                        size: 20,
                                      ),
                                      Text(
                                        "Share",
                                        style: textStyle.bodyLarge!.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: colorScheme.onTertiary
                                              .withValues(alpha: 0.5),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:card_reader_app/Screens/auth_screen.dart';
import 'package:card_reader_app/Screens/background_screen.dart';
import 'package:card_reader_app/Screens/loading_screen.dart';
import 'package:card_reader_app/Screens/validate_email_screen.dart';
import 'package:card_reader_app/Widgets/custom_app_bar.dart';
import 'package:card_reader_app/Widgets/custom_bottom_navigation_bar.dart';
import 'package:card_reader_app/Widgets/custom_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? currentUser = FirebaseAuth.instance.currentUser;

  void _checkIfUserValidated(BuildContext context) async {
    await currentUser!.reload();
    // check if (not verified)
    if (!currentUser!.emailVerified) {
      await Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const PopScope(
                canPop:
                    false, //user can't go to the home page (hit back button)
                child: BackgroundScreen(scaffoldWidget: ValidateEmailScreen()),
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
              const PopScope(canPop: false, child: AuthScreen()),
        ),
      );
    }
  }

  @override
  void initState() {
    //get the current user signed in (it will be null if there isn't any user signed in, we could use it to show the auth screen)
    currentUser = FirebaseAuth.instance.currentUser;

    // make sure if the user isn't logged in (he logged out) return the auth page (replace this page). it wont be needed as we have StreamBuilder but just in case
    _checkIfUserAuthenticated(context);

    // check if the user has a valid email (he validate it)
    _checkIfUserValidated(context);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final topMargin = MediaQuery.of(context).padding.top;
    final width = MediaQuery.sizeOf(context).width;
    final colorScheme = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme;

    final appbar = const CustomAppBar(
      screenTitle: "Card Reader",
      allowBackScreen: false,
    );

    final drawer = const CustomDrawer();

    final bottomNavigationBar = const CustomBottomNavigationBar();

    return StreamBuilder(
      // to detect if something happen to the user account like email
      stream: FirebaseAuth.instance.idTokenChanges(),
      builder: (context, snapshot) {
        //this could be used to ensure that the user is logged it or has validated email.. etc (instead of the functions defined before)
        //example
        // if (user == null || user.emailVerified == false)

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const BackgroundScreen(scaffoldWidget: LoadingScreen());
        }
        if (!snapshot.hasData) {
          return const AuthScreen();
        }
        // it will be there always as hasdata is handeled before
        User? user = snapshot.data;
        // to ensure the user's info is updated (this will ensure the streambuilder notices if the data is changed)
        user!.reload();

        return Scaffold(
          drawer: drawer,
          extendBodyBehindAppBar: true,
          appBar: appbar,
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: true,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: topMargin),
                  child: Container(
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
                        Align(
                          alignment: AlignmentGeometry.bottomCenter,
                          child: Padding(
                            padding: EdgeInsets.only(
                              top: appbar.preferredSize.height,
                              bottom: bottomNavigationBar.bottomNavSize,
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  FaIcon(
                                    FontAwesomeIcons.solidFaceSadTear,
                                    size: 200,
                                    color: colorScheme.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                  ),
                                  Text(
                                    "No Cards Scanned",
                                    style: textStyle.titleLarge!.copyWith(
                                      color: colorScheme.primary.withValues(
                                        alpha: 0.1,
                                      ),
                                      fontSize: 35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        //bottom navigation bar
                        bottomNavigationBar,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

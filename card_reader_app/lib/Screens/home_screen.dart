import 'package:card_reader_app/Screens/auth_screen.dart';
import 'package:card_reader_app/Screens/background_screen.dart';
import 'package:card_reader_app/Screens/cards_screen.dart';
import 'package:card_reader_app/Screens/scan_screen.dart';
import 'package:card_reader_app/Screens/settings_screen.dart';
import 'package:card_reader_app/Screens/validate_email_screen.dart';
import 'package:card_reader_app/Widgets/custom_drawer_button.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

//get the current user signed in (it will be null if there isn't any user signed in, we could use it to show the auth screen)
User? currentUser = FirebaseAuth.instance.currentUser;
const double bottomNavSize = 55;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // the currect selected screen to show the user
  int currentContentIdx = 0;
  String currentTitle = "Card Reader App";

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
    Widget currentContent;

    //create a virable to get the height to place a line
    final appbar = AppBar(
      backgroundColor: Colors.transparent,
      centerTitle: true,
      title: Text(
        currentTitle,
        style: textStyle.titleLarge!.copyWith(
          color: colorScheme.secondary,
          fontSize: 30,
        ),
      ),
      iconTheme: IconThemeData(color: colorScheme.secondary, size: 30),
    );

    // based on the index of the content present it as some needs buildcontext which means that i can't generate it outside context
    switch (currentContentIdx) {
      case 0:
        currentContent = CardsScreen(appBar: appbar);
        break;

      case 1:
        currentContent = ScanScreen(
          appbarHeight: appbar.preferredSize.height,
          bottomNavSize: bottomNavSize,
        );
        break;

      case 2:
        currentContent = const SettingsScreen(bottomNavSize: bottomNavSize);
        break;

      default:
        currentContent = CardsScreen(appBar: appbar);
    }

    // make sure if the user isn't logged in (he logged out) return the auth page (replace this page). it wont be needed as we have StreamBuilder but just in case
    _checkIfUserAuthenticated(context);

    // check if the user has a valid email (he validate it)
    _checkIfUserValidated(context);

    return Scaffold(
      drawer: Drawer(
        backgroundColor: colorScheme.primary,
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            children: [
              //drawer's header
              Container(
                width: double.infinity,
                height: height / 5,
                decoration: BoxDecoration(color: colorScheme.onSurface),
                child: Column(
                  children: [
                    SizedBox(height: topMargin),
                    //app title
                    Text(
                      "Buisness Card Reader",
                      textAlign: TextAlign.center,
                      style: textStyle.titleLarge!.copyWith(
                        fontSize: 32,
                        color: colorScheme.surface,
                      ),
                    ),
                    const Expanded(child: SizedBox()),

                    //user's name
                    SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          "Hello, ${currentUser!.displayName ?? "App User"}.",
                          textAlign: TextAlign.start,
                          style: textStyle.titleLarge!.copyWith(
                            fontSize: 15,
                            color: colorScheme.surface,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 5),

                    //user's email
                    SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          currentUser!.email ?? "No Email Found",
                          textAlign: TextAlign.start,
                          style: textStyle.titleLarge!.copyWith(
                            fontSize: 15,
                            color: colorScheme.surface,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),

              //drawer's body
              SizedBox(
                height: (height / 5) * 4 - bottomMargin,
                child: Padding(
                  padding: const EdgeInsetsGeometry.symmetric(horizontal: 20),
                  child: CustomScrollView(
                    slivers: [
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Column(
                          children: [
                            const SizedBox(height: 20),

                            CustomDrawerButton(
                              onPressed: () {
                                setState(() {
                                  currentContentIdx = 0;
                                  currentTitle = "Card Reader App";
                                });
                                // close drawer
                                Navigator.of(context).pop();
                              },
                              label: "Cards",
                              icon: FontAwesomeIcons.solidIdCard,
                            ),
                            const SizedBox(height: 10),

                            CustomDrawerButton(
                              onPressed: () {
                                setState(() {
                                  currentContentIdx = 1;
                                  currentTitle = "Scan a Card";
                                });
                                // close drawer
                                Navigator.of(context).pop();
                              },
                              label: "Scan a card",
                              icon: FontAwesomeIcons.cameraRetro,
                            ),
                            const SizedBox(height: 10),

                            CustomDrawerButton(
                              onPressed: () {
                                setState(() {
                                  currentContentIdx = 2;
                                  currentTitle = "Settings";
                                });
                                // close drawer
                                Navigator.of(context).pop();
                              },
                              label: "Settings",
                              icon: FontAwesomeIcons.gear,
                            ),
                            const SizedBox(height: 10),

                            CustomDrawerButton(
                              onPressed: () {},
                              label: "Profile",
                              icon: FontAwesomeIcons.solidUser,
                            ),
                            const SizedBox(height: 10),

                            CustomDrawerButton(
                              onPressed: () {},
                              label: "Rate Us",
                              icon: FontAwesomeIcons.solidStar,
                            ),
                            const SizedBox(height: 10),

                            CustomDrawerButton(
                              onPressed: () {},
                              label: "Privacy",
                              icon: FontAwesomeIcons.lock,
                            ),
                            const SizedBox(height: 10),

                            CustomDrawerButton(
                              onPressed: () async {
                                // present confirm button before signing the user out
                                if (await confirm(
                                  context,
                                  title: Text(
                                    "Confirm",
                                    style: textStyle.titleLarge!.copyWith(
                                      color: colorScheme.secondary,
                                    ),
                                  ),
                                  content: Text(
                                    "Are you sure you want to sign out?",
                                    style: textStyle.titleSmall!.copyWith(
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                  textOK: const Text("Sign Out"),
                                  textCancel: const Text("Cancel"),
                                )) {
                                  await FirebaseAuth.instance.signOut();
                                  Navigator.of(context).pop();
                                }
                                {
                                  // do nothing otherwise
                                  Navigator.of(context).pop();
                                }
                              },
                              label: "Log Out",
                              icon: FontAwesomeIcons.arrowRightFromBracket,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
                //line dividing app bar
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
                // current screen (cards or scan or more)
                Align(
                  alignment: AlignmentGeometry.bottomCenter,
                  child: SizedBox(
                    // to make it don't go on top of appbar
                    height: height - appbar.preferredSize.height * 2,
                    child: currentContent,
                  ),
                ),
                //bottom navigation bar
                Positioned(
                  bottom: bottomMargin,
                  left: bottomMargin,
                  right: bottomMargin,
                  child: Container(
                    width: width - bottomMargin * 2,
                    height: bottomNavSize,
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
                            //change filter type
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
                                        size: 25,
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

                            //camera (for scanning)
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
                                  setState(() {
                                    currentContentIdx = 1;
                                    currentTitle = "Scan a Card";
                                  });
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

                            //Share card (it should say no card selected if there wan't any or the user didn't select cards)
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
                                  setState(() {
                                    currentContentIdx = 0;
                                    currentTitle = "Card Reader App";
                                  });
                                },
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      FaIcon(
                                        FontAwesomeIcons.solidIdCard,
                                        color: colorScheme.onTertiary
                                            .withValues(alpha: 0.5),
                                        size: 25,
                                      ),
                                      Text(
                                        "Cards",
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

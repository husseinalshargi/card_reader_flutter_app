import 'package:card_reader_app/Screens/current_screen.dart';
import 'package:card_reader_app/Screens/profile_screen.dart';
import 'package:card_reader_app/Screens/scan_screen.dart';
import 'package:card_reader_app/Screens/settings_screen.dart';
import 'package:card_reader_app/Widgets/custom_drawer_button.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});
  String getUserName() {
    final currentUpdatedUser = FirebaseAuth.instance.currentUser;
    if (currentUpdatedUser == null) return "Not_Logged_In";
    final updatedUserName = currentUpdatedUser.displayName;
    return updatedUserName ?? "A_User";
  }

  String getUserEmail() {
    final currentUpdatedUser = FirebaseAuth.instance.currentUser;
    if (currentUpdatedUser == null) return "Not Logged In";
    final updatedEmail = currentUpdatedUser.email;
    return updatedEmail ?? "Not Logged In";
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme;

    return Drawer(
      backgroundColor: colorScheme.primary,
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            //drawer's header (used for accounts header)
            UserAccountsDrawerHeader(
              currentAccountPictureSize: const Size(0, 0),
              otherAccountsPicturesSize: const Size(0, 0),
              //as it will return a string that has "_" in it
              accountName: Text(getUserName().split("_").join(" ")),
              accountEmail: Text(getUserEmail()),
            ),

            //drawer's body
            Expanded(
              child: SizedBox(
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
                                // close drawer
                                Navigator.of(context).pop();

                                // go to the card reader screen
                                Navigator.of(context).pushReplacement(
                                  PageRouteBuilder(
                                    pageBuilder:
                                        (
                                          context,
                                          animation,
                                          secondaryAnimation,
                                        ) {
                                          return const CurrentScreen();
                                        },
                                  ),
                                );
                              },
                              label: "Cards",
                              icon: FontAwesomeIcons.solidIdCard,
                            ),
                            const SizedBox(height: 10),

                            CustomDrawerButton(
                              onPressed: () {
                                // close drawer
                                Navigator.of(context).pop();

                                Navigator.of(context).push(
                                  PageRouteBuilder(
                                    pageBuilder:
                                        (
                                          context,
                                          animation,
                                          secondaryAnimation,
                                        ) {
                                          return const ScanScreen();
                                        },
                                  ),
                                );
                              },
                              label: "Scan a card",
                              icon: FontAwesomeIcons.cameraRetro,
                            ),
                            const SizedBox(height: 10),

                            CustomDrawerButton(
                              onPressed: () {
                                // close drawer
                                Navigator.of(context).pop();

                                Navigator.of(context).push(
                                  PageRouteBuilder(
                                    pageBuilder:
                                        (
                                          context,
                                          animation,
                                          secondaryAnimation,
                                        ) {
                                          return const SettingsScreen();
                                        },
                                  ),
                                );
                              },
                              label: "Settings",
                              icon: FontAwesomeIcons.gear,
                            ),
                            const SizedBox(height: 10),

                            CustomDrawerButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  PageRouteBuilder(
                                    pageBuilder:
                                        (
                                          context,
                                          animation,
                                          secondaryAnimation,
                                        ) => const ProfileScreen(),
                                  ),
                                );
                              },
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
                                } else {
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
            ),
          ],
        ),
      ),
    );
  }
}

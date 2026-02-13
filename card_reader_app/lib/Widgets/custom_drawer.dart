import 'package:card_reader_app/Widgets/custom_drawer_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key, required this.currentUser});
  final User currentUser;
  @override
  Widget build(BuildContext context) {
    final topMargin = MediaQuery.of(context).padding.top;
    final bottomMargin = MediaQuery.of(context).padding.bottom;
    final height = MediaQuery.sizeOf(context).height;
    final colorScheme = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme;

    return Drawer(
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
                        "Hello, ${currentUser.displayName ?? "App User"}.",
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
                        currentUser.email ?? "No Email Found",
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
                            onPressed: () {},
                            label: "Notification",
                            icon: FontAwesomeIcons.solidBell,
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
                            label: "Scan",
                            icon: FontAwesomeIcons.cameraRetro,
                          ),
                          const SizedBox(height: 10),

                          CustomDrawerButton(
                            onPressed: () {},
                            label: "Theme",
                            icon: FontAwesomeIcons.brush,
                          ),
                          const SizedBox(height: 10),

                          CustomDrawerButton(
                            onPressed: () {},
                            label: "Privacy",
                            icon: FontAwesomeIcons.lock,
                          ),
                          const SizedBox(height: 10),

                          CustomDrawerButton(
                            onPressed: () {
                              FirebaseAuth.instance.signOut();
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
    );
  }
}

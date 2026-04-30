import 'package:card_reader_app/Screens/current_screen.dart';
import 'package:card_reader_app/Screens/scan_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar({super.key});
  final double bottomNavSize = 55;

  @override
  Widget build(BuildContext context) {
    final bottomMargin = MediaQuery.of(context).padding.bottom;
    final width = MediaQuery.sizeOf(context).width;
    final colorScheme = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme;

    return Positioned(
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
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(50),
                    splashColor: colorScheme.onPrimary.withValues(alpha: 0.4),
                    onTap: () {
                      print("Filter");
                    },
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FaIcon(
                            FontAwesomeIcons.filter,
                            color: colorScheme.onTertiary.withValues(
                              alpha: 0.5,
                            ),
                            size: 25,
                          ),
                          Text(
                            "Filter",
                            style: textStyle.bodyLarge!.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: colorScheme.onTertiary.withValues(
                                alpha: 0.5,
                              ),
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
                    color: colorScheme.onTertiary.withValues(alpha: 0.5),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(50),
                    splashColor: colorScheme.onPrimary.withValues(alpha: 0.4),
                    onTap: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) {
                                return const ScanScreen();
                              },
                        ),
                      );
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
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(50),
                    splashColor: colorScheme.onPrimary.withValues(alpha: 0.4),
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) {
                                return const CurrentScreen();
                              },
                        ),
                      );
                    },
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FaIcon(
                            FontAwesomeIcons.solidIdCard,
                            color: colorScheme.onTertiary.withValues(
                              alpha: 0.5,
                            ),
                            size: 25,
                          ),
                          Text(
                            "Cards",
                            style: textStyle.bodyLarge!.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: colorScheme.onTertiary.withValues(
                                alpha: 0.5,
                              ),
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
    );
  }
}

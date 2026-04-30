import 'package:card_reader_app/Screens/background_screen.dart';
import 'package:card_reader_app/Widgets/custom_app_bar.dart';
import 'package:card_reader_app/Widgets/part_splitter.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isNotified = false;
  bool isDark = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme;
    final width = MediaQuery.sizeOf(context).width;
    final bottomMargin = MediaQuery.of(context).padding.bottom;
    final topMargin = MediaQuery.of(context).padding.top;

    final appbar = const CustomAppBar(
      screenTitle: "Settings",
      allowBackScreen: true,
    );

    return BackgroundScreen(
      scaffoldWidget: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: appbar,
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: true,
        body: Padding(
          padding: EdgeInsets.only(top: topMargin),
          child: Container(
            width: width,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
            child: ListView(
              padding: EdgeInsets.only(
                left: 15,
                right: 15,
                top: appbar.preferredSize.height,
                bottom: bottomMargin,
              ),
              children: [
                //notifications part
                const PartSplitter(title: "Notifications"),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Switch(
                      // remove the top and bottom padding of the switch
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      activeThumbColor: colorScheme.tertiary,
                      activeTrackColor: colorScheme.secondary,
                      inactiveThumbColor: colorScheme.secondary,
                      inactiveTrackColor: colorScheme.onPrimary,
                      value: isNotified,
                      onChanged: (newIsNotifiedValue) {
                        setState(() {
                          isNotified = newIsNotifiedValue;
                        });
                      },
                    ),
                    const SizedBox(width: 20),
                    Text(
                      "App Notifications",
                      style: textStyle.titleLarge!.copyWith(
                        color: colorScheme.secondary,
                        fontSize: 25,
                        shadows: [
                          Shadow(
                            offset: const Offset(0, 4),
                            blurRadius: 4,
                            color: Colors.black.withValues(alpha: 0.25),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                //theme part
                const PartSplitter(title: "Theme"),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Switch(
                      // remove the top and bottom padding of the switch
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      activeThumbColor: colorScheme.tertiary,
                      activeTrackColor: colorScheme.secondary,
                      inactiveThumbColor: colorScheme.secondary,
                      inactiveTrackColor: colorScheme.onPrimary,
                      value: isDark,
                      onChanged: (newIsDarkValue) {
                        setState(() {
                          isDark = newIsDarkValue;
                        });
                      },
                    ),
                    const SizedBox(width: 20),
                    Text(
                      "Dark Mode",
                      style: textStyle.titleLarge!.copyWith(
                        color: colorScheme.secondary,
                        fontSize: 25,
                        shadows: [
                          Shadow(
                            offset: const Offset(0, 4),
                            blurRadius: 4,
                            color: Colors.black.withValues(alpha: 0.25),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

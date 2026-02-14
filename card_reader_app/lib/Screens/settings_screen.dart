import 'package:card_reader_app/Widgets/part_splitter.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.appbarHeight,
    required this.bottomNavSize,
  });
  final double appbarHeight;
  final double bottomNavSize;

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

    return SizedBox(
      width: width - 30,
      child: ListView(
        padding: EdgeInsets.zero,
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

          // sized box with the same size as the bottom nav bar to add padding in the bottom also the bottom margin (button used to get out of the app)
          SizedBox(height: widget.bottomNavSize + bottomMargin),
        ],
      ),
    );
  }
}

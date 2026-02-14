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
          Row(
            children: [
              Switch(
                activeThumbColor: colorScheme.tertiary,
                activeTrackColor: colorScheme.secondary,
                inactiveThumbColor: colorScheme.secondary,
                inactiveTrackColor: colorScheme.onPrimary,
                value: isNotified,
                onChanged: (newThresholdValue) {
                  setState(() {
                    isNotified = newThresholdValue;
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
              // sized box with the same size as the bottom nav bar to add padding in the bottom also the bottom margin (button used to get out of the app)
              SizedBox(height: widget.bottomNavSize + bottomMargin),
            ],
          ),
        ],
      ),
    );
  }
}

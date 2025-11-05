import 'package:flutter/material.dart';

class BackgroundScreen extends StatelessWidget {
  // this screen has the pattern with the color also has the status bar adjustment
  // all other scaffolds is passed to this
  const BackgroundScreen({super.key, required this.scaffoldWidget});
  final Widget scaffoldWidget;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        image: const DecorationImage(
          fit: BoxFit.none,
          image: AssetImage("assets/images/StarPattern.png"),
          repeat: ImageRepeat.repeat,
          scale: 12,
          opacity: 0.2,
        ),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [colorScheme.tertiary, colorScheme.onTertiary],
        ),
      ),
      child: scaffoldWidget,
    );
  }
}

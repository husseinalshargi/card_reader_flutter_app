import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class NoCardsWidget extends StatelessWidget {
  const NoCardsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme;

    return Center(
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
    );
  }
}

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CardsScreen extends StatefulWidget {
  const CardsScreen({super.key, required this.appBar});
  final AppBar appBar;
  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;

    final colorScheme = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme;

    return SizedBox(
      height: height,
      width: width,
      child: Center(
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
      ),
    );
  }
}

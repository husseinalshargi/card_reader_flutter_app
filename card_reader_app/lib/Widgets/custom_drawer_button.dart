import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomDrawerButton extends StatelessWidget {
  const CustomDrawerButton({
    super.key,
    required this.onPressed,
    required this.label,
    required this.icon,
  });
  final Function() onPressed;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(backgroundColor: colorScheme.surface),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FaIcon(
                  icon,
                  size: constraints.biggest.height - 6,
                  color: colorScheme.onTertiary,
                ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: textStyle.titleLarge!.copyWith(
                    color: colorScheme.onTertiary,
                    fontSize: constraints.biggest.height - 5,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

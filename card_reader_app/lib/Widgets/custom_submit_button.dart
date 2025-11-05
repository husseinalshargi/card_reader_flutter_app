import 'package:flutter/material.dart';

class CustomSubmitButton extends StatelessWidget {
  const CustomSubmitButton({
    super.key,
    required this.onTap,
    required this.title,
  });
  final void Function() onTap;
  final String title;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      child: SizedBox(
        height: 55,
        width: width - 40,
        child: Column(
          children: [
            Ink(
              height: 50,
              decoration: BoxDecoration(
                color: colorScheme.scrim,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    offset: const Offset(0, 4),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                splashColor: colorScheme.surface.withValues(alpha: 0.25),
                onTap: onTap,
                child: Center(
                  child: Text(
                    title,
                    style: textTheme.bodyLarge!.copyWith(
                      color: colorScheme.surface,
                      fontSize: 16,
                    ),
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

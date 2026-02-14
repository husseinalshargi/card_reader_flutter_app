import 'package:flutter/material.dart';

class PartSplitter extends StatelessWidget {
  const PartSplitter({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme;
    final width = MediaQuery.sizeOf(context).width;

    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsetsGeometry.only(top: 15, left: 5, right: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //left side of the splitter
            Expanded(
              child: Container(
                height: 2,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withValues(alpha: 0.25),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: Text(
                title,
                style: textStyle.titleSmall!.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.25),
                ),
              ),
            ),
            //right side of the splitter
            Expanded(
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withValues(alpha: 0.25),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

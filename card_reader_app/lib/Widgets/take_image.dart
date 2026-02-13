import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TakeImage extends StatefulWidget {
  const TakeImage({super.key, required this.title});
  final String title;
  @override
  State<TakeImage> createState() => _TakeImageState();
}

class _TakeImageState extends State<TakeImage> {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
    final colorScheme = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme;

    return SizedBox(
      height: height / 4,
      child: Column(
        children: [
          Text(
            widget.title,
            style: textStyle.titleSmall!.copyWith(fontSize: 13),
          ),
          Expanded(
            // for the shadows
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadiusGeometry.circular(25),
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(0, 4),
                    blurRadius: 4,
                    color: Colors.black.withValues(alpha: 0.25),
                  ),
                ],
              ),
              // the button itself
              child: Material(
                color: Colors.transparent,
                child: Ink(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 252, 242, 243),
                    borderRadius: BorderRadiusGeometry.circular(25),
                    border: BoxBorder.all(
                      color: colorScheme.secondary,
                      width: 2,
                    ),
                  ),
                  // camera icon
                  child: InkWell(
                    onTap: () {},
                    child: Center(
                      child: SizedBox(
                        width: width / 2,
                        height: height / 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              FontAwesomeIcons.solidCamera,
                              size: width / 4,
                              color: Colors.black26,
                            ),
                            Text(
                              "Press to Take an Image",
                              style: textStyle.titleSmall!.copyWith(
                                fontSize: 15,
                                color: Colors.black26,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.visible,
                              softWrap: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

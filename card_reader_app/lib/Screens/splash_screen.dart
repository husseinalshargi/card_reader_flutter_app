import 'package:flutter/material.dart';
//currently this is only used for future needs of the components (it won't be used in app)

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() {
    return _SplashScreenState();
  }
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var colorScheme = theme.colorScheme;
    var textTheme = theme.textTheme;

    double width = MediaQuery.sizeOf(context).width;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(backgroundColor: colorScheme.surface),
      ),
      backgroundColor: Colors.transparent,
      body: Center(
        child: SizedBox(
          height: 400,
          width: width,
          child: Stack(
            children: [
              ClipPath(
                clipper: WaveClipper(),
                child: Container(color: colorScheme.surface, height: 400),
              ),
              Center(
                child: Text(
                  'Business Card Reader',
                  style: textTheme.titleLarge!.copyWith(
                    color: colorScheme.primary,
                    fontSize: 64,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.visible,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    debugPrint(size.width.toString());

    var path = Path();

    path.moveTo(0, 100);

    // start from the top left of the screen go to height on the y (of the passed size in container)
    path.lineTo(0, size.height - 100);

    // controlling point (Bezier Curve)
    var firstLineControlPoint = Offset(size.width / 4, size.height - 150);

    // end of the first line
    var firstLineEndPoint = Offset(size.width / 2, size.height - 100);

    // make the first line
    path.quadraticBezierTo(
      firstLineControlPoint.dx,
      firstLineControlPoint.dy,
      firstLineEndPoint.dx,
      firstLineEndPoint.dy,
    );

    //start from the buttom center to the bottom right
    var secondLineControlPoint = Offset((size.width / 4) * 3, size.height - 50);

    var secondLineEndPoint = Offset(size.width, size.height - 100);

    path.quadraticBezierTo(
      secondLineControlPoint.dx,
      secondLineControlPoint.dy,
      secondLineEndPoint.dx,
      secondLineEndPoint.dy,
    );

    path.lineTo(size.width, 100);

    var thirdLineControlPoint = Offset((size.width / 4) * 3, 150);

    var thirdLineEndPoint = Offset(size.width / 2, 100);

    path.quadraticBezierTo(
      thirdLineControlPoint.dx,
      thirdLineControlPoint.dy,
      thirdLineEndPoint.dx,
      thirdLineEndPoint.dy,
    );

    var fourthLineControlPoint = Offset(size.width / 4, 50);

    var fourthLineEndPoint = Offset(0, 100);

    path.quadraticBezierTo(
      fourthLineControlPoint.dx,
      fourthLineControlPoint.dy,
      fourthLineEndPoint.dx,
      fourthLineEndPoint.dy,
    );

    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}

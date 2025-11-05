import 'package:card_reader_app/Widgets/sign_in_form.dart';
import 'package:card_reader_app/Widgets/sign_up_form.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

enum AuthMode { signup, logIn }

AuthMode authMode = AuthMode.logIn;

FirebaseAuth firebaseInstance = FirebaseAuth.instance;

class AuthBackground extends StatefulWidget {
  const AuthBackground({super.key});

  @override
  State<AuthBackground> createState() => _AuthBackgroundState();
}

class _AuthBackgroundState extends State<AuthBackground> {
  Widget currentForm = SignInForm(firebaseInstance: firebaseInstance);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // get the navigation bar height size
    final navigationBarSize = MediaQuery.of(context).padding.bottom;

    return SizedBox(
      width: width,
      child: Column(
        children: [
          Stack(
            children: [
              ClipPath(
                clipper: WaveClipper(),
                child: Container(
                  width: width,
                  height: height / 6,
                  color: colorScheme.surface,
                ),
              ),
              Positioned(
                left: authMode == AuthMode.logIn ? 0 : width / 2,
                top: height / 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      authMode == AuthMode.logIn ? 'Sign In' : 'Sign Up',
                      style: textTheme.titleLarge!.copyWith(
                        fontSize: 35,
                        color: colorScheme.primary,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 60),
                      child: Container(
                        height: 6,
                        width: 80,
                        decoration: BoxDecoration(
                          color: colorScheme.tertiary.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          ConstrainedBox(
            //solution for bottom overflow in case of the container was smaller thatn the coulmn (child) widget
            constraints: BoxConstraints(minHeight: height / 1.6),
            child: Container(
              width: width,
              color: colorScheme.surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  currentForm, //sign up or in form
                  Padding(
                    padding: EdgeInsets.only(bottom: navigationBarSize),
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      direction: Axis.horizontal,
                      alignment: WrapAlignment.center,
                      runAlignment: WrapAlignment.center,
                      children: [
                        Text(
                          authMode == AuthMode.logIn
                              ? 'Don’t Have an Account Yet?'
                              : 'Already Have an Account?',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontSize: 16,
                          ),
                        ),
                        TextButton(
                          child: Text(
                            authMode == AuthMode.logIn
                                ? 'Sign Up Here'
                                : 'Sign In Here',
                            style: TextStyle(
                              color: colorScheme.tertiary,
                              fontSize: 16,
                              decoration: TextDecoration.underline,
                              decorationColor: colorScheme.tertiary,
                              decorationThickness: 2,
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              authMode = authMode == AuthMode.logIn
                                  ? AuthMode.signup
                                  : AuthMode.logIn;
                              currentForm = authMode == AuthMode.logIn
                                  ? SignInForm(
                                      firebaseInstance: firebaseInstance,
                                    )
                                  : SignUpForm(
                                      firebaseInstance: firebaseInstance,
                                    );
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  // to make it animate create a constructor that takes the values of the points (make it using animation widget (the value))

  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(0, 100);

    path.lineTo(0, 200);
    path.lineTo(size.width, 200);
    path.lineTo(size.width, 100);

    var firstLineGrapPoint = Offset(
      (size.width / 4) * 3,
      authMode == AuthMode.logIn ? 200 : 0,
    );

    var firstLineEndPoint = Offset(size.width / 2, 100);

    path.quadraticBezierTo(
      firstLineGrapPoint.dx,
      firstLineGrapPoint.dy,
      firstLineEndPoint.dx,
      firstLineEndPoint.dy,
    );

    var secondLineGrapPoint = Offset(
      (size.width / 4),
      authMode == AuthMode.logIn ? 0 : 200,
    );

    var secondLineEndPoint = const Offset(0, 100);

    path.quadraticBezierTo(
      secondLineGrapPoint.dx,
      secondLineGrapPoint.dy,
      secondLineEndPoint.dx,
      secondLineEndPoint.dy,
    );

    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}

import 'dart:async';

import 'package:card_reader_app/Screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ValidateEmailScreen extends StatefulWidget {
  const ValidateEmailScreen({super.key, required this.currentUser});
  final User? currentUser;

  @override
  State<ValidateEmailScreen> createState() => _ValidateEmailScreenState();
}

class _ValidateEmailScreenState extends State<ValidateEmailScreen> {
  bool isDisabled = false;
  Widget? timerCountDown;
  late Timer _verificationCheckTimer;

  //checks if the user is email is verified
  void startPeriodicVerificationCheck() {
    _verificationCheckTimer = Timer.periodic(const Duration(seconds: 5), (
      timer,
    ) async {
      await currentUser!.reload();
      if (currentUser!.emailVerified) {
        _verificationCheckTimer.cancel();
        Navigator.of(context).pop();
      }
    });
  }

  //to make the user press a button to ensure the app detect
  void ensureVerification() async {
    await currentUser!.reload();
    if (currentUser!.emailVerified) {
      _verificationCheckTimer.cancel();
      Navigator.of(context).pop();
    }
  }

  @override
  void initState() {
    startPeriodicVerificationCheck();
    super.initState();
  }

  void disableVerificationButton() {
    //disables the button for two minutes
    setState(() {
      isDisabled = true;
    });
    timerCountDown = TimerCountdown(
      timeTextStyle: Theme.of(
        context,
      ).textTheme.bodySmall!.copyWith(fontSize: 12),
      colonsTextStyle: Theme.of(
        context,
      ).textTheme.bodySmall!.copyWith(fontSize: 12),
      enableDescriptions: false,
      format: CountDownTimerFormat.minutesSeconds,
      endTime: DateTime.now().add(const Duration(minutes: 2)),
      onEnd: () {
        setState(() {
          isDisabled = false;
          timerCountDown = null;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final topMargin = MediaQuery.of(context).padding.top;
    final bottomMargin = MediaQuery.of(context).padding.bottom;
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          width: width,
          height: height - topMargin,
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: Colors.transparent,
            body: Container(
              alignment: Alignment.bottomCenter,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: height / 5),
                  Image.asset('assets/images/Mail.png', scale: width / 50),
                  const SizedBox(height: 10),
                  Text(
                    "Please Verify Your Email",
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: colorScheme.primary,
                      fontSize: width / 12,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsGeometry.symmetric(
                      vertical: 2,
                      horizontal: 20,
                    ),
                    child: Text(
                      "An Email Verification is Sent to Your Email, Validate It to Gain Access to Your Card Reading App",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: colorScheme.primary.withValues(alpha: 0.8),
                        fontSize: width / 25,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    //disables the button if is disabled was true (when a user clickes tha button)
                    onPressed: isDisabled
                        ? null
                        : () async {
                            disableVerificationButton();
                            try {
                              await currentUser!.sendEmailVerification();
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: colorScheme.onSurface,
                                  showCloseIcon: true,
                                  closeIconColor: colorScheme.surface,
                                  content: Text(
                                    "Email Verification Sent. Check Your Spam if It Wasn't Found.",
                                    style: TextStyle(
                                      color: colorScheme.surface,
                                    ),
                                  ),
                                ),
                              );
                            } catch (error) {
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: colorScheme.error,
                                  showCloseIcon: true,
                                  closeIconColor: colorScheme.surface,
                                  content: Text(
                                    "Something Went Wrong, Verification email Can't be sent, make sure your email is correct or try again later.",
                                    style: TextStyle(
                                      color: colorScheme.surface,
                                    ),
                                  ),
                                ),
                              );
                            }
                          },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.scrim,
                      foregroundColor: colorScheme.surface,
                    ),
                    child: const Text("Send Email Verification"),
                  ),
                  ElevatedButton(
                    onPressed: ensureVerification,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.surface.withValues(
                        alpha: 0.9,
                      ),
                    ),
                    child: const Text("Already Verified?"),
                  ),
                  if (timerCountDown != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Send Another Email After: ",
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall!.copyWith(fontSize: 12),
                        ),

                        timerCountDown!,
                      ],
                    ),
                  const Expanded(child: SizedBox()),
                  TextButton.icon(
                    onPressed: () {
                      _verificationCheckTimer.cancel();
                      FirebaseAuth.instance.signOut();
                      Navigator.of(context).pop();
                    },
                    label: const Text("Log Out"),
                    icon: const FaIcon(FontAwesomeIcons.arrowRightFromBracket),
                  ),
                  SizedBox(height: bottomMargin + 5),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _verificationCheckTimer.cancel();
    super.dispose();
  }
}

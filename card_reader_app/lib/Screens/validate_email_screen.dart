import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ValidateEmailScreen extends StatefulWidget {
  const ValidateEmailScreen({super.key});

  @override
  State<ValidateEmailScreen> createState() => _ValidateEmailScreenState();
}

class _ValidateEmailScreenState extends State<ValidateEmailScreen> {
  bool isDisabled = false;
  Widget? timerCountDown;
  late Timer _verificationCheckTimer;
  final currentUser = FirebaseAuth.instance.currentUser;

  //checks if the user is email is verified
  void startPeriodicVerificationCheck() {
    _verificationCheckTimer = Timer.periodic(const Duration(seconds: 10), (
      timer,
    ) async {
      //get a new instance of the current user to ensure that it is updated
      final newUserInstance = FirebaseAuth.instance.currentUser;
      if (newUserInstance == null) return;

      await newUserInstance.reload();
      if (newUserInstance.emailVerified) {
        _verificationCheckTimer.cancel();
        if (!mounted) return;
        Navigator.of(context).pop();
      }
    });
  }

  //to make the user press a button to ensure the app detect
  void ensureVerification() async {
    //get a new instance of the current user to ensure that it is updated
    final newUserInstance = FirebaseAuth.instance.currentUser;
    if (newUserInstance == null) return;

    await newUserInstance.reload();
    if (newUserInstance.emailVerified) {
      _verificationCheckTimer.cancel();
      if (!mounted) return;
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          showCloseIcon: true,
          closeIconColor: Colors.red.shade50,
          content: const Text(
            "Email isn't verified try again after the cooldown or wait until the app checks",
            maxLines: 3,
            style: TextStyle(color: Colors.black),
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    // this will instead start when the user press send email verfication as it will only be sent then
    // but it kept for future use (the widget binding when using a async method)
    // // schedules the functions to run after the first frame
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   // if it isn't in the current screen (popped or something)
    //   if (!mounted) return;
    //   startPeriodicVerificationCheck();
    // });
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
                      "Email Verification Sent to ${currentUser!.email}.\nValidate It to Gain Access to Your Card Reading App",
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
                              // this will start the verification check after the first send email verfication
                              startPeriodicVerificationCheck();
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
                                    "Something Went Wrong, Verification email Can't be sent, make sure your email is correct or try again later. $error",
                                    maxLines: 5,
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

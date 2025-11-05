import 'package:card_reader_app/Widgets/custom_text_form_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final formKey = GlobalKey<FormState>();
  final instance = FirebaseAuth.instance;
  String enteredEmail = '';

  void sendForgetPasswordEmail(ColorScheme colorScheme) async {
    //validate all text form fields
    final isValid = formKey.currentState!.validate();

    // if one of the text fields isn't valid then do nothing
    if (!isValid) return;

    formKey.currentState!.save();
    //if all correct and have values (email in our case) then do the send forget email logic
    try {
      await instance.sendPasswordResetEmail(email: enteredEmail);
    } on FirebaseAuthException catch (error) {
      //this will close the keyboard
      FocusScope.of(context).unfocus();

      //only notice the user if the email was invalid other wise just say that an email will be sent if the email was correct
      if (error.code == 'invalid-email') {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: colorScheme.error,
            showCloseIcon: true,
            closeIconColor: colorScheme.surface,
            content: Text(
              "Invalid Email, Please Ensure Email is Valid and Try Again",
              style: TextStyle(color: colorScheme.surface),
            ),
          ),
        );
      }
    }
    FocusScope.of(context).unfocus();

    //say that an email will be sent if the email was correct after popping the screen
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: colorScheme.onSurface,
        showCloseIcon: true,
        closeIconColor: colorScheme.surface,
        duration: const Duration(seconds: 30),
        content: Text(
          "An Email Will be Sent to The email provided\nIf the Email Wasn't Found Check Your Spam or Ensure the Email is Correct then Try Again",
          style: TextStyle(color: colorScheme.surface),
          textAlign: TextAlign.center,
        ),
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final topMargin = MediaQuery.of(context).padding.top;
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            height: height - topMargin,
            width: width,
            child: Container(
              alignment: Alignment.bottomCenter,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15.0,
                      vertical: 20,
                    ),
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: FaIcon(
                        FontAwesomeIcons.arrowLeft,
                        size: 25,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: Align(
                      alignment: AlignmentGeometry.topCenter,
                      child: Text(
                        "Forget Your Password?",
                        style: textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                  SizedBox(
                    width: width,
                    height: height,
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Enter Your Email to Reset Your Password",
                            textAlign: TextAlign.center,
                            style: textTheme.bodyLarge!.copyWith(
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          CustomTextFormField(
                            inputType: InputType.email,
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  value.trim().length <= 1 ||
                                  value.trim().length > 70) {
                                return "Please Enter a Valid Email";
                              }
                              return '';
                            },
                            onSaved: (value) {
                              enteredEmail = value;
                            },
                          ),
                          const SizedBox(height: 10),
                          TextButton.icon(
                            style: TextButton.styleFrom(
                              backgroundColor: colorScheme.onSurface.withValues(
                                alpha: 0.7,
                              ),
                            ),
                            onPressed: () {
                              sendForgetPasswordEmail(colorScheme);
                            },
                            label: Text(
                              "Send Password Reset Link",
                              style: textTheme.bodyMedium!.copyWith(
                                color: colorScheme.surface,
                              ),
                            ),
                            icon: Icon(
                              Icons.mail_rounded,
                              color: colorScheme.surface,
                            ),
                          ),
                        ],
                      ),
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

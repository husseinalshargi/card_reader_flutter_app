import 'package:card_reader_app/Data/Enums/global_enums.dart';
import 'package:card_reader_app/Widgets/custom_check_box.dart';
import 'package:card_reader_app/Widgets/custom_submit_button.dart';
import 'package:card_reader_app/Widgets/custom_text_form_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key, required this.firebaseInstance});
  final FirebaseAuth firebaseInstance;

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  bool isCheckBoxSelected = false;
  late final SharedPreferences prefs;
  final formKey = GlobalKey<FormState>();
  String enteredFirstName = '';
  String enteredLastName = '';
  String enteredEmail = '';
  String enteredPassword = '';
  // ignore: unused_local_variable
  String enteredConfirmPassword = '';

  void _initPrefs() async {
    //get app the settings (keep me signed in until now)
    prefs = await SharedPreferences.getInstance();

    // ensure that the data is updated
    await prefs.reload();
  }

  @override
  void initState() {
    _initPrefs();
    super.initState();
  }

  Future<void> signUp(ColorScheme colorScheme) async {
    // this will do all validation functions
    final isValid = formKey.currentState!.validate();

    if (!isValid) {
      return;
    }

    final UserCredential userCredentials;

    //this will do all onsaved functions
    formKey.currentState!.save();
    try {
      await prefs.setBool("KeepSignedIn", isCheckBoxSelected);
      await prefs.setString("SignInMethod", AuthMethods.emailAndPassword.name);

      userCredentials = await widget.firebaseInstance
          .createUserWithEmailAndPassword(
            email: enteredEmail,
            password: enteredPassword,
          );
    } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          showCloseIcon: true,
          closeIconColor: colorScheme.surface,
          content: Text(
            error.message ?? "Sign Up Failed",
            style: TextStyle(color: colorScheme.surface),
          ),
        ),
      );
      return;
    }

    //create a name for the user after he is created (this will run lastly after all validations)
    await userCredentials.user!.updateDisplayName(
      "$enteredFirstName $enteredLastName",
    );

    userCredentials.user!.reload(); //ensure that the values is updated

    //send a verification email + this will ensure that the email is correct when a user creates an account as it is important for the user to use the services
    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: colorScheme.surface,
          showCloseIcon: true,
          closeIconColor: colorScheme.onSurface,
          content: Text(
            "Email Verification Sent. Check Your Spam if It Wasn't Found.",
            style: TextStyle(color: colorScheme.onSurface),
          ),
        ),
      );
    } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          showCloseIcon: true,
          closeIconColor: colorScheme.surface,
          content: Text(
            error.message ??
                "Verification email Can't be sent, make sure your email is correct or try again later",
            style: TextStyle(color: colorScheme.surface),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Form(
      key: formKey,
      child: Column(
        children: [
          CustomTextFormField(
            inputType: InputType.person,
            label: 'First Name',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please Enter a Valid First Name";
              }
              if (value.trim().length <= 2) {
                return "First Name Should Have More than 2 Characters";
              }
              if (value.trim().length > 30) {
                return "First Name Should Have Less than 30 Characters";
              }
              return '';
            },
            onSaved: (value) {
              enteredFirstName = value;
            },
          ),
          const SizedBox(height: 10),
          CustomTextFormField(
            inputType: InputType.person,
            label: 'Last Name',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please Enter a Valid Last Name";
              }
              if (value.trim().length <= 2) {
                return "Last Name Should Have More than 2 Characters";
              }
              if (value.trim().length > 30) {
                return "Last Name Should Have Less than 30 Characters";
              }
              return '';
            },
            onSaved: (value) {
              enteredLastName = value;
            },
          ),
          const SizedBox(height: 10),
          CustomTextFormField(
            inputType: InputType.email,
            validator: (value) {
              if (value == null ||
                  value.isEmpty ||
                  value.trim().length <= 1 ||
                  value.trim().length > 50) {
                return "Please Enter a Valid Email Address";
              }
              return '';
            },
            onSaved: (value) {
              enteredEmail = value;
            },
          ),
          const SizedBox(height: 10),
          CustomTextFormField(
            inputType: InputType.password,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please Enter a Valid Password";
              }
              if (value.length < 6) {
                return "Password Must be at Least 6 Characters Long";
              }
              //save it in validation first as this will update the value before the validation so that we could compare between the values beform confirm password validation
              enteredPassword = value;

              //no need to check here if it does match as it is important in the confirm only
              return '';
            },
            onSaved: (value) {
              enteredPassword = value;
            },
          ),
          const SizedBox(height: 10),
          CustomTextFormField(
            inputType: InputType.password,
            label: 'Confirm Your Password',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please Enter a Valid Password";
              }
              if (value != enteredPassword) {
                return "Passwords does not Match";
              }

              return '';
            },
            onSaved: (value) {
              enteredConfirmPassword = value;
            },
          ),
          Align(
            alignment: AlignmentGeometry.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: CustomCheckBox(
                isSelectedFunction: (isSelected) {
                  isCheckBoxSelected = isSelected;
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          CustomSubmitButton(
            title: 'Sign Up',
            onTap: () {
              signUp(colorScheme);
            },
          ),
        ],
      ),
    );
  }
}

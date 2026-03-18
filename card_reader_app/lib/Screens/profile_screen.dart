import 'package:card_reader_app/Data/Enums/global_enums.dart';
import 'package:card_reader_app/Screens/current_screen.dart';
import 'package:card_reader_app/Widgets/custom_submit_button.dart';
import 'package:card_reader_app/Widgets/custom_text_form_field.dart';
import 'package:card_reader_app/Widgets/part_splitter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final nameFormKey = GlobalKey<FormState>();
  final emailFormKey = GlobalKey<FormState>();
  final passwordFormKey = GlobalKey<FormState>();

  late String currentFirstName;
  late String currentLastName;
  String newFirstName = '';
  String newLastName = '';

  late String currentEmail;
  String newEmail = '';

  String newPassword = '';
  String confirmPassword = '';
  String oldPassword = '';

  late User? currentUser;

  // bool that is true if the user signed in using google, facebook and more
  Future<bool>? isExternalAuth;

  // a bool to indicate that a button is currently pressed which will be used to disable all buttons until a request is done like changing a name or another field
  bool isRunning = false;

  @override
  void initState() {
    currentUser = FirebaseAuth.instance.currentUser;
    // as we made " " between them
    currentFirstName = currentUser!.displayName!
        .split(" ")
        .first; // get the first value of a list
    currentLastName = currentUser!.displayName!
        .split(" ")
        .last; // get the last value of a list
    currentEmail = currentUser!.email!; //get app the settings

    isExternalAuth = getIsExternalAuth();
    super.initState();
  }

  Future<bool> getIsExternalAuth() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // ensure that the data is updated
    await prefs.reload();

    // get sign in method
    final String? signInMethod = prefs.getString("SignInMethod");
    // if it was true then is isn't external
    // ignore: no_leading_underscores_for_local_identifiers
    bool _isExternalAuth = !(signInMethod == AuthMethods.emailAndPassword.name);

    return _isExternalAuth;
  }

  Future<void> changeName(ColorScheme colorScheme) async {
    // this will do all validation functions
    final isValid = nameFormKey.currentState!.validate();

    if (!isValid) return;
    if (currentUser == null) return;

    //this will do all onsaved functions
    nameFormKey.currentState!.save();
    // to avoid unnecessary update
    // if new first name does not equal old or same for last name
    if (currentFirstName != newFirstName || currentLastName != newLastName) {
      try {
        await currentUser!.updateDisplayName("$newFirstName $newLastName");
      } on FirebaseAuthException catch (error) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            showCloseIcon: true,
            closeIconColor: colorScheme.surface,
            content: Text(
              error.message ?? "Something went wrong please try again later",
              style: TextStyle(color: colorScheme.surface),
            ),
          ),
        );
        return;
      }
    }
    if (!mounted) return;
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const PopScope(canPop: false, child: CurrentScreen()),
      ),
    );
    return;
  }

  Future<void> changeEmail(ColorScheme colorScheme) async {
    // this will do all validation functions
    final isValid = emailFormKey.currentState!.validate();

    if (!isValid) return;
    if (currentUser == null) return;

    //this will do all onsaved functions
    emailFormKey.currentState!.save();

    if (await isExternalAuth == null) {
      //if it isn't loaded
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          showCloseIcon: true,
          closeIconColor: colorScheme.surface,
          content: Text(
            "Something went wrong, try to sign out then sign in again",
            style: TextStyle(color: colorScheme.surface),
          ),
        ),
      );
      return;
    }

    //before changing anything check if the user is signed using email and password not external sign in, if yes continue otherwise don't
    if (await isExternalAuth!) {
      // as we checked if it was null in the condition before
      //show a message that the user can't change email if external
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          showCloseIcon: true,
          closeIconColor: colorScheme.surface,
          content: Text(
            "Can't change email on your sign in method",
            style: TextStyle(color: colorScheme.surface),
          ),
        ),
      );
      return;
    }
    if (newEmail == currentEmail) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          showCloseIcon: true,
          closeIconColor: colorScheme.surface,
          content: Text(
            "Ensure that the email is different than the old email",
            maxLines: 3,
            style: TextStyle(color: colorScheme.surface),
          ),
        ),
      );
      return;
    }
    try {
      await currentUser!.verifyBeforeUpdateEmail(newEmail);
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          showCloseIcon: true,
          closeIconColor: Colors.black,
          backgroundColor: Colors.green,
          content: Text(
            "Verification email sent to your new email confirm it to change your email",
            style: TextStyle(color: Colors.black),
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
            error.message ?? "Something went wrong $error",
            style: TextStyle(color: colorScheme.surface),
          ),
        ),
      );
    }

    // if everything finished
    if (!mounted) return;
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const PopScope(canPop: false, child: CurrentScreen()),
      ),
    );

    return;
  }

  Future<void> changePassword(ColorScheme colorScheme) async {
    // this will do all validation functions
    final isValid = passwordFormKey.currentState!.validate();

    if (!isValid) {
      return;
    }

    //this will do all onsaved functions
    passwordFormKey.currentState!.save();

    if (newPassword != confirmPassword) return;
    if (oldPassword.isEmpty) return;
    if (currentUser == null) return;

    try {
      // re auth the user first with the old password they provided
      AuthCredential credential = EmailAuthProvider.credential(
        email: currentEmail,
        password: oldPassword,
      );
      await currentUser!.reauthenticateWithCredential(credential);
      await currentUser!.updatePassword(newPassword);

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          showCloseIcon: true,
          closeIconColor: Colors.black,
          backgroundColor: Colors.green,
          content: Text(
            "Password Changed successfully",
            style: TextStyle(color: Colors.black),
          ),
        ),
      );

      // log out the user if the password is updated
      await FirebaseAuth.instance.signOut();

      // if everything finished return to the home screen as it is what keeps track if the user is signd in or not
      if (!mounted) return;
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const PopScope(canPop: false, child: CurrentScreen()),
        ),
      );
    } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          showCloseIcon: true,
          closeIconColor: colorScheme.surface,
          content: Text(
            error.message ?? "Something went wrong $error",
            style: TextStyle(color: colorScheme.surface),
          ),
        ),
      );
    }

    return;
  }

  bool isAlphabetsOnly(String str) {
    final RegExp regex = RegExp(r'^[a-zA-Z]+$');
    return regex.hasMatch(str);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final width = MediaQuery.sizeOf(context).width;
    final bottomMargin = MediaQuery.of(context).padding.bottom;
    final textStyle = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: colorScheme.onSurface,
        foregroundColor: colorScheme.surface,
      ),
      body: Padding(
        padding: EdgeInsets.only(bottom: bottomMargin),
        child: SizedBox(
          width: width,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              // change name
              Form(
                key: nameFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const PartSplitter(title: "Name"),
                    CustomTextFormField(
                      initialValue: currentFirstName,
                      inputType: InputType.person,
                      label: "First Name",
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
                        if (!isAlphabetsOnly(value.trim())) {
                          // if not only alpha
                          return "Name should have only Alphabets without space or any special characters";
                        }
                        return '';
                      },
                      onSaved: (value) {
                        newFirstName = value;
                      },
                    ),
                    const SizedBox(height: 5),
                    //last name field
                    CustomTextFormField(
                      initialValue: currentLastName,
                      inputType: InputType.person,
                      label: "Last Name",
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
                        if (!isAlphabetsOnly(value.trim())) {
                          // if not only alpha
                          return "Name should have only Alphabets without space or any special characters";
                        }

                        return '';
                      },
                      onSaved: (value) {
                        newLastName = value;
                      },
                    ),
                    const SizedBox(height: 10),
                    //save the new name
                    CustomSubmitButton(
                      onTap: () {
                        changeName(colorScheme);
                      },
                      title: "Change Your Name",
                    ),
                  ],
                ),
              ),

              // change email
              FutureBuilder(
                future: isExternalAuth,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const PartSplitter(title: "Email"),
                        SizedBox(
                          width: 30,
                          height: 30,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colorScheme.primary.withValues(alpha: 0.8),
                            ),
                            strokeWidth: 3,
                          ),
                        ),
                        Text(
                          "If it took so long try to re-authenticate",
                          style: textStyle.bodySmall!.copyWith(
                            color: colorScheme.primary.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    );
                  }

                  return Form(
                    key: emailFormKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const PartSplitter(title: "Email"),
                        //current email
                        CustomTextFormField(
                          inputType: InputType.email,
                          label: "Current Email",
                          validator: (value) {
                            return '';
                          },
                          onSaved: (value) {
                            return;
                          },
                          initialValue: currentEmail,
                          readOnly: true,
                        ),
                        const SizedBox(height: 5),
                        // snapshot -> isExternal which is true in case of external
                        if (!snapshot.hasData)
                          Text(
                            "Something went wrong try to re-authenticate or change sign in method if it was external",
                            style: textStyle.bodySmall!.copyWith(
                              color: colorScheme.primary.withValues(alpha: 0.8),
                            ),
                          ),
                        if (snapshot.data!)
                          Text(
                            "Can't change email on your sign in method (external sign in)",
                            style: textStyle.bodySmall!.copyWith(
                              color: colorScheme.primary.withValues(alpha: 0.8),
                            ),
                          ),
                        if (!snapshot.data!)
                          // this means false to external sign in
                          //New email field
                          CustomTextFormField(
                            inputType: InputType.email,
                            label: "New Email",
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  value.trim().length <= 1 ||
                                  value.trim().length > 70 ||
                                  !value.trim().contains("@") ||
                                  !value.trim().contains(".")) {
                                return "Please Enter a Valid Email Address";
                              }
                              return '';
                            },
                            onSaved: (value) {
                              newEmail = value;
                            },
                          ),
                        const SizedBox(height: 10),
                        //save the new email
                        if (!snapshot.data!)
                          CustomSubmitButton(
                            onTap: () async {
                              await changeEmail(colorScheme);
                            },
                            title: "Change Your Email",
                          ),
                      ],
                    ),
                  );
                },
              ),

              // change password
              FutureBuilder(
                future: isExternalAuth,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const PartSplitter(title: "Password"),
                        SizedBox(
                          width: 30,
                          height: 30,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colorScheme.primary.withValues(alpha: 0.8),
                            ),
                            strokeWidth: 3,
                          ),
                        ),
                        Text(
                          "If it took so long try to re-authenticate",
                          style: textStyle.bodySmall!.copyWith(
                            color: colorScheme.primary.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    );
                  }
                  return Form(
                    key: passwordFormKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const PartSplitter(title: "Password"),
                        // snapshot -> isExternal which is true in case of external
                        if (!snapshot.hasData)
                          Text(
                            "Something went wrong try to re-authenticate or change sign in method if it was external",
                            style: textStyle.bodySmall!.copyWith(
                              color: colorScheme.primary.withValues(alpha: 0.8),
                            ),
                          ),
                        if (snapshot.data!)
                          Text(
                            "Can't change password on your sign in method (external sign in)",
                            style: textStyle.bodySmall!.copyWith(
                              color: colorScheme.primary.withValues(alpha: 0.8),
                            ),
                          ),
                        if (!snapshot.data!)
                          CustomTextFormField(
                            inputType: InputType.password,
                            label: "Enter Current Password",
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please Enter a Valid Password";
                              }

                              return '';
                            },
                            onSaved: (value) {
                              oldPassword = value;
                            },
                          ),
                        if (!snapshot.data!) const SizedBox(height: 5),
                        if (!snapshot.data!)
                          CustomTextFormField(
                            inputType: InputType.password,
                            label: "New Password",
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please Enter a Valid Password";
                              }
                              if (value.length < 6) {
                                return "Password Must be at Least 6 Characters Long";
                              }
                              //save it in validation first as this will update the value before the validation so that we could compare between the values beform confirm password validation
                              newPassword = value;

                              //no need to check here if it does match as it is important in the confirm only
                              return '';
                            },
                            onSaved: (value) {
                              newPassword = value;
                            },
                          ),
                        if (!snapshot.data!) const SizedBox(height: 5),
                        //New email field
                        if (!snapshot.data!)
                          CustomTextFormField(
                            inputType: InputType.password,
                            label: "Confirm Password",
                            validator: (value) {
                              {
                                if (value == null || value.isEmpty) {
                                  return "Please Enter a Valid Password";
                                }
                                if (value != newPassword) {
                                  return "Passwords does not Match";
                                }

                                return '';
                              }
                            },
                            onSaved: (value) {
                              confirmPassword = value;
                            },
                          ),
                        if (!snapshot.data!) const SizedBox(height: 10),
                        //save the new password
                        if (!snapshot.data!)
                          CustomSubmitButton(
                            onTap: () {
                              changePassword(colorScheme);
                            },
                            title: "Change Your Password",
                          ),
                      ],
                    ),
                  );
                },
              ),
              const PartSplitter(title: "Delete Account"),
              CustomSubmitButton(onTap: () {}, title: "Delete Account"),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:card_reader_app/Data/Enums/global_enums.dart';
import 'package:card_reader_app/Screens/background_screen.dart';
import 'package:card_reader_app/Screens/forgot_password_screen.dart';
import 'package:card_reader_app/Widgets/auth_external_login_methods.dart';
import 'package:card_reader_app/Widgets/auth_icons.dart';
import 'package:card_reader_app/Widgets/custom_check_box.dart';
import 'package:card_reader_app/Widgets/custom_submit_button.dart';
import 'package:card_reader_app/Widgets/custom_text_form_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInForm extends StatefulWidget {
  const SignInForm({super.key, required this.firebaseInstance});
  final FirebaseAuth firebaseInstance;

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final googleSignIn = GoogleSignIn.instance;
  final facebookInstance = FacebookAuth.instance;
  //scopes which is used to get user name email etc...
  final List<String> scopes = [
    "email",
    "https://www.googleapis.com/auth/userinfo.profile",
  ];

  bool isCheckBoxSelected = false;
  String enteredEmail = '';
  String enteredPassword = '';
  late final SharedPreferences prefs;

  void signInUsingGoogle(ColorScheme colorScheme) async {
    try {
      // 1- Authentication request
      //make the google sign in, it might be null if the user cancelled so we addded "?""
      // ignore: unnecessary_nullable_for_final_variable_declarations
      final GoogleSignInAccount? usersGoogleAccount = await googleSignIn
          .authenticate();

      //check if the user cancelled the sign in then do nothing
      if (usersGoogleAccount == null) {
        return;
      }

      // 2- Authentication
      final GoogleSignInAuthentication authenticatedUser =
          usersGoogleAccount.authentication;

      // 3- Authorization
      //get autorization for the required scopes after the user signed in
      final GoogleSignInClientAuthorization authorizedUser =
          await usersGoogleAccount.authorizationClient.authorizeScopes(scopes);

      // 4- finally the credintials of the user which will be passed to firebase auth
      final credential = GoogleAuthProvider.credential(
        accessToken: authorizedUser.accessToken,
        idToken: authenticatedUser.idToken,
      );

      // using firebase create an account with the creds
      final userFireBaseCred = await widget.firebaseInstance
          .signInWithCredential(credential);
      //keep it true in case of external sign in
      await prefs.setBool("KeepSignedIn", true);

      //set how the user signed in to his account
      await prefs.setString("SignInMethod", AuthMethods.google.name);

      //make the user name as the same as what he have in google account, if there wasn't any name then simply write "Google User"
      await userFireBaseCred.user!.updateDisplayName(
        usersGoogleAccount.displayName ?? "Google User",
      );

      //ensure that the values is updated
      userFireBaseCred.user!.reload();
    } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: colorScheme.error,
          showCloseIcon: true,
          closeIconColor: colorScheme.surface,
          content: Text(
            error.message == "account-exists-with-different-credential"
                ? "There is an Account Already With This Email."
                : error.message == "user-disabled"
                ? "User is Currently Disabled"
                : "Something Went Wrong",
            style: TextStyle(color: colorScheme.surface),
            textAlign: TextAlign.center,
          ),
        ),
      );
      print(error.code);
    } catch (error) {
      print(error);
    }
  }

  void signInUsingFacebook(ColorScheme colorScheme) async {
    try {
      //make the user sign in
      final LoginResult facebookUser = await facebookInstance.login(
        permissions: ['email', 'public_profile'],
      );

      //if something went wrong
      if (facebookUser.status == LoginStatus.failed) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: colorScheme.error,
            showCloseIcon: true,
            closeIconColor: colorScheme.surface,
            content: Text(
              "Something Went Wrong, Facebook Auth Failed.\n${facebookUser.message}",
              style: TextStyle(color: colorScheme.surface),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }

      //to ensure that the user didn't cancel or auth failed
      if (facebookUser.status != LoginStatus.success) {
        return;
      }

      // get the user data
      final userData = await facebookInstance.getUserData();

      //get the user creds to place it in firbase auth
      final facebookAuthCredential = FacebookAuthProvider.credential(
        facebookUser.accessToken!.tokenString,
      );

      //finally sing in the user using the creds
      final userFireBaseCred = await widget.firebaseInstance
          .signInWithCredential(facebookAuthCredential);

      //keep it true in case of external sign in
      await prefs.setBool("KeepSignedIn", true);

      //set how the user signed in to his account
      await prefs.setString("SignInMethod", AuthMethods.facebook.name);

      //make the user name as the same as what he have in facebook account, if there wasn't any name then simply write "Facebook User"
      await userFireBaseCred.user!.updateDisplayName(
        userData["name"] ?? "Facebook User",
      );
    } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: colorScheme.error,
          showCloseIcon: true,
          closeIconColor: colorScheme.surface,
          content: Text(
            error.message == "account-exists-with-different-credential"
                ? "There is an Account Already With This Email."
                : error.message == "user-disabled"
                ? "User is Currently Disabled"
                : "Something Went Wrong",
            style: TextStyle(color: colorScheme.surface),
            textAlign: TextAlign.center,
          ),
        ),
      );
      print(error.code);
    } catch (error) {
      print(error);
    }
  }

  void _initPrefs() async {
    // get app the settings (keep me signed in until now)
    prefs = await SharedPreferences.getInstance();

    // ensure that the data is updated
    await prefs.reload();
  }

  void _initGoogleAuth() async {
    //init google sign in and await it to ensure that it fetches the client id
    await googleSignIn.initialize(clientId: "");
  }

  @override
  void initState() {
    super.initState();
    //init shared prefrences (to allow remember me)
    _initPrefs();
    _initGoogleAuth();
  }

  final formKey = GlobalKey<FormState>();

  void signIn(ColorScheme colorScheme) async {
    // this will do all validation functions
    final isValid = formKey.currentState!.validate();

    if (!isValid) {
      return;
    }

    //this will do all onsaved functions
    formKey.currentState!.save();
    try {
      await prefs.setBool("KeepSignedIn", isCheckBoxSelected);
      //set how the user signed in to his account
      await prefs.setString("SignInMethod", AuthMethods.emailAndPassword.name);

      await widget.firebaseInstance.signInWithEmailAndPassword(
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
            error.code == "invalid-email" ||
                    error.code == "user-not-found" ||
                    error.code == "wrong-password" ||
                    error.code == "INVALID_LOGIN_CREDENTIALS" ||
                    error.code == "invalid-credential"
                ? "Sign In Failed, Wrong Email or Password"
                : error.message ?? "Something Went Wrong, Try Again Later",
            style: TextStyle(color: colorScheme.surface),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final colorScheme = Theme.of(context).colorScheme;

    return Form(
      key: formKey,
      child: Column(
        children: [
          CustomTextFormField(
            inputType: InputType.email,
            validator: (value) {
              if (value == null ||
                  value.isEmpty ||
                  value.trim().length <= 1 ||
                  value.trim().length > 70 ||
                  !value.trim().contains("@") ||
                  !value.trim().contains(".")) {
                return "Please Enter a Valid Email";
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
              if (value == null ||
                  value.isEmpty ||
                  value.trim().length <= 1 ||
                  value.trim().length > 50) {
                return "Please Enter a Valid Value";
              }
              return '';
            },
            onSaved: (value) {
              enteredPassword = value;
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Wrap(
              direction: Axis.horizontal,
              children: [
                CustomCheckBox(
                  isSelectedFunction: (isSelected) {
                    isCheckBoxSelected = isSelected;
                  },
                ),
                SizedBox(width: width / 4),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const BackgroundScreen(
                              scaffoldWidget: ForgotPasswordScreen(),
                            ),
                      ),
                    );
                  },
                  child: Text(
                    "Forgot Password?",
                    style: TextStyle(
                      color: colorScheme.tertiary,
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                      decorationColor: colorScheme.tertiary,
                      decorationThickness: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          CustomSubmitButton(
            title: 'Sign In',
            onTap: () {
              signIn(colorScheme);
            },
          ),
          const SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              height: 20,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      height: 2,
                      width: double.infinity,
                      color: colorScheme.primary.withValues(alpha: 0.6),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Center(
                      child: Text(
                        "Or Sign In With",
                        style: TextStyle(
                          color: colorScheme.primary.withValues(alpha: 0.6),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 2,
                      width: double.infinity,
                      color: colorScheme.primary.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsetsGeometry.symmetric(
              vertical: 5,
              horizontal: 20,
            ),
            child: AuthExternalLoginMethods(
              signInMethods: [
                AuthIcons(
                  iconEnum: AuthIcon.facebookIcon,
                  externalAuthMethod: () {
                    signInUsingFacebook(colorScheme);
                  },
                ),
                if (GoogleSignIn.instance
                    .supportsAuthenticate()) //checks if the user could sign in using google in his device
                  AuthIcons(
                    iconEnum: AuthIcon.googleIcon,
                    externalAuthMethod: () {
                      signInUsingGoogle(colorScheme);
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

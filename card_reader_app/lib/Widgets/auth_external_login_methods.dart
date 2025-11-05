import 'package:card_reader_app/Widgets/auth_icons.dart';
import 'package:flutter/material.dart';

class AuthExternalLoginMethods extends StatelessWidget {
  const AuthExternalLoginMethods({super.key, required this.signInMethods});
  final List<AuthIcons> signInMethods;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [for (var icon in signInMethods) icon],
    );
  }
}

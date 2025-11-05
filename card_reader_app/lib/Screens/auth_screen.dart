import 'package:card_reader_app/Widgets/auth_background.dart';
import 'package:flutter/material.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    //get the size of the top bar of the phone
    final topbarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(height: topbarHeight + 10),
            Text(
              "Welcome!",
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge!.copyWith(
                fontSize: 64,
                color: colorScheme.surface,
              ),
            ),
            Text(
              "To Your Intelligent Card\n Reading App!",
              textAlign: TextAlign.center,
              style: textTheme.bodySmall!.copyWith(
                color: colorScheme.surface,
                fontSize: 14,
              ),
            ),
            const AuthBackground(),
          ],
        ),
      ),
    );
  }
}

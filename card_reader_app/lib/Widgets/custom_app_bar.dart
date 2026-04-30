import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.allowBackScreen,
    required this.screenTitle,
  });
  final bool allowBackScreen;
  final String screenTitle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme;

    return AppBar(
      //line dividing app bar
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(5),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            height: 5,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: colorScheme.secondary.withValues(alpha: 0.3),
            ),
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      centerTitle: true,
      title: Text(
        screenTitle,
        style: textStyle.titleLarge!.copyWith(
          color: colorScheme.secondary,
          fontSize: 30,
        ),
      ),
      //this will make leading button (back button) not work automatically it is only called through "allowBackScreen"
      leading: allowBackScreen
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          : null, //in case we don't want the user to go back show the other leading widget
      iconTheme: IconThemeData(color: colorScheme.secondary, size: 40),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum AuthIcon {
  twitterIcon(FontAwesomeIcons.twitter),
  facebookIcon(FontAwesomeIcons.facebookF),
  googleIcon(FontAwesomeIcons.google);

  final IconData icon;
  const AuthIcon(this.icon);
}

class AuthIcons extends StatelessWidget {
  const AuthIcons({
    super.key,
    required this.iconEnum,
    required this.externalAuthMethod,
  });
  final AuthIcon iconEnum;
  final void Function() externalAuthMethod;

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    return Material(
      child: Ink(
        width: 35,
        height: 35,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colorScheme.scrim.withValues(alpha: 0.6),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12.5),
          splashColor: colorScheme.surface.withValues(alpha: 0.25),
          onTap: externalAuthMethod,
          child: Center(
            child: FaIcon(iconEnum.icon, color: colorScheme.surface, size: 25),
          ),
        ),
      ),
    );
  }
}

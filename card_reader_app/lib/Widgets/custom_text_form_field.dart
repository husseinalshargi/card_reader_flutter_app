import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum InputType { email, password, person, other, phoneNumber }

class CustomTextFormField extends StatefulWidget {
  const CustomTextFormField({
    super.key,
    required this.inputType,
    this.label = '',
    this.fontAwesomeIcon = FontAwesomeIcons.question,
    this.initialValue = '',
    this.readOnly = false,
    required this.validator,
    required this.onSaved,
  });
  final bool readOnly;
  final String label;
  final InputType inputType;
  final IconData fontAwesomeIcon;
  final String Function(String? value) validator;
  final void Function(String value) onSaved;
  final String initialValue;

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  bool isPasswordVisible = false;
  IconData passwordIcon = FontAwesomeIcons.eyeSlash;

  void changePasswordVisibility() {
    setState(() {
      isPasswordVisible = !isPasswordVisible;
      passwordIcon = isPasswordVisible
          ? FontAwesomeIcons.eye
          : FontAwesomeIcons.eyeSlash;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: width - 40,
        minHeight: height / 20,
        maxHeight: height / 11,
      ),
      child: Material(
        borderRadius: BorderRadius.circular(15),
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.5),
        child: TextFormField(
          //functions
          validator: (value) {
            final validationMessage = widget.validator(value);
            if (validationMessage.isNotEmpty) {
              return validationMessage;
            }
            return null;
          },
          onSaved: (newValue) {
            //pass the value to the enterd function (it won't be null as we should set it in validator function)
            widget.onSaved(newValue!);
          },

          obscureText:
              !isPasswordVisible && widget.inputType == InputType.password,
          autocorrect: false,
          keyboardType: widget.inputType == InputType.email
              ? TextInputType.emailAddress
              : widget.inputType == InputType.password
              ? TextInputType.visiblePassword
              : widget.inputType == InputType.person
              ? TextInputType.name
              : widget.inputType == InputType.phoneNumber
              ? TextInputType.phone
              : TextInputType.text,
          style: textTheme.bodyLarge!.copyWith(
            color: colorScheme.primary.withValues(alpha: 0.6),
          ),
          decoration: InputDecoration(
            errorMaxLines: 3,
            prefix: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: widget.inputType == InputType.password
                  ? InkWell(
                      onTap: changePasswordVisibility,
                      child: FaIcon(passwordIcon),
                    )
                  : FaIcon(
                      widget.inputType == InputType.email
                          ? FontAwesomeIcons.inbox
                          : widget.inputType == InputType.person
                          ? FontAwesomeIcons.user
                          : widget.inputType == InputType.phoneNumber
                          ? FontAwesomeIcons.phone
                          : widget.fontAwesomeIcon,
                      color: colorScheme.primary.withValues(alpha: 0.6),
                    ),
            ),
            labelText:
                widget.inputType == InputType.email && widget.label.isEmpty
                ? "Email"
                : widget.inputType == InputType.password && widget.label.isEmpty
                ? "Password"
                : widget.label,
            labelStyle: textTheme.bodyMedium!.copyWith(
              color: colorScheme.primary.withValues(alpha: 0.6),
              fontSize: 15,
            ),
            filled: true,
            fillColor: colorScheme.onPrimary.withValues(alpha: 0.25),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                width: 2,
                color: colorScheme.primary.withValues(alpha: 0.25),
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                width: 2,
                color: colorScheme.primary.withValues(alpha: 1),
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(
                width: 2,
                color: colorScheme.inverseSurface.withValues(alpha: 0.25),
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(
                width: 2,
                color: colorScheme.inverseSurface.withValues(alpha: 1),
              ),
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          initialValue: widget.initialValue,
          readOnly: widget.readOnly,
        ),
      ),
    );
  }
}

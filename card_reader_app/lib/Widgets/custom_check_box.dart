import 'package:flutter/material.dart';

class CustomCheckBox extends StatefulWidget {
  const CustomCheckBox({super.key, required this.isSelectedFunction});
  //makes the value of the bool in the parent as same as in the child
  final void Function(bool isSelected) isSelectedFunction;

  @override
  State<CustomCheckBox> createState() => _CustomCheckBoxState();
}

class _CustomCheckBoxState extends State<CustomCheckBox> {
  bool isSelected = false;

  void _changeSelected() {
    setState(() {
      isSelected = !isSelected;
      widget.isSelectedFunction(isSelected = isSelected);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 130,
      child: TextButton(
        onPressed: _changeSelected,
        child: Row(
          children: [
            Container(
              width: 15,
              height: 15,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(3),
                border: BoxBorder.all(color: colorScheme.primary, width: 2),
              ),
              child: isSelected
                  ? Padding(
                      padding: const EdgeInsets.all(1.5),
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    )
                  : const SizedBox(),
            ),
            const SizedBox(width: 5),
            Text(
              "Remember Me",
              style: TextStyle(color: colorScheme.primary, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

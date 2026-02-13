import 'package:card_reader_app/Widgets/custom_submit_button.dart';
import 'package:card_reader_app/Widgets/take_image.dart';
import 'package:flutter/material.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({
    super.key,
    required this.appbarHeight,
    required this.bottomNavSize,
  });
  final double appbarHeight;
  final double bottomNavSize;

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  bool isThresholdUsed = false;
  bool isSmartCropUsed = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme;
    final width = MediaQuery.sizeOf(context).width;
    final bottomMargin = MediaQuery.of(context).padding.bottom;

    return SizedBox(
      width: width - 30,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(height: widget.appbarHeight + 5),
          // threshold button and it's description
          Row(
            children: [
              const SizedBox(width: 15),
              Switch(
                activeThumbColor: colorScheme.tertiary,
                activeTrackColor: colorScheme.secondary,
                inactiveThumbColor: colorScheme.secondary,
                inactiveTrackColor: colorScheme.onPrimary,
                value: isThresholdUsed,
                onChanged: (newThresholdValue) {
                  setState(() {
                    isThresholdUsed = newThresholdValue;
                  });
                },
              ),
              const SizedBox(width: 20),
              Text(
                "Threshold",
                style: textStyle.titleLarge!.copyWith(
                  color: colorScheme.secondary,
                  fontSize: 35,
                  shadows: [
                    Shadow(
                      offset: const Offset(0, 4),
                      blurRadius: 4,
                      color: Colors.black.withValues(alpha: 0.25),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(width: 15),
              Expanded(
                child: Text(
                  "Useful if the card has different variations of colors",
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          // this is the smart crop button part
          Row(
            children: [
              const SizedBox(width: 15),
              Switch(
                activeThumbColor: colorScheme.tertiary,
                activeTrackColor: colorScheme.secondary,
                inactiveThumbColor: colorScheme.secondary,
                inactiveTrackColor: colorScheme.onPrimary,
                value: isSmartCropUsed,
                onChanged: (newSmartCropValue) {
                  setState(() {
                    isSmartCropUsed = newSmartCropValue;
                  });
                },
              ),
              const SizedBox(width: 20),
              Text(
                "Smart Crop",
                style: textStyle.titleLarge!.copyWith(
                  color: colorScheme.secondary,
                  fontSize: 35,
                  shadows: [
                    Shadow(
                      offset: const Offset(0, 4),
                      blurRadius: 4,
                      color: Colors.black.withValues(alpha: 0.25),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(width: 15),
              Expanded(
                child: Text(
                  "Useful if the card isn’t cropped and the background color is different than the card’s",
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // start of the scanning boxes
          const TakeImage(title: "Front Side of the Card"),
          const SizedBox(height: 10),
          const TakeImage(title: "Back Side of the Card"),

          // scan the card, it takes the images taken 1 maybe 2 then sends it to the backend to be scanned which then it will return the info back to be saved in a new card object
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15),
            child: CustomSubmitButton(onTap: () {}, title: "Scan"),
          ),

          // sized box with the same size as the bottom nav bar to add padding in the bottom also the bottom margin (button used to get out of the app)
          SizedBox(height: widget.bottomNavSize + bottomMargin),
        ],
      ),
    );
  }
}

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';

class TakeImage extends StatefulWidget {
  const TakeImage({super.key, required this.title});
  final String title;
  @override
  State<TakeImage> createState() => _TakeImageState();
}

class _TakeImageState extends State<TakeImage> {
  final ImagePicker picker = ImagePicker();
  Image? currentImageTaken;

  // part of the function is taken from the image picker docs
  Future<void> _onImageButtonPressed(
    ImageSource source, {
    required BuildContext context,
  }) async {
    //ensure we are in the same screen or widget
    if (context.mounted) {
      try {
        //pick an image (take an image or pick one from gallery based on the source)
        final XFile? pickedFile = await picker.pickImage(source: source);

        //make sure the user selected an image otherwise just return from the function
        if (pickedFile == null) return;

        //read the image as bytes which will be converted to an image that will be displayed in the screen
        final Uint8List bytes = await pickedFile.readAsBytes();
        final Image imageFromXFile = Image.memory(bytes);
        setState(() {
          currentImageTaken = imageFromXFile;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.error,
            showCloseIcon: true,
            closeIconColor: Theme.of(context).colorScheme.surface,
            content: Text(
              "Error while taking/choosing the image $e",
              style: TextStyle(color: Theme.of(context).colorScheme.surface),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
    final colorScheme = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme;

    return SizedBox(
      height: height / 4,
      child: Column(
        children: [
          Text(
            widget.title,
            style: textStyle.titleSmall!.copyWith(fontSize: 13),
          ),
          Expanded(
            // for the shadows
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadiusGeometry.circular(25),
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(0, 4),
                    blurRadius: 4,
                    color: Colors.black.withValues(alpha: 0.25),
                  ),
                ],
              ),
              // the button itself
              child: Material(
                color: Colors.transparent,
                child: Ink(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 252, 242, 243),
                    borderRadius: BorderRadiusGeometry.circular(25),
                    border: BoxBorder.all(
                      color: colorScheme.secondary,
                      width: 2,
                    ),
                  ),
                  // camera icon
                  child: InkWell(
                    // here is the logic when the button is pressed
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  const Text(
                                    'Choose a way to select the card image to be scanned',
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      TextButton(
                                        style: TextButton.styleFrom(
                                          backgroundColor: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                          foregroundColor: Theme.of(
                                            context,
                                          ).colorScheme.surface,
                                        ),
                                        onPressed: () {
                                          if (picker.supportsImageSource(
                                            ImageSource.camera,
                                          )) {
                                            _onImageButtonPressed(
                                              ImageSource.camera,
                                              context: context,
                                            );
                                          } else {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).clearSnackBars();
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                backgroundColor: Theme.of(
                                                  context,
                                                ).colorScheme.error,
                                                showCloseIcon: true,
                                                closeIconColor: Theme.of(
                                                  context,
                                                ).colorScheme.surface,
                                                content: Text(
                                                  "Can't take an image, check permessions",
                                                  style: TextStyle(
                                                    color: Theme.of(
                                                      context,
                                                    ).colorScheme.surface,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            );
                                          }
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Camera'),
                                      ),
                                      const SizedBox(width: 5),
                                      TextButton(
                                        style: TextButton.styleFrom(
                                          backgroundColor: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                          foregroundColor: Theme.of(
                                            context,
                                          ).colorScheme.surface,
                                        ),
                                        onPressed: () {
                                          if (picker.supportsImageSource(
                                            ImageSource.gallery,
                                          )) {
                                            _onImageButtonPressed(
                                              ImageSource.gallery,
                                              context: context,
                                            );
                                          } else {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).clearSnackBars();
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                backgroundColor: Theme.of(
                                                  context,
                                                ).colorScheme.error,
                                                showCloseIcon: true,
                                                closeIconColor: Theme.of(
                                                  context,
                                                ).colorScheme.surface,
                                                content: Text(
                                                  "Can't choose an iimage from gallery, check permessions",
                                                  style: TextStyle(
                                                    color: Theme.of(
                                                      context,
                                                    ).colorScheme.surface,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            );
                                          }
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Gallery'),
                                      ),
                                      const SizedBox(width: 5),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Close'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                      return;
                    },
                    //if the image weren't null then show it instead of tak an image widget
                    child: Center(
                      child: SizedBox(
                        width: width / 2,
                        height: height / 5,
                        child:
                            currentImageTaken ??
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  FontAwesomeIcons.solidCamera,
                                  size: width / 4,
                                  color: Colors.black26,
                                ),
                                Text(
                                  "Tap to Take an Image or to Choose from Gallery",
                                  style: textStyle.titleSmall!.copyWith(
                                    fontSize: 15,
                                    color: Colors.black26,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 3,
                                  overflow: TextOverflow.visible,
                                  softWrap: true,
                                ),
                              ],
                            ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

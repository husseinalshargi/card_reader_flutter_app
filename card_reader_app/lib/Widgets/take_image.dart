import 'dart:typed_data';

import 'package:card_reader_app/Data/Providers/scan_request_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';

class TakeImage extends ConsumerStatefulWidget {
  const TakeImage({
    super.key,
    required this.title,
    required this.isFrontOfCard,
  });
  final String title;

  final bool isFrontOfCard;

  @override
  ConsumerState<TakeImage> createState() => _TakeImageState();
}

class _TakeImageState extends ConsumerState<TakeImage> {
  final ImagePicker picker = ImagePicker();

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

        //save the image in the scan request provider based on what part of the card this is
        if (widget.isFrontOfCard) {
          ref
              .read(scanRequestProvider.notifier)
              .updateScanRequest(firstImageXFile: pickedFile);
        } else {
          ref
              .read(scanRequestProvider.notifier)
              .updateScanRequest(secondImageXFile: pickedFile);
        }
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
    // ref is used inside build function
    // to use the scan request provider to save the images and options before the request
    //this will rebuild the widget when it is affected
    final scanRequest = ref.watch(scanRequestProvider);

    XFile? currentXFile = widget.isFrontOfCard
        ? scanRequest.firstImageXFile
        : scanRequest.secondImageXFile;

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
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withValues(alpha: 0.5),
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
                                                  "Can't take an image, check permissions",
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
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withValues(alpha: 0.50),
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
                                                  "Can't choose an image from gallery, check permissions",
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
                                      // this will make it based on this widget not all widgets (check if the current mode is null)
                                      if ((scanRequest.firstImageXFile !=
                                                  null &&
                                              widget.isFrontOfCard) ||
                                          (scanRequest.secondImageXFile !=
                                                  null &&
                                              !widget.isFrontOfCard))
                                        TextButton(
                                          onPressed: () {
                                            ref
                                                .read(
                                                  scanRequestProvider.notifier,
                                                )
                                                .removeImage(
                                                  widget.isFrontOfCard,
                                                );

                                            Navigator.pop(context);
                                          },
                                          child: const Text('remove'),
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
                        child: currentXFile != null
                            ? FutureBuilder(
                                //read the image as bytes which will be converted to an image that will be displayed in the screen
                                future: currentXFile.readAsBytes(),
                                builder:
                                    (
                                      BuildContext context,
                                      AsyncSnapshot<Uint8List> snapshot,
                                    ) {
                                      //while waiting for the image to been shown, show a progress indicator
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }
                                      // if the image for some reason is null (it got after the first null cheeking)
                                      if (!snapshot.hasData) {
                                        return const Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons
                                                  .image_not_supported_outlined,
                                            ),
                                            Text("Image can't be shown"),
                                          ],
                                        );
                                      }
                                      return Image.memory(snapshot.data!);
                                    },
                              )
                            : Column(
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

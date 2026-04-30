import 'dart:convert';

import 'package:card_reader_app/Data/Models/card_details.dart';
import 'package:card_reader_app/Data/Models/scan_request.dart';
import 'package:card_reader_app/Data/Providers/scan_request_notifier.dart';
import 'package:card_reader_app/Screens/background_screen.dart';
import 'package:card_reader_app/Screens/current_screen.dart';
import 'package:card_reader_app/Screens/loading_screen.dart';
import 'package:card_reader_app/Widgets/custom_app_bar.dart';
import 'package:card_reader_app/Widgets/custom_bottom_navigation_bar.dart';
import 'package:card_reader_app/Widgets/custom_submit_button.dart';
import 'package:card_reader_app/Widgets/take_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  bool isThresholdUsed = false;
  bool isSmartCropUsed = false;

  final customBottomNavigationBar = const CustomBottomNavigationBar();

  Future<StreamedResponse>? scanCard(
    BuildContext context,
    ScanRequest scanRequest,
  ) async {
    final currentToken = await FirebaseAuth.instance.currentUser!.getIdToken();

    if (currentToken == null || currentToken.isEmpty) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          showCloseIcon: true,
          closeIconColor: Theme.of(context).colorScheme.surface,
          content: Text(
            "User should sign in again",
            style: TextStyle(color: Theme.of(context).colorScheme.surface),
            textAlign: TextAlign.center,
          ),
        ),
      );
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, firstAnimation, secondaryAnimation) =>
              const CurrentScreen(),
        ),
      );
    }

    // remove null files and convert the list to a list of bytes instead of Xfiles
    final imageBytesList = await Future.wait(
      [
        scanRequest.firstImageXFile,
        scanRequest.secondImageXFile,
      ].nonNulls.map((img) => img.readAsBytes()),
    );

    // instead of:
    // var paint = Paint();
    // paint.color = Colors.black;

    // we will use ..
    // var paint = Paint()
    //   ..color = Colors.black

    var uri = Uri.parse('http://10.0.2.2:8000/process_card');
    var request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = "Bearer $currentToken"
      ..fields['is_binarized'] = scanRequest.isThresholdUsed.toString()
      ..fields['is_extracted'] = scanRequest.isSmartCropUsed.toString();
    int i = 0;
    for (var byte in imageBytesList) {
      request.files.add(
        http.MultipartFile.fromBytes("images", byte, filename: "image_$i.jpg"),
      );
      i++;
    }

    // reset the request for new requests
    ref.read(scanRequestProvider.notifier).resetRequest();

    final response = await request.send();
    return response;
  }

  @override
  Widget build(BuildContext context) {
    // ref is used inside build function
    // to use the scan request provider to save the images and options before the request
    //this will rebuild the widget when it is affected (watch) but (read) wont
    final scanRequest = ref.watch(scanRequestProvider);

    final colorScheme = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme;
    final width = MediaQuery.sizeOf(context).width;
    final topMargin = MediaQuery.of(context).padding.top;

    final appbar = const CustomAppBar(
      allowBackScreen: true,
      screenTitle: "Scan a Card",
    );

    return BackgroundScreen(
      scaffoldWidget: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: appbar,
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: true,
        body: Padding(
          padding: EdgeInsets.only(top: topMargin),
          child: Container(
            width: width,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
            child: Stack(
              children: [
                ListView(
                  padding: EdgeInsets.only(
                    top: appbar.preferredSize.height,
                    left: 15,
                    right: 15,
                    bottom: customBottomNavigationBar.bottomNavSize,
                  ),
                  children: [
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
                            // set the isThreshold in the notifier
                            ref
                                .read(scanRequestProvider.notifier)
                                .updateScanRequest(
                                  isThresholdUsed: newThresholdValue,
                                );
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
                            // set the isThreshold in the notifier
                            ref
                                .read(scanRequestProvider.notifier)
                                .updateScanRequest(
                                  isSmartCropUsed: newSmartCropValue,
                                );
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
                    const TakeImage(
                      title: "Front Side of the Card",
                      isFrontOfCard: true,
                    ),
                    const SizedBox(height: 10),
                    const TakeImage(
                      title: "Back Side of the Card",
                      isFrontOfCard: false,
                    ),

                    // scan the card, it takes the images taken 1 maybe 2 then sends it to the backend to be scanned which then it will return the info back to be saved in a new card object
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15.0,
                        vertical: 15,
                      ),
                      child: CustomSubmitButton(
                        onTap: () async {
                          final firstImageXFile = scanRequest.firstImageXFile;
                          final secondImageXFile = scanRequest.secondImageXFile;

                          if (firstImageXFile == null &&
                              secondImageXFile == null) {
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: colorScheme.error,
                                showCloseIcon: true,
                                closeIconColor: colorScheme.surface,
                                content: Text(
                                  "You should at least select an image to scan",
                                  style: TextStyle(color: colorScheme.surface),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );

                            return;
                          }
                          Navigator.of(context).pushReplacement(
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) => FutureBuilder(
                                future: scanCard(context, scanRequest),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const BackgroundScreen(
                                      scaffoldWidget: LoadingScreen(),
                                    );
                                  }

                                  if (snapshot.hasData &&
                                      snapshot.data!.statusCode == 200) {
                                    final outputStream = snapshot.data!.stream;

                                    return FutureBuilder(
                                      future: outputStream.bytesToString(),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const BackgroundScreen(
                                            scaffoldWidget: LoadingScreen(),
                                          );
                                        }
                                        if (snapshot.hasData) {
                                          // case of success converting to string
                                          try {
                                            //convert from string json to map obj
                                            final cardData = jsonDecode(
                                              snapshot.data!,
                                            );
                                            // from map obj to card details obj
                                            final cardDetails =
                                                CardDetails.fromJson(
                                                  data: cardData,
                                                );

                                            return const CurrentScreen();
                                          } on Exception {
                                            WidgetsBinding.instance
                                                .addPostFrameCallback(
                                                  (_) => ScaffoldMessenger.of(
                                                    context,
                                                  ).clearSnackBars(),
                                                );
                                            WidgetsBinding.instance
                                                .addPostFrameCallback(
                                                  (_) =>
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          backgroundColor:
                                                              colorScheme.error,
                                                          showCloseIcon: true,
                                                          closeIconColor:
                                                              colorScheme
                                                                  .surface,
                                                          content: Text(
                                                            "Something went wrong with your request parse related error",
                                                            style: TextStyle(
                                                              color: colorScheme
                                                                  .surface,
                                                            ),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ),
                                                      ),
                                                );
                                          }
                                        }

                                        WidgetsBinding.instance
                                            .addPostFrameCallback(
                                              (_) => ScaffoldMessenger.of(
                                                context,
                                              ).clearSnackBars(),
                                            );
                                        WidgetsBinding.instance
                                            .addPostFrameCallback(
                                              (_) =>
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      backgroundColor:
                                                          colorScheme.error,
                                                      showCloseIcon: true,
                                                      closeIconColor:
                                                          colorScheme.surface,
                                                      content: Text(
                                                        "Something went wrong with your request (server error)",
                                                        style: TextStyle(
                                                          color: colorScheme
                                                              .surface,
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
                                                  ),
                                            );
                                        return const CurrentScreen();
                                      },
                                    );
                                  }

                                  // WidgetsBinding.instance.addPostFrameCallback((_) => ) is used to show the snackbar even if we were in build
                                  // if there is an error in the server then show the error and go back to the main screen
                                  if (snapshot.hasData &&
                                      snapshot.data!.statusCode != 200) {
                                    final outputStream = snapshot.data!.stream;
                                    WidgetsBinding.instance
                                        .addPostFrameCallback(
                                          (_) => ScaffoldMessenger.of(
                                            context,
                                          ).clearSnackBars(),
                                        );
                                    WidgetsBinding.instance.addPostFrameCallback(
                                      (
                                        _,
                                      ) => ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          backgroundColor: colorScheme.error,
                                          showCloseIcon: true,
                                          closeIconColor: colorScheme.surface,
                                          content: FutureBuilder(
                                            future: outputStream
                                                .bytesToString(),
                                            builder: (context, asyncSnapshot) {
                                              return Text(
                                                "Something went wrong with your request error: ${asyncSnapshot.data}",
                                                style: TextStyle(
                                                  color: colorScheme.surface,
                                                ),
                                                textAlign: TextAlign.center,
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    );
                                    return const CurrentScreen();
                                  }

                                  // case of no data
                                  WidgetsBinding.instance.addPostFrameCallback(
                                    (_) => ScaffoldMessenger.of(
                                      context,
                                    ).clearSnackBars(),
                                  );
                                  WidgetsBinding.instance.addPostFrameCallback(
                                    (_) => ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                          SnackBar(
                                            backgroundColor: colorScheme.error,
                                            showCloseIcon: true,
                                            closeIconColor: colorScheme.surface,
                                            content: Text(
                                              "Something went wrong (Server did not respond)",
                                              style: TextStyle(
                                                color: colorScheme.surface,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                  );
                                  return const CurrentScreen();
                                },
                              ),
                            ),
                          );
                        },
                        title: "Scan",
                      ),
                    ),
                  ],
                ),

                //bottom nav bar
                customBottomNavigationBar,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

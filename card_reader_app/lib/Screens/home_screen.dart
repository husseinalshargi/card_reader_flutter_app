import 'package:card_reader_app/Data/Providers/scanned_cards_notifier.dart';
import 'package:card_reader_app/Screens/auth_screen.dart';
import 'package:card_reader_app/Screens/background_screen.dart';
import 'package:card_reader_app/Screens/loading_screen.dart';
import 'package:card_reader_app/Screens/validate_email_screen.dart';
import 'package:card_reader_app/Widgets/custom_app_bar.dart';
import 'package:card_reader_app/Widgets/custom_bottom_navigation_bar.dart';
import 'package:card_reader_app/Widgets/custom_drawer.dart';
import 'package:card_reader_app/Widgets/no_cards_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stroke_text/stroke_text.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  User? currentUser = FirebaseAuth.instance.currentUser;

  void _checkIfUserValidated(BuildContext context) async {
    await currentUser!.reload();
    // check if (not verified)
    if (!currentUser!.emailVerified) {
      await Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const PopScope(
                canPop:
                    false, //user can't go to the home page (hit back button)
                child: BackgroundScreen(scaffoldWidget: ValidateEmailScreen()),
              ),
        ),
      );
    }
  }

  void _checkIfUserAuthenticated(BuildContext context) {
    if (currentUser == null) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const PopScope(canPop: false, child: AuthScreen()),
        ),
      );
    }
  }

  @override
  void initState() {
    //get the current user signed in (it will be null if there isn't any user signed in, we could use it to show the auth screen)
    currentUser = FirebaseAuth.instance.currentUser;

    // make sure if the user isn't logged in (he logged out) return the auth page (replace this page). it wont be needed as we have StreamBuilder but just in case
    _checkIfUserAuthenticated(context);

    // check if the user has a valid email (he validate it)
    _checkIfUserValidated(context);

    super.initState();
  }

  @override
  Widget build(BuildContext screenContext) {
    final scannedCards = ref.watch(scannedCardsProvider);

    final topMargin = MediaQuery.of(screenContext).padding.top;
    final bottomMargin = MediaQuery.of(screenContext).padding.bottom;
    final width = MediaQuery.sizeOf(screenContext).width;
    final colorScheme = Theme.of(screenContext).colorScheme;
    final textStyle = Theme.of(screenContext).textTheme;

    final appbar = const CustomAppBar(
      screenTitle: "Card Reader",
      allowBackScreen: false,
    );

    final drawer = const CustomDrawer();

    final bottomNavigationBar = const CustomBottomNavigationBar();

    return StreamBuilder(
      // to detect if something happen to the user account like email
      stream: FirebaseAuth.instance.idTokenChanges(),
      builder: (context, snapshot) {
        //this could be used to ensure that the user is logged it or has validated email.. etc (instead of the functions defined before)
        //example
        // if (user == null || user.emailVerified == false)

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const BackgroundScreen(scaffoldWidget: LoadingScreen());
        }
        if (!snapshot.hasData) {
          return const AuthScreen();
        }
        // it will be there always as hasdata is handeled before
        User? user = snapshot.data;
        // to ensure the user's info is updated (this will ensure the streambuilder notices if the data is changed)
        user!.reload();

        return Scaffold(
          drawer: drawer,
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
                  Padding(
                    padding: EdgeInsets.only(
                      top: appbar.preferredSize.height + 2,
                    ),
                    child: scannedCards.when(
                      data: (data) {
                        // show no cards if there is non in the notifier
                        return data.isEmpty
                            ? const NoCardsWidget()
                            : ListView.builder(
                                padding: const EdgeInsets.only(top: 5),
                                itemCount: data.length + 1,
                                itemBuilder: (context, idx) {
                                  // in case of the last (added length) will be only to provide empty space for the nav bar
                                  if (idx == data.length) {
                                    return SizedBox(
                                      height:
                                          bottomNavigationBar.bottomNavSize +
                                          bottomMargin,
                                    );
                                  }

                                  return Card(
                                    key: Key(data[idx]['id'].toString()),
                                    color: colorScheme.secondary.withValues(
                                      alpha: 0.25,
                                    ),
                                    child: Dismissible(
                                      key: Key(data[idx]['id'].toString()),
                                      confirmDismiss: (direction) async {
                                        //this function instead of always dismiss it will check the returned value if true dismiss
                                        if (direction ==
                                            DismissDirection.startToEnd) {
                                          ref
                                              .read(
                                                scannedCardsProvider.notifier,
                                              )
                                              .removeCard(
                                                id: data[idx]['id'],
                                                context: screenContext,
                                              );
                                          return true;
                                        }
                                        // then do not (this is the op)
                                        return false;
                                      }, //left side to delete
                                      background: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        alignment: Alignment.centerLeft,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                        ),
                                        child: const Icon(
                                          Icons.delete,
                                          color: Colors.white,
                                        ),
                                      ),
                                      secondaryBackground: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        alignment: Alignment.centerRight,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                        ),
                                        child: const Icon(
                                          Icons.share,
                                          color: Colors.white,
                                        ),
                                      ),

                                      child: ListTile(
                                        key: Key(data[idx]['id'].toString()),
                                        minTileHeight: 75,
                                        title: StrokeText(
                                          text: data[idx]['full_name'] ?? "",
                                          textStyle: textStyle.titleMedium!
                                              .copyWith(
                                                color: colorScheme.surface,
                                              ),
                                          strokeColor: colorScheme.primary,
                                          strokeWidth: 3,
                                        ),
                                        subtitle: Padding(
                                          padding: const EdgeInsets.only(
                                            left: 8.0,
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,

                                            children: [
                                              StrokeText(
                                                text:
                                                    data[idx]['company_name'] ??
                                                    "",
                                                textStyle: textStyle.titleSmall!
                                                    .copyWith(
                                                      color:
                                                          colorScheme.surface,
                                                    ),
                                                strokeColor:
                                                    colorScheme.primary,
                                                strokeWidth: 3,
                                              ),
                                              StrokeText(
                                                text: data[idx]['email'] ?? "",
                                                textStyle: textStyle.titleSmall!
                                                    .copyWith(
                                                      color:
                                                          colorScheme.surface,
                                                    ),
                                                strokeColor:
                                                    colorScheme.primary,
                                                strokeWidth: 3,
                                              ),
                                              StrokeText(
                                                text:
                                                    data[idx]["phone_number"] ??
                                                    "",
                                                textStyle: textStyle.titleSmall!
                                                    .copyWith(
                                                      color:
                                                          colorScheme.surface,
                                                    ),
                                                strokeColor:
                                                    colorScheme.primary,
                                                strokeWidth: 3,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                      },
                      error: (data, stackTrace) {
                        return const Center(
                          child: Text("Couldn't fetch all cards"),
                        );
                      },
                      loading: () {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Please Wait...",
                                style: Theme.of(screenContext)
                                    .textTheme
                                    .titleLarge!
                                    .copyWith(color: colorScheme.onSurface),
                              ),
                              const SizedBox(height: 20),
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  //bottom navigation bar
                  bottomNavigationBar,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

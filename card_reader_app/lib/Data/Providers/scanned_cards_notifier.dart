import 'dart:convert';

import 'package:card_reader_app/Data/Enums/global_enums.dart';
import 'package:card_reader_app/Data/Models/card_details.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

// created a notifier as we can alter it but a provider we can't

class ScannedCardsNotifier extends AsyncNotifier<List<Map<String, dynamic>>> {
  FilterType filterType = FilterType.nameAZ;
  // instead a constructor we need to create the instance in a build method
  @override
  Future<List<Map<String, dynamic>>> build() async {
    // build deal with errors and loading automatically
    final cardsList = await _getDataFromAPI();
    return cardsList;
  }

  Future<List<Map<String, dynamic>>> _getDataFromAPI() async {
    final currentToken = await FirebaseAuth.instance.currentUser!.getIdToken();
    var uri = Uri.parse('http://10.0.2.2:8000/get_all_cards');
    var request = http.MultipartRequest('GET', uri)
      ..headers['Authorization'] = "Bearer $currentToken";

    final response = await request.send();

    final responseString = await response.stream.bytesToString();

    // in case the response is an empty list
    if (responseString == "[]") {
      return [];
    }
    final decodedCardsList = jsonDecode(responseString);

    // this will work as we first decode data then convert it
    final List<Map<String, dynamic>> cardsList =
        List<Map<String, dynamic>>.from(decodedCardsList);

    cardsList.sort((a, b) {
      return (a["full_name"] as String).compareTo(b["full_name"] as String) *
          -1;
      //multiply by -1 to reverse
    });

    return cardsList;
  }

  // here is the methods of the notifier

  void changeFilter({required BuildContext context}) {
    // as this will indicate that the object is changed (update all widgets related)
    final cardsList = [...state.value!];
    final nextFilterTypeIndex = filterType.index + 1;

    if (nextFilterTypeIndex >= FilterType.values.length) {
      // reset to the first filter type
      filterType = FilterType.nameAZ;
    } else {
      // change the filter type to the next
      filterType = FilterType.values[nextFilterTypeIndex];
    }
    switch (filterType) {
      case FilterType.nameAZ:
        cardsList.sort((a, b) {
          return (a["full_name"] as String).compareTo(
                b["full_name"] as String,
              ) *
              -1;
          // to reverse we will use * -1
        });
        break;

      case FilterType.nameZA:
        cardsList.sort((a, b) {
          return (a["full_name"] as String).compareTo(b["full_name"] as String);
        });
        break;

      case FilterType.timeNew:
        cardsList.sort((a, b) {
          return (a["id"] as int).compareTo(b["id"] as int) * -1;
        });
        break;

      case FilterType.timeOld:
        cardsList.sort((a, b) {
          return (a["id"] as int).compareTo(b["id"] as int);
        });
        break;
    }

    //show the message
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ScaffoldMessenger.of(context).clearSnackBars(),
    );
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 55),
          elevation: 1000,
          backgroundColor: Colors.transparent,
          content: Container(
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(75),
            ),
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Center(
                child: Text(
                  filterType.filterMessage,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    //change the state to the updated one
    state = AsyncValue.data(cardsList);
  }

  void setError() {
    state = AsyncValue.error(
      "Something went wrong, couldn't fetch all cards",
      StackTrace.current,
    );
  }

  void refreshCardsList() async {
    state = const AsyncValue.loading();

    // in order to automatically handle errors
    state = await AsyncValue.guard<List<Map<String, dynamic>>>(() async {
      return await _getDataFromAPI();
    });
  }

  void addCard(CardDetails cardDetails) {
    final cardDetailsMap = cardDetails.toMap();

    // remove old card to be replaced by the new
    final cardsList = state.value!.where((card) {
      return card["id"] != cardDetailsMap["id"];
    }).toList();

    state = AsyncValue.data([cardDetailsMap, ...cardsList]);
  }

  void removeCard({required int id, required BuildContext context}) async {
    final currentToken = await FirebaseAuth.instance.currentUser!.getIdToken();
    if (currentToken == null || currentToken.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => ScaffoldMessenger.of(context).clearSnackBars(),
      );
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.error,
            showCloseIcon: true,
            closeIconColor: Theme.of(context).colorScheme.surface,
            content: Text(
              "Couldn't fetch user's details try again later or sign out then sign in again",
              style: TextStyle(color: Theme.of(context).colorScheme.surface),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    var uri = Uri.http('10.0.2.2:8000', "/delete_card", {
      "card_id": id.toString(),
    });

    var response = await http.post(
      uri,
      headers: {"Authorization": "Bearer $currentToken"},
    );

    if (response.statusCode != 200) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => ScaffoldMessenger.of(context).clearSnackBars(),
      );
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.error,
            showCloseIcon: true,
            closeIconColor: Theme.of(context).colorScheme.surface,
            content: Text(
              "Couldn't delete card",
              style: TextStyle(color: Theme.of(context).colorScheme.surface),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    } else {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => ScaffoldMessenger.of(context).clearSnackBars(),
      );
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            showCloseIcon: true,
            closeIconColor: Colors.white,
            content: Text(
              "Card deleted successfully",
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
      if (state.hasValue && state.value!.isNotEmpty) {
        state = AsyncValue.data(
          state.value!.where((card) {
            return card["id"] != id;
          }).toList(),
        );
      }
    }
  }
}

//to be able to use the notifier we need to create a variable that will be the provider
// the first thing in the generic type is the notifier class then the class used in the provider
//then in the constructor we will return the notifier to be listened to
final scannedCardsProvider =
    AsyncNotifierProvider<ScannedCardsNotifier, List<Map<String, dynamic>>>(() {
      return ScannedCardsNotifier();
    });

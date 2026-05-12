import 'dart:convert';

import 'package:card_reader_app/Data/Models/card_details.dart';
import 'package:card_reader_app/Data/Providers/scanned_cards_notifier.dart';
import 'package:card_reader_app/Screens/background_screen.dart';
import 'package:card_reader_app/Screens/current_screen.dart';
import 'package:card_reader_app/Widgets/custom_app_bar.dart';
import 'package:card_reader_app/Widgets/custom_submit_button.dart';
import 'package:card_reader_app/Widgets/custom_text_form_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;

class CardDetailsScreen extends ConsumerStatefulWidget {
  const CardDetailsScreen({
    super.key,
    required this.cardDetails,
    required this.createNewCard,
  });
  final CardDetails cardDetails;
  final bool createNewCard;

  @override
  ConsumerState<CardDetailsScreen> createState() {
    return _CardDetailsScreenState();
  }
}

class _CardDetailsScreenState extends ConsumerState<CardDetailsScreen> {
  final cardDetailsFormKey = GlobalKey<FormState>();
  late String newFullName;
  late String newPhoneNumber;
  late String newOfficeNumber;
  late String newWebSite;
  late String newCompanyName;
  late String newEmail;
  late String newAddress;
  late String newJobTitle;
  late String newCity;
  late String newCountry;

  @override
  void initState() {
    newFullName = widget.cardDetails.fullName;
    newPhoneNumber = widget.cardDetails.phoneNumber;
    newOfficeNumber = widget.cardDetails.officeNumber;
    newWebSite = widget.cardDetails.webSite;
    newCompanyName = widget.cardDetails.companyName;
    newEmail = widget.cardDetails.email;
    newAddress = widget.cardDetails.address;
    newJobTitle = widget.cardDetails.jobTitle;
    newCity = widget.cardDetails.city;
    newCountry = widget.cardDetails.country;

    super.initState();
  }

  Future<void> saveCard(
    BuildContext context,
    CardDetailsScreen widget,
    WidgetRef ref,
  ) async {
    final isValid = cardDetailsFormKey.currentState!.validate();

    if (!isValid) return;

    cardDetailsFormKey.currentState!.save();

    try {
      final currentToken = await FirebaseAuth.instance.currentUser!
          .getIdToken();

      var uri = Uri.parse('http://10.0.2.2:8000/upsert_card');

      final Map<String, dynamic> requestCard = {
        "id": widget.cardDetails.id,
        "full_name": newFullName,
        "phone_number": newPhoneNumber,
        "office_number": newOfficeNumber,
        "web_site": newWebSite,
        "company_name": newCompanyName,
        "email": newEmail,
        "address": newAddress,
        "job_title": newJobTitle,
        "city": newCity,
        "country": newCountry,
      };

      final response = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
          'Authorization': "Bearer $currentToken",
        },
        body: jsonEncode(requestCard),
      );

      if (response.statusCode != 200) {
        ScaffoldMessenger.of(context).clearSnackBars();

        (_) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.error,
            showCloseIcon: true,
            closeIconColor: Theme.of(context).colorScheme.surface,
            content: Text(
              "Couldn't save card",
              style: TextStyle(color: Theme.of(context).colorScheme.surface),
              textAlign: TextAlign.center,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).clearSnackBars();

        (_) => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            showCloseIcon: true,
            closeIconColor: Colors.white,
            content: Text(
              "Card saved successfully",
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }

      // now we will add the id from the response (from the db) to the actual card so it will be updated next
      final cardDetailsFromResponseInJson = jsonDecode(response.body);
      CardDetails newCardDetails = CardDetails.fromJson(
        data: cardDetailsFromResponseInJson,
      );

      ref.read(scannedCardsProvider.notifier).addCard(newCardDetails);

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) {
            return const CurrentScreen();
          },
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          showCloseIcon: true,
          closeIconColor: Theme.of(context).colorScheme.surface,
          content: Text(
            "Couldn't Save Card, please try again later, $e",
            style: TextStyle(color: Theme.of(context).colorScheme.surface),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final width = MediaQuery.sizeOf(context).width;
    final topMargin = MediaQuery.of(context).padding.top;
    final bottomMargin = MediaQuery.of(context).padding.bottom;

    final appBar = const CustomAppBar(
      allowBackScreen: true,
      screenTitle: "Card Details",
    );

    return BackgroundScreen(
      scaffoldWidget: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: true,
        extendBodyBehindAppBar: true,
        appBar: appBar,
        body: Padding(
          padding: EdgeInsets.only(top: topMargin),
          child: Container(
            width: width,
            height: double.infinity,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),

            child: Stack(
              children: [
                Form(
                  key: cardDetailsFormKey,
                  child: ListView(
                    padding: EdgeInsets.only(
                      top: appBar.preferredSize.height + 10,
                      bottom: bottomMargin,
                      left: 15,
                      right: 15,
                    ),

                    children: [
                      CustomTextFormField(
                        inputType: InputType.person,
                        label: "Name",
                        validator: (value) {
                          if (value != null && value.length > 255) {
                            return "Field should be less than 255 characters";
                          }
                          return '';
                        },
                        initialValue: widget.cardDetails.fullName,
                        onSaved: (value) {
                          newFullName = value;
                        },
                      ),
                      const SizedBox(height: 10),
                      CustomTextFormField(
                        inputType: InputType.email,
                        label: "Email",
                        validator: (value) {
                          if (value != null && value.length > 255) {
                            return "Field should be less than 255 characters";
                          }
                          return "";
                        },
                        initialValue: widget.cardDetails.email,
                        onSaved: (value) {
                          newEmail = value;
                        },
                      ),
                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: width / 2.3,
                            child: CustomTextFormField(
                              inputType: InputType.person,
                              label: "Job Title",
                              validator: (value) {
                                if (value != null && value.length > 255) {
                                  return "Field should be less than 255 characters";
                                }
                                return "";
                              },
                              initialValue: widget.cardDetails.jobTitle,
                              onSaved: (value) {
                                newJobTitle = value;
                              },
                            ),
                          ),
                          const VerticalDivider(),
                          SizedBox(
                            width: width / 2.3,
                            child: CustomTextFormField(
                              inputType: InputType.other,
                              fontAwesomeIcon: FontAwesomeIcons.building,
                              label: "Company Name",
                              validator: (value) {
                                if (value != null && value.length > 255) {
                                  return "Field should be less than 255 characters";
                                }
                                return "";
                              },
                              initialValue: widget.cardDetails.companyName,
                              onSaved: (value) {
                                newCompanyName = value;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: width / 2.3,
                            child: CustomTextFormField(
                              inputType: InputType.phoneNumber,
                              label: "Phone Number",
                              validator: (value) {
                                if (value != null && value.length > 255) {
                                  return "Field should be less than 255 characters";
                                }
                                return "";
                              },
                              initialValue: widget.cardDetails.phoneNumber,
                              onSaved: (value) {
                                newPhoneNumber = value;
                              },
                            ),
                          ),
                          const VerticalDivider(),
                          SizedBox(
                            width: width / 2.3,
                            child: CustomTextFormField(
                              inputType: InputType.other,
                              fontAwesomeIcon: FontAwesomeIcons.squarePhone,
                              label: "Office Number",
                              validator: (value) {
                                if (value != null && value.length > 255) {
                                  return "Field should be less than 255 characters";
                                }
                                return "";
                              },
                              initialValue: widget.cardDetails.officeNumber,
                              onSaved: (value) {
                                newOfficeNumber = value;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      CustomTextFormField(
                        inputType: InputType.other,
                        fontAwesomeIcon: FontAwesomeIcons.globe,
                        label: "Web Site",
                        validator: (value) {
                          if (value != null && value.length > 255) {
                            return "Field should be less than 255 characters";
                          }
                          return "";
                        },
                        initialValue: widget.cardDetails.webSite,
                        onSaved: (value) {
                          newWebSite = value;
                        },
                      ),
                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: width / 2.3,
                            child: CustomTextFormField(
                              inputType: InputType.other,
                              fontAwesomeIcon: FontAwesomeIcons.city,
                              label: "City",
                              validator: (value) {
                                if (value != null && value.length > 255) {
                                  return "Field should be less than 255 characters";
                                }
                                return "";
                              },
                              initialValue: widget.cardDetails.city,
                              onSaved: (value) {
                                newCity = value;
                              },
                            ),
                          ),
                          const VerticalDivider(),
                          SizedBox(
                            width: width / 2.3,
                            child: CustomTextFormField(
                              inputType: InputType.other,
                              fontAwesomeIcon: FontAwesomeIcons.flag,
                              label: "Country",
                              validator: (value) {
                                if (value != null && value.length > 255) {
                                  return "Field should be less than 255 characters";
                                }
                                return "";
                              },
                              initialValue: widget.cardDetails.country,
                              onSaved: (value) {
                                newCountry = value;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      CustomTextFormField(
                        inputType: InputType.other,
                        fontAwesomeIcon: FontAwesomeIcons.locationPin,
                        label: "Address",
                        validator: (value) {
                          if (value != null && value.length > 255) {
                            return "Field should be less than 255 characters";
                          }
                          return "";
                        },
                        initialValue: widget.cardDetails.address,
                        onSaved: (value) {
                          newAddress = value;
                        },
                      ),
                      const SizedBox(height: 15),
                      CustomSubmitButton(
                        onTap: () {
                          saveCard(context, widget, ref);
                        },
                        title: "Save",
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton.icon(
                            style: TextButton.styleFrom(
                              backgroundColor: colorScheme.primary.withValues(
                                alpha: 0.8,
                              ),
                              foregroundColor: colorScheme.surface,
                            ),
                            onPressed: () {
                              print("Save Contact");
                            },
                            icon: const FaIcon(FontAwesomeIcons.addressBook),
                            label: const Text("Save in Contacts"),
                          ),
                          const VerticalDivider(),
                          TextButton.icon(
                            style: TextButton.styleFrom(
                              backgroundColor: colorScheme.primary.withValues(
                                alpha: 0.8,
                              ),
                              foregroundColor: colorScheme.surface,
                            ),
                            onPressed: () {
                              print("Share Contact");
                            },
                            icon: const FaIcon(FontAwesomeIcons.share),
                            label: const Text("Share Contact"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

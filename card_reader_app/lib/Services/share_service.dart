import 'dart:io';

import 'package:card_reader_app/Data/Models/card_details.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ShareService {
  static Future<void> shareContact(CardDetails cardDetails) async {
    // first step is to create the contact that will be shared
    final Contact contact = Contact(
      name: Name(first: cardDetails.fullName),
      phones: [
        Phone(number: cardDetails.phoneNumber, isPrimary: true),
        Phone(number: cardDetails.officeNumber, isPrimary: false),
      ],
      emails: [Email(address: cardDetails.email, isPrimary: true)],
      addresses: [
        Address(
          formatted: cardDetails.address,
          city: cardDetails.city,
          country: cardDetails.country,
        ),
      ],
      organizations: [
        Organization(
          name: cardDetails.companyName,
          jobTitle: cardDetails.jobTitle,
        ),
      ],
      websites: [Website(url: cardDetails.webSite)],
    );

    // create a VCard string which is used to share contact
    String vCardString = FlutterContacts.vCard.export(contact);

    // create a temp file which then will be shared using share library
    final Directory directory = await getTemporaryDirectory();
    final fileName = "${cardDetails.fullName.replaceAll(" ", "")}_contact.vcf";
    final file = File("${directory.path}/$fileName");

    // put the VCard string within the file now
    await file.writeAsString(vCardString);

    //finally the share functionality
    // in this function the file must be xfile instance not file so we will make one using the file path in the xfile class
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: "Check my card reader contact for: ${cardDetails.fullName}",
      ),
    );
  }
}

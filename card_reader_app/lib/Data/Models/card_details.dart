class CardDetails {
  final int? id;
  String fullName;
  String phoneNumber;
  String officeNumber;
  String webSite;
  String companyName;
  String email;
  String address;
  String jobTitle;
  String city;
  String country;

  CardDetails({
    this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.officeNumber,
    required this.webSite,
    required this.companyName,
    required this.email,
    required this.address,
    required this.jobTitle,
    required this.city,
    required this.country,
  });

  factory CardDetails.fromJson({required Map<String, dynamic> data}) {
    return CardDetails(
      id: data["id"],
      fullName: data["full_name"] ?? "",
      phoneNumber: data["phone_number"] ?? "",
      officeNumber: data["office_number"] ?? "",
      webSite: data["web_site"] ?? "",
      companyName: data["company_name"] ?? "",
      email: data["email"] ?? "",
      address: data["address"] ?? "",
      jobTitle: data["job_title"] ?? "",
      city: data["city"] ?? "",
      country: data["country"] ?? "",
    );
    // dict["something"] will return null in case of something isn't a key in the dict
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "full_name": fullName,
      "phone_number": phoneNumber,
      "office_number": officeNumber,
      "web_site": webSite,
      "company_name": companyName,
      "email": email,
      "address": address,
      "job_title": jobTitle,
      "city": city,
      "country": country,
    };
  }
}

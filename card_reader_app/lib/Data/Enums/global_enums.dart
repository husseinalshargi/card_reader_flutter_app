//used in preference to deal with the user account based on the provider (sign out if he didn't check remember me)
enum AuthMethods { emailAndPassword, google, facebook }

enum FilterType {
  nameAZ("A-Z Filter"),
  nameZA("Z-A Filter"),
  timeNew("New-Old Filter"),
  timeOld("Old-New Filter");

  final String filterMessage;

  const FilterType(this.filterMessage);
}

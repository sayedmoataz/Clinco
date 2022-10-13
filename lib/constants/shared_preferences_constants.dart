class SharedPreferencesConstants {
  static final SharedPreferencesConstants _sharedPreferencesConstants =
      SharedPreferencesConstants._internal();

  factory SharedPreferencesConstants() {
    return _sharedPreferencesConstants;
  }

  SharedPreferencesConstants._internal();

  final isLoggedIn = "is_logged_in";
  final accountType = "account_type";
  final accountStatus = "account_status";
  final userName = "user_name";
  final userEmail = "user_email";
  final userImage = "user_image";
  final userId = "user_id";
  final selectedCountry = "selected_country";
}

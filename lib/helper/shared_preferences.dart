import 'package:shared_preferences/shared_preferences.dart';

import '../constants/shared_preferences_constants.dart';

class AppData {
  static final AppData _appData = AppData._internal();
  SharedPreferences? prefs;

  factory AppData() {
    return _appData;
  }

  AppData._internal();

  Future<SharedPreferences?> getSharedPreferencesInstance() async {
    if (prefs == null)
      await SharedPreferences.getInstance().then((value) => prefs = value);
    return prefs;
  }

  Future<bool?> clearSharedPreferencesData(
          SharedPreferences sharedPreferences) async =>
      await sharedPreferences.clear();

  //isLoggedIn
  bool getIsLoggedIn(SharedPreferences sharedPreferences) =>
      sharedPreferences.getBool(SharedPreferencesConstants().isLoggedIn) ??
      false;

  Future<bool?> setIsLoggedIn(
          SharedPreferences? sharedPreferences, bool? isLoggedIn) async =>
      await sharedPreferences!
          .setBool(SharedPreferencesConstants().isLoggedIn, isLoggedIn!);

  Future<bool?> removeIsLoggedIn(SharedPreferences sharedPreferences) async =>
      await sharedPreferences.remove(SharedPreferencesConstants().isLoggedIn);

  //AccountType
  String? getAccountType(SharedPreferences sharedPreferences) =>
      sharedPreferences.getString(SharedPreferencesConstants().accountType);

  Future<bool?> setAccountType(
          SharedPreferences? sharedPreferences, String? accountType) async =>
      await sharedPreferences!
          .setString(SharedPreferencesConstants().accountType, accountType!);

  Future<bool?> removeAccountType(SharedPreferences sharedPreferences) async =>
      await sharedPreferences.remove(SharedPreferencesConstants().accountType);

  //AccountStatus
  int? getAccountStatus(SharedPreferences sharedPreferences) =>
      sharedPreferences.getInt(SharedPreferencesConstants().accountStatus);

  Future<bool?> setAccountStatus(
          SharedPreferences? sharedPreferences, int? accountStatus) async =>
      await sharedPreferences!
          .setInt(SharedPreferencesConstants().accountStatus, accountStatus!);

  Future<bool?> removeAccountStatus(
          SharedPreferences sharedPreferences) async =>
      await sharedPreferences
          .remove(SharedPreferencesConstants().accountStatus);

  //UserEmail
  String? getUserEmail(SharedPreferences sharedPreferences) =>
      sharedPreferences.getString(SharedPreferencesConstants().userEmail);

  Future<bool?> setUserEmail(
          SharedPreferences? sharedPreferences, String? userEmail) async =>
      await sharedPreferences!
          .setString(SharedPreferencesConstants().userEmail, userEmail!);

  Future<bool?> removeUserEmail(SharedPreferences sharedPreferences) async =>
      await sharedPreferences.remove(SharedPreferencesConstants().userEmail);

  //UserId
  String? getUserId(SharedPreferences sharedPreferences) =>
      sharedPreferences.getString(SharedPreferencesConstants().userId);

  Future<bool?> setUserId(
          SharedPreferences? sharedPreferences, String? userId) async =>
      await sharedPreferences!
          .setString(SharedPreferencesConstants().userId, userId!);

  Future<bool?> removeUserId(SharedPreferences sharedPreferences) async =>
      await sharedPreferences.remove(SharedPreferencesConstants().userId);

  //selectedCountry
  String? getSelectedCountry(SharedPreferences sharedPreferences) =>
      sharedPreferences.getString(SharedPreferencesConstants().selectedCountry);

  Future<bool?> setSelectedCountry(SharedPreferences? sharedPreferences,
          String? selectedCountry) async =>
      await sharedPreferences!.setString(
          SharedPreferencesConstants().selectedCountry, selectedCountry!);

  Future<bool?> removeSelectedCountry(
          SharedPreferences sharedPreferences) async =>
      await sharedPreferences
          .remove(SharedPreferencesConstants().selectedCountry);
}

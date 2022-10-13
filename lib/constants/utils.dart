import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:phone_number/phone_number.dart';

import '../model/user_data.dart';

class Utils {
  static final Utils _utils = Utils._internal();

  factory Utils() => _utils;

  Utils._internal();

  bool isNetworkUrl(String uri) => uri.startsWith('https://');

  String capitalize(String text) =>
      text.replaceFirst(text[0], text[0].toUpperCase());

  bool isPhoneNumberValid(String phoneNumberString) {
    bool isValid = false;
    PhoneNumberUtil plugin = PhoneNumberUtil();
    plugin.carrierRegionCode().then((regionCode) async {
      await plugin
          .validate(phoneNumberString, regionCode: regionCode)
          .then((isPhoneValid) {
        isValid = isPhoneValid;
      });
    });
    return isValid;
  }

  static String getAccountColl(String accountType) {
    AccountTypes type = AccountTypes.values.byName(accountType);
    switch (type) {
      case AccountTypes.Admin:
        return "Admins";
      case AccountTypes.Doctor:
        return "Doctors";
      case AccountTypes.Company:
        return "Companies";
      case AccountTypes.Lab:
        return "Labs";
      case AccountTypes.RaysCenter:
        return "RaysCenter";
      default:
        return "Patients";
    }
  }

  static Future callOnFcmApiSendPushNotifications({
    // required String userId,
    required String token,
    required String notificationTitle,
    required String notificationBody,
    required Map<String, dynamic> notificationData,
  }) async {
    // getAccountColl(accountType)
    var serverKey =
        "AAAA0BI8tCo:APA91bFPHeTBcXyKw-K96_vEfT8qKxn8kfh3ICc9uOMKWzxTjvfQlrTmm_evZo-9BRjTE195M_2gQ41v9yo_efeknpj_VbGITbKiGImCJYWYLtST4Lm4cyUHV4HDxJh78yGmwvzZsmZB";
    // FirebaseFirestore.instance.collection(accountType).doc(userId).get().then((value) async{
    //   if(value.data()!.containsKey("token") && value["token"] != ""){
    //     print("USER DISABLE NOTIFICATION");
    //   }else{
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverKey',
        },
        body: jsonEncode({
          "to": token,
          "notification": {
            'title': notificationTitle,
            'body': notificationBody,
            "click_action": "FLUTTER_NOTIFICATION_CLICK",
            "sound": "default"
          },
          "data": notificationData,
        }),
      );
    } catch (e) {
      print("PUSH NOTIFICATION ERROR CAUSED");
    }
    // }).catchError((error){
    //   print(error);
    // });
  }

  static Future callOnFcmApiSendPushNotificationsWithId({
    required String userId,
    required String accountType,
    required String notificationTitle,
    required String notificationBody,
    required Map<String, dynamic> notificationData,
  }) async {
    // getAccountColl(accountType)
    var serverKey =
        "AAAA0BI8tCo:APA91bFPHeTBcXyKw-K96_vEfT8qKxn8kfh3ICc9uOMKWzxTjvfQlrTmm_evZo-9BRjTE195M_2gQ41v9yo_efeknpj_VbGITbKiGImCJYWYLtST4Lm4cyUHV4HDxJh78yGmwvzZsmZB";
    FirebaseFirestore.instance
        .collection(accountType)
        .doc(userId)
        .get()
        .then((value) async {
      if (value.exists) {
        if (!value.data()!.containsKey("token") || value["token"] == "") {
          print("USER DISABLE NOTIFICATION");
        } else {
          print("ttttttttttttttttttt");
          try {
            await http.post(
              Uri.parse('https://fcm.googleapis.com/fcm/send'),
              headers: <String, String>{
                'Content-Type': 'application/json',
                'Authorization': 'key=$serverKey',
              },
              body: jsonEncode({
                "to": value["token"],
                "notification": {
                  'title': notificationTitle,
                  'body': notificationBody,
                  "click_action": "FLUTTER_NOTIFICATION_CLICK",
                  "sound": "default"
                },
                "data": notificationData,
              }),
            );
          } catch (e) {
            print("PUSH NOTIFICATION ERROR CAUSED");
          }
        }
      }
    }).catchError((error) {
      print(error);
    });
  }
}

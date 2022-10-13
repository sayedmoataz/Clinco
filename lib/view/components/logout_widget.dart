import 'package:clinico/view/components/alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helper/shared_preferences.dart';

class LogoutWidget {
  static final LogoutWidget _singleton = LogoutWidget._internal();

  factory LogoutWidget() => _singleton;

  LogoutWidget._internal();

  showLogoutDialog(BuildContext context) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text(
              'تسجيل الخروج',
              style: TextStyle(color: Colors.black),
              textDirection: TextDirection.rtl,
            ),
            content: const Text('هل متأكد من أنك تريد تسجيل الخروج ؟',
                style: TextStyle(color: Colors.black),
                textDirection: TextDirection.rtl),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, 'Cancel'),
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () => _logout(context),
                child: const Text('نعم'),
              ),
            ],
          )),
    );
  }

  _logout(BuildContext context) async {
    AppData appData = AppData();
    SharedPreferences? pref = await appData.getSharedPreferencesInstance();

    LoadingIndicator dialog = loadingIndicatorWidget();
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return dialog;
        });
    await FirebaseAuth.instance
        .signOut()
        .then((value) async => {
              await appData
                  .setIsLoggedIn(pref, false)
                  .then((value) => {
                        Navigator.pushNamedAndRemoveUntil(context,
                            '/loginScreen', (Route<dynamic> route) => false)
                      })
                  .catchError((error) {
                Fluttertoast.showToast(msg: 'حدث خطأ ما!');
              })
            })
        .catchError((error) {
      Fluttertoast.showToast(msg: 'حدث خطأ ما!');
    });
  }
}

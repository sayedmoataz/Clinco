import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:clinico/model/user_data.dart';
import 'package:clinico/view/components/alert.dart';
import 'package:clinico/view/components/background.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/app_colors.dart';
import '../../helper/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  Color primaryColor = AppColors.primaryColor;
  late final AppData _appData;
  BuildContext? dialogContext;
  DateTime? currentBackPressTime;
  var _email, _password;

  GlobalKey<FormState> formstate = GlobalKey<FormState>();
  bool _isObscure = true;

  @override
  void initState() {
    _appData = AppData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
        onWillPop: onWillPop,
        child: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: Background(
                  child: Form(
                      key: formstate,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 20),
                              child: Text(
                                "تسجيل الدخول",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                    fontSize: 33),
                                textAlign: TextAlign.right,
                              ),
                            ),
                            SizedBox(height: size.height * 0.03),
                            Container(
                              alignment: Alignment.center,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "البريد الالكترونى",
                                    style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  TextFormField(
                                    enableInteractiveSelection: true,
                                    enableSuggestions: true,
                                    style: const TextStyle(fontSize: 18),
                                    textInputAction: TextInputAction.next,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.all(8),
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: const BorderSide(
                                              color: Colors.grey)),
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: const BorderSide(
                                              color: Colors.grey)),
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: const BorderSide(
                                              color: Colors.grey)),
                                      errorBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: const BorderSide(
                                              color: Colors.grey)),
                                      focusedErrorBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: const BorderSide(
                                              color: Colors.grey)),
                                    ),
                                    onSaved: (val) {
                                      _email = val.toString().trim();
                                    },
                                    validator: (val) {
                                      if (val != null) {
                                        if (!EmailValidator.validate(val)) {
                                          return "البريد الإلكتروني غير صالح";
                                        }
                                      }
                                      return null;
                                    },
                                  )
                                ],
                              ),
                            ),
                            SizedBox(height: size.height * 0.015),
                            Container(
                              alignment: Alignment.center,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "كلمة المرور",
                                    style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  TextFormField(
                                    enableInteractiveSelection: true,
                                    textInputAction: TextInputAction.done,
                                    style: const TextStyle(fontSize: 18),
                                    keyboardType: TextInputType.text,
                                    enableSuggestions: false,
                                    autocorrect: false,
                                    obscureText: _isObscure,
                                    onSaved: (val) {
                                      _password = val.toString().trim();
                                    },
                                    validator: (val) {
                                      if (val != null) {
                                        if (val.length > 12) {
                                          return "أقصى عدد أحرف لكلمة المرور هو ١٢";
                                        }
                                        if (val.length < 6) {
                                          return "أقل عدد أحرف لكلمة المرور هو ٦";
                                        }
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.all(8),
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: const BorderSide(
                                                color: Colors.grey)),
                                        enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: const BorderSide(
                                                color: Colors.grey)),
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: const BorderSide(
                                                color: Colors.grey)),
                                        errorBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: const BorderSide(
                                                color: Colors.grey)),
                                        focusedErrorBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: const BorderSide(
                                                color: Colors.grey)),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _isObscure
                                                ? Icons.visibility
                                                : Icons.visibility_off,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _isObscure = !_isObscure;
                                            });
                                          },
                                        )),
                                    // decoration: InputDecoration(
                                    //     labelText: 'كلمة المرور',
                                    //     ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              alignment: Alignment.centerRight,
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 10),
                              child: GestureDetector(
                                onTap: () => {resetPassword()},
                                child: Text(
                                  "نسيت كلمة المرور؟",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.normal,
                                      color: primaryColor),
                                ),
                              ),
                            ),
                            SizedBox(height: size.height * 0.05),
                            Container(
                              alignment: Alignment.center,
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 10),
                              child: ElevatedButton(
                                onPressed: () async {
                                  var user = await signIn();
                                  if (user != null) {
                                    fetchUserDataFromFirestore();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(80.0)),
                                    // textColor: Colors.white,
                                    padding: const EdgeInsets.all(0),
                                    elevation: 0),
                                child: Container(
                                  alignment: Alignment.center,
                                  height: 40.0,
                                  width: size.width * 0.5,
                                  decoration: BoxDecoration(
                                      color: AppColors.primaryColor,
                                      borderRadius: BorderRadius.circular(25)),
                                  // decoration: BoxDecoration(borderRadius: BorderRadius.circular(80.0), gradient: const LinearGradient(colors: [Color.fromARGB(255, 255, 136, 34), Color.fromARGB(255, 255, 177, 41)])),
                                  padding: const EdgeInsets.all(0),
                                  child: const Text(
                                    "دخول",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              alignment: Alignment.center,
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 10),
                              child: GestureDetector(
                                onTap: () => {
                                  Navigator.popAndPushNamed(
                                      context, "/registrationScreen")
                                },
                                child: Text(
                                  "ليس لديك حساب؟ سجل الآن",
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor),
                                ),
                              ),
                            )
                          ],
                        ),
                      ))),
            )));
  }

  Future<void> resetPassword() async {
    var formdata = formstate.currentState;
    formdata!.save();
    if (_email != null &&
        _email.toString().isNotEmpty &&
        EmailValidator.validate(_email)) {
      try {
        await FirebaseAuth.instance
            .sendPasswordResetEmail(email: _email)
            .then((value) {
          AwesomeDialog(
                  context: context,
                  title: "تم بنجاح",
                  body: const Text(
                      "لقد أرسلنا رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني!"),
                  dialogType: DialogType.SUCCES)
              .show();
        });
      } catch (e) {
        AwesomeDialog(
                context: context,
                title: "خطأ",
                body: Text("خطأ: $e"),
                dialogType: DialogType.ERROR)
            .show();
      }
    } else {
      AwesomeDialog(
              context: context,
              title: "خطأ",
              body: const Text("أدخل بريدًا إلكترونيًا صالحًا!"),
              dialogType: DialogType.ERROR)
          .show();
    }
  }

  signIn() async {
    var formdata = formstate.currentState;
    if (formdata!.validate()) {
      formdata.save();
      try {
        LoadingIndicator dialog = loadingIndicatorWidget();
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              dialogContext = context;
              return dialog;
            });
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: _email, password: _password);
        return userCredential;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          Navigator.of(context).pop();
          AwesomeDialog(
                  context: context,
                  title: "خطأ",
                  body: const Text("البريد الإكتروني غير صحيح"),
                  dialogType: DialogType.ERROR)
              .show();
        } else if (e.code == 'wrong-password') {
          Navigator.of(context).pop();
          AwesomeDialog(
                  context: context,
                  title: "خطأ",
                  body: const Text("كلمة المرور غير صحيحة"),
                  dialogType: DialogType.ERROR)
              .show();
        }
      }
    }
  }

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(msg: "إضغط مرة أخرى للخروج من التطبيق");
      return Future.value(false);
    }
    return Future.value(true);
  }

  void fetchUserDataFromFirestore() {
    FirebaseFirestore.instance
        .collection(FirestoreCollections.Users.name)
        .where('email', isEqualTo: _email)
        .get()
        .then((snapshos) {
      QueryDocumentSnapshot<Map<String, dynamic>> queryDocumentSnapshot =
          snapshos.docs.first;
      if (queryDocumentSnapshot.exists) {
        String userId = queryDocumentSnapshot.id;
        Map<String, dynamic> map = queryDocumentSnapshot.data();
        UserData userData = UserData.fromJson(map);
        saveUserDataInSharedPreferences(userData, userId);
      }
    });
  }

  Future<void> saveUserDataInSharedPreferences(
      UserData userData, String userId) async {
    SharedPreferences? pref = await _appData.getSharedPreferencesInstance();
    await _appData.setIsLoggedIn(pref, true);
    await _appData.setAccountType(pref, userData.accountType);
    await _appData.setAccountStatus(pref, userData.accountStatus);
    await _appData.setUserEmail(pref, userData.email);
    await _appData.setSelectedCountry(pref, userData.selectedCountry);
    await _appData.setUserId(pref, userId);
    FirebaseMessaging.instance.getToken().then((value) {
      FirebaseFirestore.instance
          .collection(getAccountColl(userData.accountType!))
          .doc(userId)
          .update({
        "token": value.toString(),
      });
    }).catchError((error) {});
    Navigator.pushNamedAndRemoveUntil(
        context,
        getNextHomeScreenRouteName(userData.accountType!),
        (Route<dynamic> route) => false);
  }

  String getNextHomeScreenRouteName(String accountType) {
    AccountTypes type = AccountTypes.values.byName(accountType);
    switch (type) {
      case AccountTypes.Admin:
        return "/adminHomeScreen";
      case AccountTypes.Doctor:
        return "/doctorHomeScreen";
      case AccountTypes.Company:
        return "/companyHomeScreen";
      case AccountTypes.Lab:
        return "/labHomeScreen";
      case AccountTypes.RaysCenter:
        return "/raysCenterHomeScreen";
      default:
        return "/patientHomeScreen";
    }
  }

  String getAccountColl(String accountType) {
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
}

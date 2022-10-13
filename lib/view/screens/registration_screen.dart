import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:clinico/model/company.dart';
import 'package:clinico/model/doctor.dart';
import 'package:clinico/model/labs.dart';
import 'package:clinico/model/patient.dart';
import 'package:clinico/model/rays.dart';
import 'package:clinico/model/user_data.dart';
import 'package:clinico/view/components/background.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/account_constants.dart';
import '../../constants/app_colors.dart';
import '../../helper/shared_preferences.dart';
import '../../model/selected_speciality.dart';
import '../components/alert.dart';
import 'doctor_part/doctor_level_selection_screen.dart';
import 'doctor_part/doctor_speciality_selection_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  Color primaryColor = AppColors.primaryColor;
  late final AppData _appData;
  BuildContext? dialogContext;
  DateTime? currentBackPressTime;
  var _name, _email, _password;
  String? selectedDoctorLevel;
  SelectedSpeciality? selectedDoctorSpeciality;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  String _selectedCountry = Countries.Egypt.name;
  var _accountType = AccountTypes.Patient.name;
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
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 20),
                              child: Text(
                                "إنشاء حساب جديد",
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
                                    "الإسم",
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
                                    textInputAction: TextInputAction.next,
                                    style: const TextStyle(fontSize: 20),
                                    keyboardType: TextInputType.name,
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
                                      _name = val.toString().trim();
                                    },
                                    validator: (val) {
                                      String text = val.toString().trim();
                                      if (text.length > 30) {
                                        return 'أقصى عدد للأحرف هو ٣٠';
                                      }
                                      if (text.length < 5) {
                                        return 'أقل عدد للأحرف هو ٥';
                                      }
                                      return null;
                                    },
                                    maxLength: 30,
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
                                      "البريد الإلكتروني",
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
                                      textInputAction: TextInputAction.next,
                                      style: const TextStyle(fontSize: 20),
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
                                    ),
                                  ],
                                )),
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
                                      style: const TextStyle(fontSize: 20),
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
                                          contentPadding:
                                              const EdgeInsets.all(8),
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
                                          focusedErrorBorder:
                                              OutlineInputBorder(
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
                                )),
                            SizedBox(height: size.height * 0.015),
                            Container(
                                alignment: Alignment.centerLeft,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 40),
                                child: Row(
                                  children: [
                                    const SizedBox(
                                      width: 70,
                                      child: Text('الدولة',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.normal,
                                              color: Colors.black)),
                                    ),
                                    Container(
                                      alignment: Alignment.centerLeft,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 40),
                                      child: DropdownButton<String>(
                                        value: _selectedCountry,
                                        icon: const Icon(
                                            FontAwesomeIcons.caretDown),
                                        elevation: 16,
                                        style:
                                            const TextStyle(color: Colors.grey),
                                        underline: null,
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            _selectedCountry = newValue!;
                                          });
                                        },
                                        items: getCountries()
                                            .map<DropdownMenuItem<String>>(
                                                (Countries value) {
                                          return DropdownMenuItem<String>(
                                            value: value.name,
                                            child: Text(
                                                arabicCountriesNames[
                                                    value.index],
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color: Colors.black)),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ],
                                )),
                            SizedBox(height: size.height * 0.015),
                            Container(
                                alignment: Alignment.centerLeft,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 40),
                                child: Row(
                                  children: [
                                    const SizedBox(
                                      width: 70,
                                      child: Text('نوع الحساب',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.normal,
                                              color: Colors.black)),
                                    ),
                                    Container(
                                      alignment: Alignment.centerLeft,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 40),
                                      child: DropdownButton<String>(
                                        value: _accountType,
                                        icon: const Icon(
                                            FontAwesomeIcons.caretDown),
                                        elevation: 16,
                                        style:
                                            const TextStyle(color: Colors.grey),
                                        underline: null,
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            _accountType = newValue!;
                                          });
                                        },
                                        items: getRegistrationAccountTypeList()
                                            .map<DropdownMenuItem<String>>(
                                                (AccountTypes value) {
                                          return DropdownMenuItem<String>(
                                            value: value.name,
                                            child: Text(
                                                arabicAccountTypes[value.index],
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color: Colors.black)),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ],
                                )),
                            SizedBox(height: size.height * 0.015),
                            Visibility(
                                visible:
                                    _accountType == AccountTypes.Doctor.name,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 40),
                                  child: Row(
                                    children: [
                                      TextButton(
                                        style: ButtonStyle(
                                            foregroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(Colors.white),
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(Colors.blue)),
                                        onPressed: () =>
                                            _startDoctorLevelSelectionScreen(
                                                context),
                                        child: Text(selectedDoctorLevel ??
                                            'إختيار مستوى الطبيب'),
                                      ),
                                      SizedBox(width: size.width * 0.03),
                                      TextButton(
                                        style: ButtonStyle(
                                            foregroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(Colors.white),
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(Colors.blue)),
                                        onPressed: () =>
                                            _startSpecialitySelectionScreen(
                                                context),
                                        child: Text(selectedDoctorSpeciality
                                                ?.speciality.arabicTitle ??
                                            'إختيار تخصص الطبيب'),
                                      ),
                                    ],
                                  ),
                                )),
                            SizedBox(height: size.height * 0.02),
                            Container(
                              alignment: Alignment.center,
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 6),
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (_accountType ==
                                          AccountTypes.Doctor.name &&
                                      (selectedDoctorLevel == null ||
                                          selectedDoctorSpeciality == null)) {
                                    Fluttertoast.showToast(
                                        msg:
                                            'برجاء التأكد من إدخال جميع البيانات المطلوبة!');
                                    return;
                                  }
                                  UserCredential user = await signUp();
                                  if (user.user != null) {
                                    createAccountInFirestore(user.user!.uid);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(80.0)),
                                  // textColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.all(0),
                                ),
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
                              alignment: Alignment.centerLeft,
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 10),
                              child: GestureDetector(
                                onTap: () => {
                                  Navigator.popAndPushNamed(
                                      context, "/loginScreen")
                                },
                                child: Text(
                                  "لديك حساب بالفعل؟ تسجيل الدخول",
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

  signUp() async {
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
            .createUserWithEmailAndPassword(email: _email, password: _password);
        return userCredential;
      } on FirebaseAuthException catch (e) {
        Navigator.of(context).pop();
        AwesomeDialog(
                context: context,
                title: "خطأ",
                body: Text("خطأ: $e"),
                dialogType: DialogType.ERROR)
            .show();
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

  void createAccountInFirestore(String userId) {
    int accountStatus = 0;
    if (_accountType == AccountTypes.Patient.name) accountStatus = 1;
    UserData userData =
        UserData(_email, _selectedCountry, _accountType, accountStatus);
    DocumentReference userDocumentReference = _firebaseFirestore
        .collection(FirestoreCollections.Users.name)
        .doc(userId);
    userDocumentReference.set(userData.toJson()).then((value) {
      createSpecifiedAccountByType(userData, userId);
    }).catchError((e) {
      AwesomeDialog(
              context: context,
              title: "خطأ",
              body: Text("خطأ: $e"),
              dialogType: DialogType.ERROR)
          .show();
    });
  }

  void createSpecifiedAccountByType(UserData userData, String userId) async {
    String token = "";
    await FirebaseMessaging.instance.getToken().then((value) {
      if (value != null) token = value.toString();
    }).catchError((error) {});
    AccountTypes type =
        AccountTypes.values.byName(userData.accountType.toString());
    DocumentReference documentReference;
    Map<String, dynamic> jsonObject;
    switch (type) {
      case AccountTypes.Doctor:
        {
          documentReference = _firebaseFirestore
              .collection(FirestoreCollections.Doctors.name)
              .doc(userId);
          jsonObject = Doctor(
                  userId,
                  userData.email,
                  userData.selectedCountry,
                  '',
                  _name,
                  selectedDoctorSpeciality?.id,
                  '',
                  '',
                  selectedDoctorLevel,
                  [],
                  userData.accountStatus,
                  token)
              .toJson();
        }
        break;
      case AccountTypes.Company:
        {
          documentReference = _firebaseFirestore
              .collection(FirestoreCollections.Companies.name)
              .doc(userId);
          jsonObject = Company(userId, userData.email, userData.selectedCountry,
                  '', _name, '', '', '', [], userData.accountStatus, token)
              .toJson();
        }
        break;
      case AccountTypes.Lab:
        {
          documentReference = _firebaseFirestore
              .collection(FirestoreCollections.Labs.name)
              .doc(userId);
          // jsonObject = Company(userId, userData.email, userData.selectedCountry, '', _name, '', '', '', [], userData.accountStatus).toJson();
          jsonObject = Labs(
                  accountStatus: userData.accountStatus,
                  name: _name,
                  email: userData.email,
                  image: "",
                  address: "",
                  userId: userId,
                  phoneNumber: "",
                  selectedCountry: userData.selectedCountry,
                  description: "",
                  token: token)
              .toJson();
        }
        break;
      case AccountTypes.RaysCenter:
        {
          documentReference = _firebaseFirestore
              .collection(FirestoreCollections.RaysCenter.name)
              .doc(userId);
          jsonObject = Rays(
                  accountStatus: userData.accountStatus,
                  name: _name,
                  email: userData.email,
                  image: "",
                  address: "",
                  userId: userId,
                  phoneNumber: "",
                  selectedCountry: userData.selectedCountry,
                  description: "",
                  token: token)
              .toJson();
        }
        break;
      default:
        {
          documentReference = _firebaseFirestore
              .collection(FirestoreCollections.Patients.name)
              .doc(userId);
          jsonObject = Patient(userId, userData.email, userData.selectedCountry,
                  '', _name, '', userData.accountStatus, token)
              .toJson();
        }
    }

    documentReference.set(jsonObject).then((value) {
      saveUserDataInSharedPreferences(userData, userId);
    }).catchError((e) {
      AwesomeDialog(
              context: context,
              title: "Error",
              body: Text("Error: $e"),
              dialogType: DialogType.ERROR)
          .show();
    });
  }

  Future<void> saveUserDataInSharedPreferences(
      UserData userData, String userId) async {
    SharedPreferences? pref = await _appData.getSharedPreferencesInstance();
    await _appData.setIsLoggedIn(pref, true);
    await _appData.setUserId(pref, userId);
    await _appData.setSelectedCountry(pref, userData.selectedCountry);
    await _appData.setAccountType(pref, userData.accountType);
    await _appData.setAccountStatus(pref, userData.accountStatus);
    Fluttertoast.showToast(msg: "تم إنشاء الحساب بنجاح!");
    Navigator.pushNamedAndRemoveUntil(
        context,
        getNextHomeScreenRouteName(userData.accountType!),
        (Route<dynamic> route) => false);
  }

  String getNextHomeScreenRouteName(String accountType) {
    AccountTypes type = AccountTypes.values.byName(accountType);
    switch (type) {
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

  _startDoctorLevelSelectionScreen(BuildContext context) async =>
      await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const DoctorLevelSelectionScreen()))
          .then((value) => {
                if (value != null)
                  {
                    setState(() {
                      selectedDoctorLevel = value as String;
                    })
                  }
              });

  _startSpecialitySelectionScreen(BuildContext context) async =>
      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  const DoctorSpecialitySelectionScreen())).then((value) => {
            if (value != null)
              {
                setState(() {
                  selectedDoctorSpeciality = value as SelectedSpeciality;
                })
              }
          });

  List<Countries> getCountries() => Countries.values.cast().toList().cast();
  List<String> arabicCountriesNames = AccountConstants.arabicCountriesNames;

  List<AccountTypes> getRegistrationAccountTypeList() => AccountTypes.values
      .cast()
      .where((element) => element != AccountTypes.Admin)
      .toList()
      .cast();
  List<String> arabicAccountTypes = AccountConstants.arabicAccountTypes;
}

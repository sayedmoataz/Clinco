import 'dart:async';

import 'package:clinico/constants/app_colors.dart';
import 'package:clinico/model/Payment%20Models/cache_helper.dart';
import 'package:clinico/model/user_data.dart';
import 'package:clinico/view/screens/about_us_screen.dart';
import 'package:clinico/view/screens/admin_part/admin_home_screen.dart';
import 'package:clinico/view/screens/company_part/company_home_screen.dart';
import 'package:clinico/view/screens/doctor_part/doctor_home_screen.dart';
import 'package:clinico/view/screens/guides_screen.dart';
import 'package:clinico/view/screens/lab_rays_shared/labs/lab_home_screen.dart';
import 'package:clinico/view/screens/lab_rays_shared/rays/rays_center_home_screen.dart';
import 'package:clinico/view/screens/login_screen.dart';
import 'package:clinico/view/screens/patient_part/patient_home_screen.dart';
import 'package:clinico/view/screens/registration_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model/Payment Models/cubit.dart';
import 'helper/local_notification.dart';
import 'helper/shared_preferences.dart';
import 'model/Payment Models/visa_web_view.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  RemoteNotification? notification = message.notification;
}

bool _isLoggedIn = false;
String? _accountType;

void main() async {
  CacheHelper.init();
  initializeDateFormatting('ar_KSA', null).then((_) => startApp());
}

void startApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  runZonedGuarded(
    () {
      runProject(const MyApp());
    },
    (error, stack) => FirebaseCrashlytics.instance.recordError(
      error,
      stack,
      fatal: true,
    ),
  );
}

void runProject(MyApp myApp) async {
  AppData appData = AppData();
  SharedPreferences? pref = await appData.getSharedPreferencesInstance();

  _isLoggedIn = appData.getIsLoggedIn(pref!);
  if (_isLoggedIn) {
    _accountType = appData.getAccountType(pref);
    if (_accountType == AccountTypes.Doctor.name ||
        _accountType == AccountTypes.Company.name) {
      String userEmail = appData.getUserEmail(pref)!;
      await FirebaseFirestore.instance
          .collection(FirestoreCollections.Users.name)
          .where('email', isEqualTo: userEmail)
          .get()
          .then((snapshos) async {
        QueryDocumentSnapshot<Map<String, dynamic>> queryDocumentSnapshot =
            snapshos.docs.first;
        if (queryDocumentSnapshot.exists) {
          Map<String, dynamic> map = queryDocumentSnapshot.data();
          UserData userData = UserData.fromJson(map);
          await appData.setAccountStatus(pref, userData.accountStatus);
        }
      });
    }
  }

  runApp(myApp);
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    FirebaseMessaging.instance.getToken().then((value) => print(value));
    LocNotification.init(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (BuildContext context) => HomeCubit(),
      child: Directionality(
          textDirection: TextDirection.rtl,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
                // primaryColor: const Color(0xFF2661FA),
                primaryColor: AppColors.appPrimaryColor,
                scaffoldBackgroundColor: Colors.white,
                visualDensity: VisualDensity.adaptivePlatformDensity,
                fontFamily: "Lateef",
                textTheme: TextTheme(),
                appBarTheme: const AppBarTheme(
                    backgroundColor: Colors.white,
                    centerTitle: true,
                    elevation: 0,
                    iconTheme: IconThemeData(color: Colors.black),
                    titleTextStyle: TextStyle(color: Colors.black))),
            home: getNextHomeScreen(),
            routes: {
              "/loginScreen": (context) => const LoginScreen(),
              "/registrationScreen": (context) => const RegistrationScreen(),
              "/adminHomeScreen": (context) => const AdminHomeScreen(),
              "/doctorHomeScreen": (context) => const DoctorHomeScreen(),
              "/companyHomeScreen": (context) => const CompanyHomeScreen(),
              "/patientHomeScreen": (context) => const PatientHomeScreen(),
              "/aboutUsScreen": (context) => const AboutUsScreen(),
              "/guidesScreen": (context) => const GuidesScreen(),
              "/labHomeScreen": (context) => const LabsHomeScreen(),
              "/raysCenterHomeScreen": (context) => const RaysCenterHomeScreen(),
              "/payment": (context) => const PaymentWeView()
            },
          )),
    );
  }

  Widget getNextHomeScreen() {
    if (!_isLoggedIn) {
      return const LoginScreen();
    } else {
      AccountTypes type = AccountTypes.values.byName(_accountType!);
      switch (type) {
        case AccountTypes.Admin:
          return const AdminHomeScreen();
        case AccountTypes.Doctor:
          return const DoctorHomeScreen();
        case AccountTypes.Company:
          return const CompanyHomeScreen();
        case AccountTypes.Lab:
          return const LabsHomeScreen();
        case AccountTypes.RaysCenter:
          return const RaysCenterHomeScreen();
        default:
          return const PatientHomeScreen();
      }
    }
  }
}

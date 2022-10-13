import 'package:clinico/view/screens/patient_part/fragments/patient_clinics_appointments_fragment.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:line_icons/line_icons.dart';

import '../../../constants/app_colors.dart';
import '../bought_devices.dart';
import '../fragments/clinic_speciality_list_fragment.dart';
import '../fragments/more_fragment.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({Key? key}) : super(key: key);

  @override
  _PatientHomeScreenState createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  List<Color> primaryGradientColors = AppColors.primaryGradientColors;
  Color primaryLightColor = AppColors.primaryColor;
  DateTime? currentBackPressTime;
  int selectedIndex = 0;
  final widgetTitle = [
    'العيادات',
    'الحجوزات',
    'الأجهزة',
    'الصفحة الشخصية',
    'المزيد'
  ];
  final widgetOptions = [
    const ClinicSpecialityListFragment(),
    const PatientClinicsAppointmentsFragment(
      screenTitle: 'حجوزات العيادات',
    ),
    const BoughtDevices(),
    // DevicesCategoriesFragment(isAdmin: false,),
    // const BmiInputPage(),
    const MoreFragment()
  ];

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Directionality(
          textDirection: TextDirection.rtl, child: getScreenScaffoldWidget()),
    );
  }

  Scaffold getScreenScaffoldWidget() {
    return Scaffold(
        body: IndexedStack(
          index: selectedIndex,
          children: widgetOptions,
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            // BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.heartPulse), label: 'العيادات'),
            // BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.calendarDay), label: 'الحجوزات'),
            // BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.desktop), label: 'الأجهزة'),
            // BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.weightScale), label: 'كتلة الجسم BMI'),
            // BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.ellipsisVertical), label: 'المزيد'),
            BottomNavigationBarItem(
                icon: Icon(LineIcons.home), label: 'الرئيسية'),
            BottomNavigationBarItem(
                icon: Icon(LineIcons.calendarCheckAlt), label: 'مواعيدى'),
            BottomNavigationBarItem(
                icon: Icon(LineIcons.microscope), label: 'أجهزتى'),
            BottomNavigationBarItem(icon: Icon(LineIcons.user), label: 'حسابى'),
          ],
          currentIndex: selectedIndex,
          onTap: onItemTapped,
          elevation: 0,
          selectedItemColor: AppColors.appPrimaryColor,
          selectedLabelStyle: TextStyle(color: AppColors.appPrimaryColor),
          unselectedLabelStyle: const TextStyle(color: Colors.grey),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedIconTheme: IconThemeData(color: AppColors.appPrimaryColor),
          unselectedItemColor: Colors.grey,
          // type: BottomNavigationBarType.fixed,
          // selectedLabelStyle: TextStyle(color: primaryLightColor, fontSize: 10),
          // selectedIconTheme: const IconThemeData(color: Color(0xFFF80144), opacity: 1.0, size: 30.0),
          // selectedItemColor: const Color(0xFFF80144),
          // showSelectedLabels: true,
          // unselectedIconTheme: const IconThemeData(color: AppColors.primaryColor, opacity: 1.0, size: 30.0),
          // unselectedFontSize: 16,
          // unselectedItemColor: AppColors.primaryColor,
          // unselectedLabelStyle: const TextStyle(fontSize: 8, color: AppColors.primaryColor),
          // showUnselectedLabels: false,
          // backgroundColor: Colors.white,
        ));
  }

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(msg: "Click again to exit the application!");
      return Future.value(false);
    }
    return Future.value(true);
  }
}

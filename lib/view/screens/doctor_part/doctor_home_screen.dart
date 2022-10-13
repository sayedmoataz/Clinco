import 'package:clinico/view/screens/doctor_part/doctor_main.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:line_icons/line_icons.dart';

import '../../../constants/app_colors.dart';
import '../bought_devices.dart';
import '../fragments/more_fragment.dart';
import 'doctor_clinics_appointments_fragment.dart';
import 'fragments/doctor_clinics_fragment.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({Key? key}) : super(key: key);

  @override
  _DoctorHomeScreenState createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  List<Color> primaryGradientColors = AppColors.primaryGradientColors;
  Color primaryLightColor = AppColors.primaryColor;
  DateTime? currentBackPressTime;
  int selectedIndex = 0;
  final widgetTitle = [
    'الأجهزة',
    'العيادات',
    'عياداتي',
    'الحجوزات',
    'الشخصية',
    'المزيد'
  ];
  final widgetOptions = [
    // DevicesCategoriesFragment(isAdmin: false,),
    const DoctorMainPage(),
    const DoctorClinicsFragment(),
    const DoctorClinicsAppointmentsFragment(),
    const BoughtDevices(),
    // const ProfileFragment(),
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
            // BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.desktop), label: 'الأجهزة'),
            // BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.heartPulse), label: 'العيادات'),
            BottomNavigationBarItem(
                icon: Icon(LineIcons.home), label: 'الرئيسية'),
            BottomNavigationBarItem(
                icon: Icon(LineIcons.doctor), label: 'عياداتي'),
            BottomNavigationBarItem(
                icon: Icon(LineIcons.businessTime), label: 'الحجوزات'),
            BottomNavigationBarItem(
                icon: Icon(LineIcons.microscope), label: 'اجهزتى'),
            BottomNavigationBarItem(
                icon: Icon(LineIcons.user), label: 'المزيد'),
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

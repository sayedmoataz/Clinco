import 'package:clinico/view/screens/admin_part/fragments/admin_company_list_fragment.dart';
import 'package:clinico/view/screens/admin_part/fragments/admin_doctor_list_fragment.dart';
import 'package:clinico/view/screens/clinics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../constants/app_colors.dart';
import '../fragments/devices_categories_fragment.dart';
import '../fragments/more_fragment.dart';
import '../fragments/profile_fragment.dart';
import 'fragments/admin_lab_list_fragment.dart';
import 'fragments/admin_ray_list_fragment.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen>
    with TickerProviderStateMixin {
  List<Color> primaryGradientColors = AppColors.primaryGradientColors;
  Color primaryLightColor = AppColors.primaryColor;
  DateTime? currentBackPressTime;
  int selectedIndex = 0;
  final widgetTitle = [
    'الأجهزة',
    'العيادات',
    'الأطباء',
    'الشركات',
    'الشخصية',
    'المزيد'
  ];
  final widgetOptions = [
    DevicesCategoriesFragment(
      isAdmin: true,
    ),
    const Clinics(),
    const AdminDoctorListFragment(),
    const AdminCompanyListFragment(),
    const AdminLabListFragment(),
    const AdminRayListFragment(),
    const ProfileFragment(),
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
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.desktop), label: 'الأجهزة'),
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.heartPulse), label: 'العيادات'),
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.userDoctor), label: 'الأطباء'),
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.solidBuilding), label: 'الشركات'),
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.laptopMedical), label: 'المعامل'),
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.buildingColumns), label: 'المراكز'),
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.user), label: 'الشخصية'),
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.ellipsisVertical), label: 'المزيد'),
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
      ),
    );
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

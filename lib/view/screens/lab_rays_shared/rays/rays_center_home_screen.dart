import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:line_icons/line_icons.dart';

import '../../../../../constants/app_colors.dart';
import '../lab_ray_requests.dart';
import '../lab_rays_opening_hours.dart';
import '../lab_rays_settings.dart';

class RaysCenterHomeScreen extends StatefulWidget {
  const RaysCenterHomeScreen({Key? key}) : super(key: key);

  @override
  _RaysCenterHomeScreenState createState() => _RaysCenterHomeScreenState();
}

class _RaysCenterHomeScreenState extends State<RaysCenterHomeScreen> {
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
    LabRayRequests(
      isLab: false,
      pageIndex: 0,
    ),
    LabRayRequests(
      isLab: false,
      pageIndex: 1,
    ),
    LabRaysOpeningHoursScreen(
      isLab: false,
    ),
    LabRaysSettings(
      isLab: false,
    )
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
                icon: Icon(LineIcons.home), label: 'حجوزات جديدة'),
            BottomNavigationBarItem(
                icon: Icon(LineIcons.checkCircle), label: 'حجوزات مقبولة'),
            BottomNavigationBarItem(
                icon: Icon(LineIcons.businessTime), label: 'مواعيد العمل'),
            // BottomNavigationBarItem(icon: Icon(LineIcons.businessTime), label: 'بيانات شخصية'),
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

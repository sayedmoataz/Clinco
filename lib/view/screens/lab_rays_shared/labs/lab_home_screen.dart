import 'package:clinico/view/screens/lab_rays_shared/lab_ray_requests.dart';
import 'package:clinico/view/screens/lab_rays_shared/lab_rays_opening_hours.dart';
import 'package:clinico/view/screens/lab_rays_shared/lab_rays_settings.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:line_icons/line_icons.dart';

import '../../../../../constants/app_colors.dart';

class LabsHomeScreen extends StatefulWidget {
  const LabsHomeScreen({Key? key}) : super(key: key);

  @override
  _LabsHomeScreenState createState() => _LabsHomeScreenState();
}

class _LabsHomeScreenState extends State<LabsHomeScreen> {
  List<Color> primaryGradientColors = AppColors.primaryGradientColors;
  Color primaryLightColor = AppColors.primaryColor;
  DateTime? currentBackPressTime;
  int selectedIndex = 0;
  final widgetOptions = [
    LabRayRequests(
      isLab: true,
      pageIndex: 0,
    ),
    LabRayRequests(
      isLab: true,
      pageIndex: 1,
    ),
    LabRaysOpeningHoursScreen(
      isLab: true,
    ),
    LabRaysSettings(
      isLab: true,
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

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:line_icons/line_icons.dart';

import '../../../constants/app_colors.dart';
import '../fragments/devices_categories_fragment.dart';
import '../fragments/more_fragment.dart';
import '../fragments/profile_fragment.dart';
import 'devices_cart.dart';

class CompanyHomeScreen extends StatefulWidget {
  const CompanyHomeScreen({Key? key}) : super(key: key);

  @override
  _CompanyHomeScreenState createState() => _CompanyHomeScreenState();
}

class _CompanyHomeScreenState extends State<CompanyHomeScreen> {
  List<Color> primaryGradientColors = AppColors.primaryGradientColors;
  Color primaryLightColor = AppColors.primaryColor;
  DateTime? currentBackPressTime;
  int selectedIndex = 0;
  final widgetTitle = ['الأجهزة', 'الصفحة الشخصية', 'المزيد'];
  final widgetOptions = [
    DevicesCategoriesFragment(
      isAdmin: false,
    ),
    const ProfileFragment(),
    const DevicesCart(),
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
                icon: Icon(LineIcons.desktop), label: 'الأجهزة'),
            BottomNavigationBarItem(
                icon: Icon(LineIcons.user), label: 'الصفحة الشخصية'),
            BottomNavigationBarItem(
                icon: Icon(LineIcons.shoppingBasket),
                label: 'الاجهزة المشترية'),
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

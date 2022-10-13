import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

class ClinicsTabBar extends StatelessWidget implements PreferredSizeWidget {
  List<Color> primaryGradientColors = AppColors.primaryGradientColors;
  TabController tabController;

  ClinicsTabBar(this.tabController, {Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(50);

  @override
  Widget build(BuildContext context) {
    return Container(
      // decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: primaryGradientColors),),
      color: AppColors.appPrimaryColor,
      child: TabBar(
        controller: tabController,
        indicatorColor: AppColors.appPrimaryColor,
        labelColor: AppColors.secondaryColor2,
        labelStyle: const TextStyle(
            fontSize: 14.0,
            fontFamily: 'Family Name',
            fontWeight: FontWeight.bold),
        unselectedLabelColor: Colors.white,
        unselectedLabelStyle:
            const TextStyle(fontSize: 14.0, fontFamily: 'Family Name'),
        tabs: const [
          Tab(text: 'مكالمة/عيادة'),
          Tab(text: 'مكالمة دكتور'),
          Tab(text: 'حجز عيادة')
        ],
      ),
    );
  }
}

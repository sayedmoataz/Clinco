import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

class DevicesCategoriesTabBar extends StatelessWidget
    implements PreferredSizeWidget {
  List<Color> primaryGradientColors = AppColors.primaryGradientColors;
  TabController tabController;

  DevicesCategoriesTabBar(this.tabController, {Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(50);

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: tabController,
      indicatorColor: AppColors.appPrimaryColor,
      labelColor: AppColors.appPrimaryColor,
      labelStyle: const TextStyle(
        fontSize: 16.0,
      ),
      unselectedLabelColor: Colors.black,
      unselectedLabelStyle: const TextStyle(
        fontSize: 16.0,
      ),
      tabs: const [Tab(text: 'جديد'), Tab(text: 'مستعمل')],
    );
  }
}

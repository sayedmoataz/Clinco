import 'package:flutter/material.dart';

import '../screens/devices_categories_screen.dart';

class DevicesCategoriesTabBarView extends StatelessWidget {
  bool isAdmin = false;
  TabController tabController;

  DevicesCategoriesTabBarView(
      {Key? key, required this.isAdmin, required this.tabController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: tabController,
      children: [
        DevicesCategoriesScreen(
          isNew: true,
          isAdmin: isAdmin,
        ),
        DevicesCategoriesScreen(
          isNew: false,
          isAdmin: isAdmin,
        )
      ],
    );
  }
}

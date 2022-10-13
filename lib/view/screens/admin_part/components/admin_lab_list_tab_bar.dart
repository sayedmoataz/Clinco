import 'package:flutter/material.dart';

import '../../../../constants/account_constants.dart';
import '../../../../constants/app_colors.dart';
import '../../../../model/user_data.dart';

class AdminLabListTabBar extends StatelessWidget
    implements PreferredSizeWidget {
  List<Color> primaryGradientColors = AppColors.primaryGradientColors;
  TabController tabController;

  AdminLabListTabBar(this.tabController, {Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(50);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: primaryGradientColors),
      ),
      child: TabBar(
        controller: tabController,
        indicatorColor: AppColors.secondaryColor2,
        labelColor: AppColors.secondaryColor2,
        labelStyle: const TextStyle(
            fontSize: 14.0,
            fontFamily: 'Family Name',
            fontWeight: FontWeight.bold),
        unselectedLabelColor: Colors.white,
        unselectedLabelStyle:
            const TextStyle(fontSize: 14.0, fontFamily: 'Family Name'),
        tabs: [
          Tab(
              text: AccountConstants
                  .accountStatusTitleList[AccountStatus.Pending.index]),
          Tab(
              text: AccountConstants
                  .accountStatusTitleList[AccountStatus.Approved.index]),
          Tab(
              text: AccountConstants
                  .accountStatusTitleList[AccountStatus.Rejected.index])
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../model/user_data.dart';
import '../admin_company_list_item_screen.dart';

class AdminCompanyListTabBarView extends StatelessWidget {
  TabController tabController;

  AdminCompanyListTabBarView({Key? key, required this.tabController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: tabController,
      children: const [
        AdminCompanyListItemScreen(accountStatus: AccountStatus.Pending),
        AdminCompanyListItemScreen(accountStatus: AccountStatus.Approved),
        AdminCompanyListItemScreen(accountStatus: AccountStatus.Rejected)
      ],
    );
  }
}

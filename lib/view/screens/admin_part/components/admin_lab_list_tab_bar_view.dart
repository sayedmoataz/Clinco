import 'package:flutter/material.dart';

import '../../../../model/user_data.dart';
import '../admin_labs_list.dart';

class AdminLabListTabBarView extends StatelessWidget {
  TabController tabController;

  AdminLabListTabBarView({Key? key, required this.tabController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: tabController,
      children: const [
        AdminLabsList(accountStatus: AccountStatus.Pending),
        AdminLabsList(accountStatus: AccountStatus.Approved),
        AdminLabsList(accountStatus: AccountStatus.Rejected)
      ],
    );
  }
}

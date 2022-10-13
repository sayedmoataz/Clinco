import 'package:flutter/material.dart';

import '../../../../model/user_data.dart';
import '../admin_rays_list.dart';

class AdminRayListTabBarView extends StatelessWidget {
  TabController tabController;

  AdminRayListTabBarView({Key? key, required this.tabController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: tabController,
      children: const [
        AdminRaysList(accountStatus: AccountStatus.Pending),
        AdminRaysList(accountStatus: AccountStatus.Approved),
        AdminRaysList(accountStatus: AccountStatus.Rejected)
      ],
    );
  }
}

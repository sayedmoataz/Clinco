import 'package:flutter/material.dart';

import '../../../../model/user_data.dart';
import '../admin_doctor_list_item_screen.dart';

class AdminDoctorListTabBarView extends StatelessWidget {
  TabController tabController;

  AdminDoctorListTabBarView({Key? key, required this.tabController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: tabController,
      children: const [
        AdminDoctorListItemScreen(accountStatus: AccountStatus.Pending),
        AdminDoctorListItemScreen(accountStatus: AccountStatus.Approved),
        AdminDoctorListItemScreen(accountStatus: AccountStatus.Rejected)
      ],
    );
  }
}

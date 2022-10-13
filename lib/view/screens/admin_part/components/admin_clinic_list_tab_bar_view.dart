import 'package:flutter/material.dart';

import '../../../../model/user_data.dart';
import '../admin_clinic_list_item_screen.dart';

class AdminClinicListTabBarView extends StatelessWidget {
  TabController tabController;
  final String specialityId;

  AdminClinicListTabBarView(
      {Key? key, required this.tabController, required this.specialityId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: tabController,
      children: [
        AdminClinicListItemScreen(
            specialityId: specialityId, accountStatus: AccountStatus.Pending),
        AdminClinicListItemScreen(
            specialityId: specialityId, accountStatus: AccountStatus.Approved),
        AdminClinicListItemScreen(
            specialityId: specialityId, accountStatus: AccountStatus.Rejected)
      ],
    );
  }
}

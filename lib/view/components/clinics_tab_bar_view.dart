import 'package:flutter/material.dart';

import '../screens/clinic_list_screen.dart';

class ClinicsTabBarView extends StatelessWidget {
  TabController tabController;
  final String specialityId;

  ClinicsTabBarView(
      {Key? key, required this.tabController, required this.specialityId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: tabController,
      children: [
        ClinicListScreen(specialityId: specialityId, revealWayIndex: 0),
        ClinicListScreen(specialityId: specialityId, revealWayIndex: 1),
        ClinicListScreen(specialityId: specialityId, revealWayIndex: 2),
      ],
    );
  }
}

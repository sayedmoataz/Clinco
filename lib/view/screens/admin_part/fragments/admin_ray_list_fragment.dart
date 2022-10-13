import 'package:flutter/material.dart';

import '../../../../constants/app_colors.dart';
import '../components/admin_doctor_list_tab_bar.dart';
import '../components/admin_ray_list_tab_bar_view.dart';

class AdminRayListFragment extends StatefulWidget {
  const AdminRayListFragment({Key? key}) : super(key: key);

  @override
  _AdminRayListFragmentState createState() => _AdminRayListFragmentState();
}

class _AdminRayListFragmentState extends State<AdminRayListFragment>
    with TickerProviderStateMixin {
  List<Color> primaryGradientColors = AppColors.primaryGradientColors;
  Color primaryLightColor = AppColors.primaryColor;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      vsync: this,
      length: 3,
    );
  }

  @override
  Widget build(BuildContext context) => getDefaultTabController(_tabController);

  getDefaultTabController(TabController tabController) {
    AdminDoctorListTabBar tabBar = AdminDoctorListTabBar(tabController);
    return Scaffold(
      appBar: AppBar(
        title: const Text('المركز',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: primaryGradientColors),
          ),
        ),
      ),
      body: DefaultTabController(
          length: 2,
          child: Scaffold(
            body: AdminRayListTabBarView(tabController: tabController),
            appBar: PreferredSize(
              preferredSize: tabBar.preferredSize,
              child: tabBar,
            ),
          )),
    );
  }
}

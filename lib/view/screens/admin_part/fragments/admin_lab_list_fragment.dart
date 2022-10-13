import 'package:flutter/material.dart';

import '../../../../constants/app_colors.dart';
import '../components/admin_doctor_list_tab_bar.dart';
import '../components/admin_lab_list_tab_bar_view.dart';

class AdminLabListFragment extends StatefulWidget {
  const AdminLabListFragment({Key? key}) : super(key: key);

  @override
  _AdminLabListFragmentState createState() => _AdminLabListFragmentState();
}

class _AdminLabListFragmentState extends State<AdminLabListFragment>
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
        title: const Text('المعامل',
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
            body: AdminLabListTabBarView(tabController: tabController),
            appBar: PreferredSize(
              preferredSize: tabBar.preferredSize,
              child: tabBar,
            ),
          )),
    );
  }
}

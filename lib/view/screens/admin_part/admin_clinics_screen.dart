import 'dart:ui' as ui;

import 'package:clinico/constants/app_colors.dart';
import 'package:flutter/material.dart';

import '../../../model/device.dart';
import 'components/admin_clinic_list_tab_bar.dart';
import 'components/admin_clinic_list_tab_bar_view.dart';

class AdminClinicsScreen extends StatefulWidget {
  final String specialityDocumentId, specialityDocumentPath, specialityTitle;

  const AdminClinicsScreen(
      {Key? key,
      required this.specialityDocumentId,
      required this.specialityDocumentPath,
      required this.specialityTitle})
      : super(key: key);

  @override
  _AdminClinicsScreenState createState() => _AdminClinicsScreenState();
}

class _AdminClinicsScreenState extends State<AdminClinicsScreen>
    with TickerProviderStateMixin {
  Color primaryColor = AppColors.primaryColor;
  List<Color> primaryGradientColors = AppColors.primaryGradientColors;
  bool isEnabled = false;
  final searchFieldController = TextEditingController();
  List<Device> devices = <Device>[];
  String searchText = '';
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(
      vsync: this,
      length: 3,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) => getDefaultTabController(_tabController);

  getDefaultTabController(TabController tabController) {
    AdminClinicListTabBar tabBar = AdminClinicListTabBar(tabController);
    return Directionality(
        textDirection: ui.TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.specialityTitle,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                body: AdminClinicListTabBarView(
                  tabController: tabController,
                  specialityId: widget.specialityDocumentId,
                ),
                appBar: PreferredSize(
                  preferredSize: tabBar.preferredSize,
                  child: tabBar,
                ),
              )),
        ));
  }
}

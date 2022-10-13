import 'dart:ui' as ui;

import 'package:clinico/view/screens/clinics_map_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../constants/app_colors.dart';
import '../components/clinics_tab_bar.dart';
import '../components/clinics_tab_bar_view.dart';

class ClinicsMainScreen extends StatefulWidget {
  final String specialityId, specialityDocumentPath, specialityTitle;

  const ClinicsMainScreen(
      {Key? key,
      required this.specialityId,
      required this.specialityDocumentPath,
      required this.specialityTitle})
      : super(key: key);

  @override
  _ClinicsMainScreenState createState() => _ClinicsMainScreenState();
}

class _ClinicsMainScreenState extends State<ClinicsMainScreen>
    with TickerProviderStateMixin {
  Color primaryColor = AppColors.primaryColor;
  List<Color> primaryGradientColors = AppColors.primaryGradientColors;
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
    ClinicsTabBar tabBar = ClinicsTabBar(tabController);
    return Directionality(
        textDirection: ui.TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.specialityTitle,
                style: const TextStyle(fontSize: 20)),
            // flexibleSpace: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: primaryGradientColors),),),
            // actions: [IconButton(icon: const Icon(FontAwesomeIcons.mapLocationDot, color: AppColors.secondaryColor2,), onPressed: () => _mapButtonClicked(),),],
          ),
          body: DefaultTabController(
              length: 2,
              child: Scaffold(
                body: Column(
                  children: [
                    Expanded(
                      child: ClinicsTabBarView(
                        tabController: tabController,
                        specialityId: widget.specialityId,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => _mapButtonClicked(),
                        child: Container(
                          margin: const EdgeInsets.all(10),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                              color: AppColors.appPrimaryColor,
                              borderRadius: BorderRadius.circular(25)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text(
                                "عرض العيادات على الخريطة",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Icon(
                                FontAwesomeIcons.mapLocationDot,
                                color: Colors.white,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    )
                  ],
                ),
                appBar: PreferredSize(
                  preferredSize: tabBar.preferredSize,
                  child: tabBar,
                ),
              )),
        ));
  }

  _mapButtonClicked() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ClinicsMapScreen(
            specialityId: widget.specialityId,
            specialityDocumentPath: widget.specialityDocumentPath,
            specialityTitle: widget.specialityTitle)));
  }
}

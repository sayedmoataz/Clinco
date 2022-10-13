import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../helper/shared_preferences.dart';
import '../../../model/ad.dart';
import '../../../model/user_data.dart';
import '../../components/ads_container_widget.dart';
import '../../components/devices_categories_tab_bar.dart';
import '../../components/devices_categories_tab_bar_view.dart';
import '../category_data_screen.dart';

class DevicesCategoriesFragment extends StatefulWidget {
  bool isAdmin = false;

  DevicesCategoriesFragment({Key? key, required this.isAdmin})
      : super(key: key);

  @override
  _DevicesCategoriesFragmentState createState() =>
      _DevicesCategoriesFragmentState();
}

class _DevicesCategoriesFragmentState extends State<DevicesCategoriesFragment>
    with TickerProviderStateMixin {
  List<Color> primaryGradientColors = AppColors.primaryGradientColors;
  Color primaryColor = AppColors.primaryColor;
  late TabController _tabController;
  List<Ad> ads = <Ad>[];
  FirebaseFirestore? _firebaseFirestore;
  late Query<Map<String, dynamic>>? queryDevicesAdsRef;
  late final AppData _appData;
  String? _selectedCountry;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      vsync: this,
      length: 2,
    );
    _firebaseFirestore = FirebaseFirestore.instance;
    _appData = AppData();
    _appData.getSharedPreferencesInstance().then((pref) {
      setState(() {
        _selectedCountry = _appData.getSelectedCountry(pref!)!;
        queryDevicesAdsRef = _firebaseFirestore!
            .collection(FirestoreCollections.DevicesAds.name)
            .where('selectedCountry', isEqualTo: _selectedCountry)
            .where('isActive', isEqualTo: true)
            .where('expiryDate', isGreaterThanOrEqualTo: DateTime.now())
            .orderBy('expiryDate', descending: false)
            .orderBy('priority', descending: false);
        getDevicesAds();
      });
    });
  }

  getDevicesAds() async {
    await queryDevicesAdsRef!.get().then((value) => {
          setState(() {
            ads.clear();
            value.docs
                .asMap()
                .forEach((key, json) => ads.add(Ad.fromJson(json)));
          })
        });
  }

  @override
  Widget build(BuildContext context) => getDefaultTabController(_tabController);

  getDefaultTabController(TabController tabController) {
    DevicesCategoriesTabBar tabBar = DevicesCategoriesTabBar(tabController);
    return Scaffold(
        appBar: AppBar(
          title: const Text('الأجهزة الطبية',
              style: TextStyle(
                fontSize: 20,
              )),
          // flexibleSpace: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: primaryGradientColors),),),
        ),
        body: Column(
          children: [
            Flexible(
              flex: 25,
              child: AdsContainerWidget(ads: ads),
            ),
            Flexible(
              flex: 75,
              child: DefaultTabController(
                  length: 2,
                  child: Scaffold(
                      body: DevicesCategoriesTabBarView(
                          isAdmin: widget.isAdmin,
                          tabController: tabController),
                      appBar: PreferredSize(
                        preferredSize: tabBar.preferredSize,
                        child: tabBar,
                      ),
                      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
                      floatingActionButton: Visibility(
                        visible: widget.isAdmin,
                        child: FloatingActionButton(
                          onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => CategoryDataScreen(
                                      isNewCategory: _tabController.index == 0
                                          ? true
                                          : false,
                                      isNewItem: true,
                                      categoryDocumentPath: null,
                                      category: null))),
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.add,
                            color: primaryColor,
                          ),
                        ),
                      ))),
            )
          ],
        ));
  }
}

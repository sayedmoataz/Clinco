import 'package:clinico/model/user_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../helper/shared_preferences.dart';
import '../../../model/ad.dart';
import '../../../model/home_card.dart';
import '../../../model/speciality.dart';
import '../../all_clinics_map.dart';
import '../../components/ads_container_widget.dart';
import '../bmi_calculator/screens/bmi_input_page.dart';
import '../fragments/devices_categories_fragment.dart';
import '../fragments/profile_fragment.dart';
import '../speciality_data_screen.dart';

class DoctorMainPage extends StatefulWidget {
  const DoctorMainPage({Key? key}) : super(key: key);

  @override
  _DoctorMainPageState createState() => _DoctorMainPageState();
}

class _DoctorMainPageState extends State<DoctorMainPage> {
  Color primaryLightColor = AppColors.primaryColor;
  List<Color> primaryGradientColors = AppColors.primaryGradientColors;
  List<Speciality> specialties = <Speciality>[];
  late CollectionReference specialtiesRef;
  late final AppData _appData;
  String? _userId, _selectedCountry, _accountType;
  bool _isAdmin = false;
  List<Ad> ads = <Ad>[];
  FirebaseFirestore? _firebaseFirestore;
  late Query<Map<String, dynamic>>? queryClinicsAdsRef;

  List<HomeCard> homeCards = [
    // HomeCard(pageName: "حجز عيادة", pageImage: "assets/images/clinic.png"),
    // // HomeCard(pageName: "مكالمة دكتور", pageImage: "assets/images/call_doctor.png"),
    // HomeCard(pageName: "معامل التحاليل", pageImage: "assets/images/analisis.png"),
    // HomeCard(pageName: "مراكز الاشعة", pageImage: "assets/images/rays.png"),
    // // HomeCard(pageName: "اقرب العيادات", pageImage: "assets/images/clinic_location.png"),
    HomeCard(
        pageName: "الاجهزة الطبية", pageImage: "assets/images/devices.png"),
    // HomeCard(pageName: "عروض طبية", pageImage: "assets/images/tools_sales.png"),
    HomeCard(
        pageName: "مؤشر كتلة الجسم", pageImage: "assets/images/weight.png"),
    HomeCard(
        pageName: "الملف التعريفي", pageImage: "assets/images/user_avatar.png"),
    HomeCard(
        pageName: "خريطة العيادات",
        pageImage: "assets/images/clinic_location.png"),
  ];

  @override
  void initState() {
    super.initState();

    _firebaseFirestore = FirebaseFirestore.instance;
    _appData = AppData();
    _appData.getSharedPreferencesInstance().then((pref) {
      setState(() {
        _userId = _appData.getUserId(pref!)!;
        _selectedCountry = _appData.getSelectedCountry(pref)!;
        _accountType = _appData.getAccountType(pref);
        _isAdmin = (_accountType == AccountTypes.Admin.name);
        queryClinicsAdsRef = _firebaseFirestore!
            .collection(FirestoreCollections.ClinicsAds.name)
            .where('selectedCountry', isEqualTo: _selectedCountry)
            .orderBy('priority', descending: false);
        getClinicsAds();
      });
    });
    specialtiesRef = FirebaseFirestore.instance
        .collection(FirestoreCollections.Specialties.name);
  }

  getClinicsAds() async {
    await queryClinicsAdsRef!.get().then((value) => {
          setState(() {
            ads.clear();
            value.docs
                .asMap()
                .forEach((key, json) => ads.add(Ad.fromJson(json)));
          })
        });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            // title: const Text('العيادات', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            // flexibleSpace: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: primaryGradientColors),),),
            leading: Center(
                child: Text(
              "CLINICO",
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: AppColors.appPrimaryColor,
                  fontSize: 28,
                  fontWeight: FontWeight.bold),
            )),
            leadingWidth: 100,
            backgroundColor: Colors.grey[100],
            elevation: 0,
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: Visibility(
            visible: _isAdmin,
            child: FloatingActionButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => SpecialityDataScreen(
                      isNewItem: true,
                      specialityDocumentPath: null,
                      speciality: null))),
              backgroundColor: Colors.white,
              child: Icon(
                Icons.add,
                color: primaryLightColor,
              ),
            ),
          ),
          // body: Column(
          //   children: [
          //     Flexible(flex: 25,child: AdsContainerWidget(ads: ads),),
          //     Flexible(flex: 75, child: _getSpecialties(),)
          //   ],
          // )
          body: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  AdsContainerWidget(ads: ads),
                  const SizedBox(
                    height: 5,
                  ),
                  productsCard(context),
                ],
              )),
        ));
  }

  Widget productsCard(
    BuildContext context,
  ) =>
      Container(
        padding: const EdgeInsets.all(8),
        // color: Colors.grey[100],
        child: GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          crossAxisSpacing: 1.0,
          mainAxisSpacing: 1.0,
          childAspectRatio: 1 / 1,
          children: List.generate(
            homeCards.length,
            (index) => Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: GestureDetector(
                onTap: () {
                  if (index == 0)
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DevicesCategoriesFragment(
                                  isAdmin: false,
                                )));
                  if (index == 1)
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const BmiInputPage()));
                  if (index == 2)
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ProfileFragment()));
                  if (index == 3)
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AllClinicsMap(
                                  isPatient: false,
                                )));
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    // border: Border.all(color: Colors.grey)
                  ),
                  child: Column(
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Image(
                          // image: NetworkImage(data[index].image!),
                          image: AssetImage(homeCards[index].pageImage!),
                          width: double.infinity,
                          // fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        homeCards[index].pageName!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 17),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}

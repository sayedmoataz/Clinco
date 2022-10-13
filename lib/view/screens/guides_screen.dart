import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../constants/app_colors.dart';
import '../../helper/shared_preferences.dart';
import '../../model/doctor_guide.dart';
import '../../model/user_data.dart';
import 'guide_steps_screen.dart';

class GuidesScreen extends StatefulWidget {
  const GuidesScreen({Key? key}) : super(key: key);

  @override
  _GuidesScreenState createState() => _GuidesScreenState();
}

class _GuidesScreenState extends State<GuidesScreen> {
  Color primaryLightColor = AppColors.primaryColor;
  List<Color> primaryGradientColors = AppColors.primaryGradientColors;
  List<DoctorGuide> guides = <DoctorGuide>[];
  late CollectionReference guidesCategoriesRef;
  late final AppData _appData;
  String? _selectedCountry;

  @override
  void initState() {
    guidesCategoriesRef =
        FirebaseFirestore.instance.collection(FirestoreCollections.Guides.name);
    _appData = AppData();
    _appData.getSharedPreferencesInstance().then((pref) {
      setState(() {
        _selectedCountry = _appData.getSelectedCountry(pref!)!;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('الإرشادات',
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
          body: getGuidesList(),
        ));
  }

  getGuidesList() {
    return Column(
      children: [
        Flexible(
          child: StreamBuilder(
              stream: guidesCategoriesRef
                  .orderBy('order', descending: false)
                  .where('selectedCountry', isEqualTo: _selectedCountry)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  List<QueryDocumentSnapshot> docs = snapshot.data!.docs;
                  if (docs.isEmpty) {
                    return const Center(
                        child: Text('No data found!',
                            style: TextStyle(color: Colors.blue)));
                  }
                  Map map = (docs).asMap();
                  guides.clear();
                  map.forEach((dynamic, json) =>
                      guides.add(DoctorGuide.fromJson(json)));
                  return ListView.builder(
                      itemCount: guides.length,
                      itemBuilder: (context, index) {
                        String path = docs[index].reference.path;
                        return _buildGuideWidget(guides[index], path);
                      });
                } else if (snapshot.hasError) {
                  return const Center(
                      child: Text(
                    'Something wrong!',
                    style: TextStyle(color: Colors.red),
                  ));
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                return const Center(
                    child: Text(
                  'Unknown error!',
                  style: TextStyle(color: Colors.red),
                ));
              }),
        ),
      ],
    );
  }

  _buildGuideWidget(DoctorGuide guide, String guideDocumentPath) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: InkWell(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => GuideStepsScreen(
                  guideDocumentPath: guideDocumentPath,
                  guideTitle: guide.title))),
          child: ListTile(
            title: Text(
              guide.title!,
              style: TextStyle(fontSize: 16, color: primaryLightColor),
            ),
            leading: SizedBox(
              height: double.infinity,
              child: Icon(
                FontAwesomeIcons.solidCircleDot,
                color: primaryLightColor,
              ),
            ),
            trailing: SizedBox(
              height: double.infinity,
              child: Icon(
                FontAwesomeIcons.angleLeft,
                color: primaryLightColor,
                size: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

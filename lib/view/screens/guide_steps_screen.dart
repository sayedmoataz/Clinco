import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../model/doctor_guide_step.dart';
import '../../model/user_data.dart';

class GuideStepsScreen extends StatefulWidget {
  String? guideTitle, guideDocumentPath;

  GuideStepsScreen(
      {Key? key, required this.guideDocumentPath, required this.guideTitle})
      : super(key: key);

  @override
  _GuideStepsScreenState createState() => _GuideStepsScreenState();
}

class _GuideStepsScreenState extends State<GuideStepsScreen> {
  Color primaryLightColor = AppColors.primaryColor;
  List<Color> primaryGradientColors = AppColors.primaryGradientColors;
  List<DoctorGuideStep> guideSteps = <DoctorGuideStep>[];
  late CollectionReference guideStepsCategoriesRef;

  @override
  void initState() {
    guideStepsCategoriesRef = FirebaseFirestore.instance.collection(
        '${widget.guideDocumentPath}/${FirestoreCollections.Steps.name}');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.guideTitle ?? '',
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
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
              stream: guideStepsCategoriesRef
                  .orderBy('order', descending: false)
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
                  guideSteps.clear();
                  map.forEach((dynamic, json) =>
                      guideSteps.add(DoctorGuideStep.fromJson(json)));
                  return ListView.builder(
                      itemCount: guideSteps.length,
                      itemBuilder: (context, index) =>
                          _buildGuideStepWidget(guideSteps[index], index + 1));
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

  _buildGuideStepWidget(DoctorGuideStep guideStep, int leadingNumber) {
    return Card(
        color: Colors.white,
        child: Padding(
            padding: const EdgeInsets.all(2),
            child: ListTile(
                title: Text(
                  guideStep.title!,
                  style: TextStyle(fontSize: 16, color: primaryLightColor),
                ),
                leading: SizedBox(
                  height: double.infinity,
                  child: CircleAvatar(
                    backgroundColor: primaryLightColor,
                    child: Text(
                      leadingNumber.toString(),
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ))));
  }
}

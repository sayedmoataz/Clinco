import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../constants/app_colors.dart';
import '../../../model/selected_speciality.dart';
import '../../../model/speciality.dart';
import '../../../model/user_data.dart';

class DoctorSpecialitySelectionScreen extends StatefulWidget {
  const DoctorSpecialitySelectionScreen({Key? key}) : super(key: key);

  @override
  _DoctorSpecialitySelectionScreenState createState() =>
      _DoctorSpecialitySelectionScreenState();
}

class _DoctorSpecialitySelectionScreenState
    extends State<DoctorSpecialitySelectionScreen> {
  Color primaryLightColor = AppColors.primaryColor;
  List<Color> primaryGradientColors = AppColors.primaryGradientColors;
  List<Speciality> specialities = <Speciality>[];
  late CollectionReference specialitiesRef;

  @override
  void initState() {
    specialitiesRef = FirebaseFirestore.instance
        .collection(FirestoreCollections.Specialties.name);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('التخصصات الطبية',
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
          body: getSpecialityList(),
        ));
  }

  getSpecialityList() {
    return Column(
      children: [
        Flexible(
          child: StreamBuilder(
              stream: specialitiesRef
                  .orderBy('arabicTitle', descending: false)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  List<QueryDocumentSnapshot> docs = snapshot.data!.docs;
                  if (docs.isEmpty) {
                    return const Center(
                        child: Text('عفواً، لا يوجد بيانات!',
                            style: TextStyle(color: Colors.blue)));
                  }
                  Map map = (docs).asMap();
                  specialities.clear();
                  map.forEach((dynamic, json) =>
                      specialities.add(Speciality.fromJson(json)));
                  return ListView.builder(
                      itemCount: specialities.length,
                      itemBuilder: (context, index) {
                        String documentId = docs[index].reference.id;
                        return _buildSpecialityWidget(
                            documentId, specialities[index]);
                      });
                } else if (snapshot.hasError) {
                  return const Center(
                      child: Text(
                    'عفواً، حدث خطأ ما!',
                    style: TextStyle(color: Colors.red),
                  ));
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                return const Center(
                    child: Text(
                  'عفواً، حدث خطأ ما!',
                  style: TextStyle(color: Colors.red),
                ));
              }),
        ),
      ],
    );
  }

  _buildSpecialityWidget(String specialityId, Speciality speciality) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: InkWell(
          onTap: () => Navigator.pop(
              context, SelectedSpeciality(specialityId, speciality)),
          child: ListTile(
            title: Text(
              speciality.arabicTitle!,
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

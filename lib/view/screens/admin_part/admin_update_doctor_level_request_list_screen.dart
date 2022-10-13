import 'package:clinico/model/update_doctor_level_request.dart';
import 'package:clinico/view/screens/admin_part/view_doctor_profile_screen_for_update_request_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../model/doctor.dart';
import '../../../model/user_data.dart';

class AdminUpdateDoctorLevelRequestListScreen extends StatefulWidget {
  const AdminUpdateDoctorLevelRequestListScreen({Key? key}) : super(key: key);

  @override
  _AdminUpdateDoctorLevelRequestListScreenState createState() =>
      _AdminUpdateDoctorLevelRequestListScreenState();
}

class _AdminUpdateDoctorLevelRequestListScreenState
    extends State<AdminUpdateDoctorLevelRequestListScreen> {
  Color primaryLightColor = AppColors.primaryColor;
  List<Color> primaryGradientColors = AppColors.primaryGradientColors;
  BuildContext? dialogContext;
  List<UpdateDoctorLevelRequest> updateDoctorLevelRequests =
      <UpdateDoctorLevelRequest>[];
  List<Doctor> doctors = <Doctor>[];
  FirebaseFirestore? _firebaseFirestore;
  late CollectionReference updateDoctorLevelRequestsRef;

  @override
  void initState() {
    super.initState();
    _firebaseFirestore = FirebaseFirestore.instance;
    updateDoctorLevelRequestsRef = _firebaseFirestore!
        .collection(FirestoreCollections.UpdateDoctorLevelRequests.name);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('طلبات تغيير مستوى الطبيب',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: primaryGradientColors),
              ),
            ),
          ),
          body: StreamBuilder(
              stream: updateDoctorLevelRequestsRef
                  .orderBy('newLevel', descending: false)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  List<QueryDocumentSnapshot> updateDoctorLevelRequestDocs =
                      snapshot.data!.docs;
                  if (updateDoctorLevelRequestDocs.isEmpty) {
                    return const Center(
                        child: Text('عفواً، لا يوجد بيانات!',
                            style: TextStyle(color: Colors.blue)));
                  }
                  Map map = (updateDoctorLevelRequestDocs).asMap();
                  updateDoctorLevelRequests.clear();
                  map.forEach((dynamic, json) {
                    updateDoctorLevelRequests
                        .add(UpdateDoctorLevelRequest.fromJson(json));
                  });
                  _getRequesterDoctorList();

                  return Directionality(
                      textDirection: TextDirection.rtl,
                      child: doctors.isNotEmpty
                          ? _buildDoctorListViewWidget(
                              updateDoctorLevelRequestDocs)
                          : const Center(child: CircularProgressIndicator()));
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
        ));
  }

  Widget _buildDoctorListViewWidget(
      List<QueryDocumentSnapshot> updateDoctorLevelRequestDocs) {
    return ListView.builder(
        itemCount: doctors.length,
        itemBuilder: (context, i) {
          return Directionality(
              textDirection: TextDirection.rtl,
              child: GestureDetector(
                  onTap: () => {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                ViewDoctorProfileScreenForUpdateRequestScreen(
                                    isDoctorLevelUpdate: true,
                                    isDoctorSpecialityUpdate: false,
                                    doctorAccountJsonMap: doctors[i].toJson(),
                                    doctorId: updateDoctorLevelRequestDocs[i]
                                        .reference
                                        .id,
                                    updateDoctorLevelRequest:
                                        UpdateDoctorLevelRequest.fromJson(
                                            updateDoctorLevelRequestDocs[i]
                                                .data()),
                                    updateDoctorSpecialityRequest: null),
                            settings: RouteSettings(
                                name:
                                    "AdminUpdateDoctorLevelRequestListScreen")))
                      },
                  child: _buildDoctorCardWidget(doctors[i])));
        });
  }

  Widget _buildDoctorCardWidget(Doctor doctor) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: primaryGradientColors,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        height: 80,
        padding: const EdgeInsets.all(4),
        child: Row(children: [
          Expanded(
            flex: 4,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  image: DecorationImage(
                      image: NetworkImage(doctor.image ?? ''),
                      fit: BoxFit.fill)),
            ),
          ),
          const Spacer(
            flex: 1,
          ),
          Expanded(
            flex: 14,
            child: Container(
              padding: const EdgeInsets.only(top: 5, bottom: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                      flex: 5,
                      fit: FlexFit.loose,
                      child: Text(doctor.name ?? '',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white))),
                  const Spacer(
                    flex: 1,
                  ),
                  Flexible(
                      flex: 3,
                      fit: FlexFit.loose,
                      child: Text(doctor.doctorLevel ?? '',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(
                              fontSize: 10.0,
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondaryColor2))),
                  const Spacer(
                    flex: 1,
                  ),
                  Flexible(
                      flex: 3,
                      fit: FlexFit.loose,
                      child: Text(doctor.selectedCountry ?? '',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(
                              fontSize: 10.0,
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondaryColor2))),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }

  _getRequesterDoctorList() async {
    List<Doctor> fetchedDoctors = <Doctor>[];
    for (UpdateDoctorLevelRequest request in updateDoctorLevelRequests) {
      await _firebaseFirestore
          ?.doc(request.doctorDocumentReferencePath!)
          .get()
          .then((value) {
        if (value.exists) {
          fetchedDoctors.add(Doctor.fromJson(value.data()));
        }
      });
    }
    setState(() {
      doctors = fetchedDoctors;
    });
  }
}

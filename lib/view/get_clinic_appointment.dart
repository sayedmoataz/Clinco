import 'package:clinico/constants/app_colors.dart';
import 'package:clinico/view/screens/view_clinic_profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../model/clinic.dart';
import '../../model/user_data.dart';

class GetClinicAppointment extends StatefulWidget {
  const GetClinicAppointment({Key? key}) : super(key: key);

  @override
  _GetClinicAppointmentState createState() => _GetClinicAppointmentState();
}

class _GetClinicAppointmentState extends State<GetClinicAppointment> {
  List<Color> primaryGradientColors = AppColors.primaryGradientColors;
  List<Clinic> clinics = <Clinic>[];
  FirebaseFirestore? _firebaseFirestore;
  late CollectionReference clinicsRef;

  @override
  void initState() {
    super.initState();
    _firebaseFirestore = FirebaseFirestore.instance;
    clinicsRef =
        _firebaseFirestore!.collection(FirestoreCollections.Clinics.name);
  }

  @override
  Widget build(BuildContext context) {
    if (clinicsRef != null) {
      return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            appBar: AppBar(
              title: const Text(
                "حجز عيادة",
                style: TextStyle(fontSize: 20),
              ),
            ),
            body: Column(
              children: [
                Flexible(
                  child: clinicList(),
                ),
              ],
            ),
          ));
    } else {
      return const Center(child: CircularProgressIndicator());
      ;
    }
  }

  Widget clinicList() => StreamBuilder(
      stream: clinicsRef
          .where('revealWay', whereIn: [0, 2])
          .where('accountStatus', isNotEqualTo: 2)
          .orderBy('accountStatus', descending: true)
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
          clinics.clear();
          map.forEach((dynamic, json) {
            clinics.add(Clinic.fromJson(json));
          });
          return Directionality(
              textDirection: TextDirection.rtl,
              child: ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, i) {
                    return Directionality(
                        textDirection: TextDirection.rtl,
                        child: GestureDetector(
                          onTap: () =>
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => ViewClinicProfileScreen(
                                        clinic: clinics[i],
                                        clinicId: docs[i].reference.id,
                                      ))),
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Card(
                              // clipBehavior: Clip.antiAlias,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  gradient: const LinearGradient(
                                    colors: AppColors.primaryGradientColors,
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                ),
                                // decoration: BoxDecoration(gradient: LinearGradient(colors: primaryGradientColors, begin: Alignment.centerLeft, end: Alignment.centerRight,),),
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
                                            color: AppColors.appPrimaryColor,
                                            width: 2,
                                          ),
                                          image: DecorationImage(
                                              image: NetworkImage(
                                                  clinics[i].logo ?? ''),
                                              fit: BoxFit.fill)),
                                    ),
                                  ),
                                  const Spacer(
                                    flex: 1,
                                  ),
                                  Expanded(
                                    flex: 14,
                                    child: Container(
                                      padding: const EdgeInsets.only(
                                          top: 5, bottom: 5),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Flexible(
                                              flex: 5,
                                              fit: FlexFit.loose,
                                              child: Text(clinics[i].name ?? '',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                  textDirection:
                                                      TextDirection.rtl,
                                                  style: const TextStyle(
                                                      fontSize: 18.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white))),
                                          const Spacer(
                                            flex: 1,
                                          ),
                                          Flexible(
                                              flex: 3,
                                              fit: FlexFit.loose,
                                              child: Text(
                                                  clinics[i].address ?? '',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                  textDirection:
                                                      TextDirection.rtl,
                                                  style: const TextStyle(
                                                      fontSize: 16.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.yellow))),
                                        ],
                                      ),
                                    ),
                                  ),
                                ]),
                              ),
                            ),
                          ),
                        ));
                  }));
        } else if (snapshot.hasError) {
          return const Center(
              child: Text(
            'عفواً، حدث خطأ ما!',
            style: TextStyle(color: Colors.red),
          ));
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        return const Center(
            child: Text(
          'عفواً، حدث خطأ ما!',
          style: TextStyle(color: Colors.red),
        ));
      });
}

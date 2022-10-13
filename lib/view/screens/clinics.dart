import 'package:clinico/view/screens/clinics_main_screen.dart';
import 'package:clinico/view/screens/speciality_data_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../constants/app_colors.dart';
import '../../helper/shared_preferences.dart';
import '../../model/speciality.dart';
import '../../model/user_data.dart';
import 'admin_part/admin_clinics_screen.dart';

class Clinics extends StatefulWidget {
  const Clinics({Key? key}) : super(key: key);

  @override
  State<Clinics> createState() => _ClinicsState();
}

class _ClinicsState extends State<Clinics> {
  // Color primaryLightColor = AppColors.primaryColor;
  // List<Color> primaryGradientColors = AppColors.primaryGradientColors;
  List<Speciality> specialties = <Speciality>[];
  late CollectionReference specialtiesRef;
  late final AppData _appData;
  String? _userId, _selectedCountry, _accountType;
  bool _isAdmin = false;
  FirebaseFirestore? _firebaseFirestore;
  late Query<Map<String, dynamic>>? queryClinicsAdsRef;

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
        // queryClinicsAdsRef = _firebaseFirestore!.collection(FirestoreCollections.ClinicsAds.name).where('selectedCountry', isEqualTo: _selectedCountry)
        //     .where('isActive', isEqualTo: true).where('expiryDate', isGreaterThanOrEqualTo: DateTime.now())
        //     .orderBy('expiryDate', descending: false)
        //     .orderBy('priority', descending: false);
        queryClinicsAdsRef = _firebaseFirestore!
            .collection(FirestoreCollections.ClinicsAds.name)
            .where('selectedCountry', isEqualTo: _selectedCountry)
            // .where('isActive', isEqualTo: true).where('expiryDate', isGreaterThanOrEqualTo: DateTime.now())
            // .orderBy('expiryDate', descending: false)
            .orderBy('priority', descending: false);
        // getClinicsAds();
      });
    });
    specialtiesRef = FirebaseFirestore.instance
        .collection(FirestoreCollections.Specialties.name);
  }

  // getClinicsAds() async {
  //   await queryClinicsAdsRef!.get().then((value) => {
  //     setState(() {
  //       ads.clear();
  //       value.docs.asMap().forEach((key, json) => ads.add(Ad.fromJson(json)));
  //     })
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("عياداتى",
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
        ),
        body: _getSpecialties(),
      ),
    );
  }

  Widget _getSpecialties() {
    Size size = MediaQuery.of(context).size;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: StreamBuilder(
              stream: specialtiesRef
                  .where('selectedCountry', isEqualTo: _selectedCountry)
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
                  specialties.clear();
                  map.forEach((dynamic, json) =>
                      specialties.add(Speciality.fromJson(json)));
                  return Directionality(
                      textDirection: TextDirection.rtl,
                      child: ListView.builder(
                        // gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        //     crossAxisCount: 3,
                        //     childAspectRatio: 0.8
                        // ),
                        // separatorBuilder: (BuildContext context, int index) => const Divider(),
                        itemCount: specialties.length,
                        padding: const EdgeInsets.all(2.0),
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) {
                                String id = docs.elementAt(index).reference.id;
                                String path =
                                    docs.elementAt(index).reference.path;
                                return _isAdmin
                                    ? AdminClinicsScreen(
                                        specialityDocumentId: id,
                                        specialityDocumentPath: path,
                                        specialityTitle:
                                            specialties[index].arabicTitle ??
                                                '',
                                      )
                                    : ClinicsMainScreen(
                                        specialityId: id,
                                        specialityDocumentPath: path,
                                        specialityTitle:
                                            specialties[index].arabicTitle ??
                                                '',
                                      );
                              }));
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Container(
                                height: 100,
                                // decoration: BoxDecoration(
                                //   borderRadius: BorderRadius.circular(10)
                                // ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  gradient: const LinearGradient(
                                    colors: AppColors.primaryGradientColors,
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                ),
                                // borderRadius: BorderRadius.all(Radius.circular(10.0)), gradient: LinearGradient(colors: [AppColors.primaryColor, Color(0x8000000),], begin: FractionalOffset(0.0, 1.0), end: FractionalOffset(0.0, 0.0), stops: [0.0, 1.0], tileMode: TileMode.clamp),),
                                child: LayoutBuilder(
                                  builder: (BuildContext context,
                                      BoxConstraints constraints) {
                                    return Row(
                                      // crossAxisAlignment: CrossAxisAlignment.center,
                                      // mainAxisAlignment: MainAxisAlignment.end,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                "عيادات",
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              SizedBox(
                                                width:
                                                    constraints.maxWidth * 0.5,
                                                child: Text(
                                                  specialties[index]
                                                          .arabicTitle ??
                                                      '',
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.yellow,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Visibility(
                                                  visible: _isAdmin,
                                                  child: Container(
                                                      alignment:
                                                          Alignment.center,
                                                      width: 100,
                                                      height: 20,
                                                      // height: constraints.maxHeight * 0.2,
                                                      // width: double.infinity,
                                                      child: getManageIcons(
                                                          docs
                                                              .elementAt(index)
                                                              .reference
                                                              .path,
                                                          specialties[index]))),
                                            ],
                                          ),
                                        ),
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Image(
                                            width: 100,
                                            height: 100,
                                            // height: constraints.maxHeight * (_isAdmin ? 0.65 : 0.85),
                                            fit: BoxFit.fill,
                                            image: NetworkImage(
                                              specialties[index].image ?? '',
                                            ),
                                          ),
                                        ),
                                        // const SizedBox(height: 1,),
                                        // Container(
                                        //   alignment: Alignment.center,
                                        //   height: constraints.maxHeight * 0.13,
                                        //   width: double.infinity,
                                        //   child: Text(specialties[index].arabicTitle ?? '', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),textAlign: TextAlign.center),
                                        // ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ));
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

  Widget getManageIcons(String documentPath, Speciality speciality) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => SpecialityDataScreen(
                  isNewItem: false,
                  specialityDocumentPath: documentPath,
                  speciality: speciality))),
          icon: const Icon(
            Icons.edit,
            color: Colors.white,
            size: 20,
          ),
        ),
        IconButton(
          onPressed: () {
            showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: const Text(
                  'حذف تخصص',
                  style: TextStyle(color: Colors.black),
                  textDirection: TextDirection.rtl,
                ),
                content: Text(
                    'هل متأكد أنك تريد حذف ${speciality.arabicTitle} ؟',
                    style: const TextStyle(color: Colors.black),
                    textDirection: TextDirection.rtl),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'Cancel'),
                    child: const Text('إلغاء'),
                  ),
                  TextButton(
                    onPressed: () => deleteSpeciality(documentPath, speciality),
                    child: const Text('نعم'),
                  ),
                ],
              ),
            );
          },
          icon: const Icon(
            Icons.delete,
            color: Colors.white,
            size: 20,
          ),
        )
      ],
    );
  }

  void deleteSpeciality(String path, Speciality speciality) {
    FirebaseStorage.instance
        .refFromURL(speciality.image!)
        .delete()
        .then((value) => {
              FirebaseFirestore.instance.doc(path).delete().then((value) => {
                    Fluttertoast.showToast(msg: 'تم الحذف بنجاح!'),
                    Navigator.pop(context, 'Ok')
                  })
            });
  }
}

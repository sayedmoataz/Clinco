import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/utils.dart';
import '../../../../helper/shared_preferences.dart';
import '../../../../helper/social_media_operations.dart';
import '../../../../model/clinic.dart';
import '../../../../model/doctor.dart';
import '../../../../model/user_data.dart';
import '../../clinic_data_screen.dart';
import '../doctor_clinic_available_days_screen.dart';

class DoctorClinicsFragment extends StatefulWidget {
  const DoctorClinicsFragment({Key? key}) : super(key: key);

  @override
  _DoctorClinicsFragmentState createState() => _DoctorClinicsFragmentState();
}

class _DoctorClinicsFragmentState extends State<DoctorClinicsFragment> {
  List<Color> primaryGradientColors = AppColors.primaryGradientColors;
  Color primaryLightColor = AppColors.primaryColor;
  SocialMediaOperations? socialMediaOperations;
  bool isEnabled = false, _searchBoolean = false;
  final searchFieldController = TextEditingController();
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  Doctor? _doctor;
  List<Clinic> clinics = <Clinic>[];
  String? _clinicsCollectionPath, _userId, _selectedCountry;
  late Query<Map<String, dynamic>>? _defaultQuery;
  Query<Map<String, dynamic>>? _fetchingQuery;
  String searchText = '';
  late final AppData _appData;
  FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  @override
  void initState() {
    socialMediaOperations = SocialMediaOperations();
    _clinicsCollectionPath = FirestoreCollections.Clinics.name;
    _appData = AppData();
    _appData.getSharedPreferencesInstance().then((pref) {
      _userId = _appData.getUserId(pref!)!;
      _selectedCountry = _appData.getSelectedCountry(pref)!;
      int accountStatus = _appData.getAccountStatus(pref)!;
      if (accountStatus == 1) {
        setState(() {
          isEnabled = true;
        });
      }

      _defaultQuery = FirebaseFirestore.instance
          .collection(_clinicsCollectionPath!)
          .orderBy('name', descending: false)
          .where('doctorUserId', isEqualTo: _userId);
      _fetchingQuery = _defaultQuery;

      fetchDoctorData();
    });

    super.initState();
  }

  void fetchDoctorData() async {
    await _firebaseFirestore
        .collection(FirestoreCollections.Doctors.name)
        .where('userId', isEqualTo: _userId)
        .get()
        .then((snapshots) {
      QueryDocumentSnapshot<Map<String, dynamic>> queryDocumentSnapshot =
          snapshots.docs.first;
      if (queryDocumentSnapshot.exists) {
        setState(() {
          _doctor = Doctor.fromJson(queryDocumentSnapshot.data());
        });
      }
    });
  }

  @override
  void dispose() {
    searchFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
            appBar: AppBar(
                title: !_searchBoolean
                    ? const Text('العيادات',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold))
                    : _searchTextField(),
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: primaryGradientColors),
                  ),
                ),
                actions: appBarActions()),
            floatingActionButton: Visibility(
                visible: isEnabled,
                child: FloatingActionButton(
                    onPressed: () =>
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ClinicDataScreen(
                                  userId: _userId,
                                  selectedCountry: _selectedCountry,
                                  isNewItem: true,
                                  clinicDocumentPath: null,
                                  clinic: null,
                                  doctor: _doctor,
                                ))),
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.add,
                      color: primaryLightColor,
                    ))),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            body: isEnabled ? itemList() : getNotActivatedWidget()));
  }

  Widget _searchTextField() => TextField(
        enableSuggestions: true,
        autofocus: true,
        cursorColor: Colors.white,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
        textInputAction: TextInputAction.search,
        onSubmitted: (_) async {
          setState(() {
            searchText = searchFieldController.text.trim();
            _fetchingQuery = searchText.isNotEmpty
                ? _defaultQuery
                    ?.where('name',
                        isGreaterThanOrEqualTo: Utils().capitalize(searchText))
                    .where('name',
                        isLessThanOrEqualTo:
                            "${Utils().capitalize(searchText)}\uf7ff")
                : _defaultQuery;
          });
        },
        decoration: const InputDecoration(
          enabledBorder:
              UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder:
              UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          hintText: 'بحث...',
          hintStyle: TextStyle(
            color: Colors.white60,
            fontSize: 20,
          ),
        ),
        controller: searchFieldController,
      );

  appBarActions() => !_searchBoolean
      ? [
          Visibility(
              visible: isEnabled,
              child: IconButton(
                  icon: const Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _searchBoolean = true;
                    });
                  }))
        ]
      : [
          Visibility(
              visible: isEnabled,
              child: IconButton(
                  icon: const Icon(
                    Icons.clear,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _searchBoolean = false;
                      _fetchingQuery = _defaultQuery;
                      searchFieldController.clear();
                    });
                  }))
        ];

  Widget itemList() => StreamBuilder(
      stream: _fetchingQuery?.snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          List<QueryDocumentSnapshot> docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(
                child: Text(
              'من فضلك أضف بيانات عياداتك !',
              style: TextStyle(color: AppColors.secondaryColor3),
            ));
          }
          Map map = (docs).asMap();
          clinics.clear();
          map.forEach((dynamic, json) => clinics.add(Clinic.fromJson(json)));
          return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, i) {
                return Directionality(
                    textDirection: ui.TextDirection.rtl,
                    child: GestureDetector(
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: primaryGradientColors,
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            ),
                            height: 120,
                            padding: const EdgeInsets.all(2),
                            child: Column(
                              children: [
                                Expanded(
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
                                                image: NetworkImage(
                                                    clinics[i].logo!),
                                                fit: BoxFit.fill)),
                                      ),
                                    ),
                                    const Spacer(
                                      flex: 1,
                                    ),
                                    Expanded(
                                      flex: getTextsAreaFlex(
                                          clinics[i].doctorUserId == _userId,
                                          clinics[i].phoneNumber != null &&
                                              clinics[i]
                                                  .phoneNumber!
                                                  .isNotEmpty),
                                      child: Container(
                                        padding: const EdgeInsets.only(
                                            top: 10, bottom: 10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Flexible(
                                                flex: 2,
                                                fit: FlexFit.loose,
                                                child: Text(
                                                    clinics[i].name ?? '',
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    textDirection:
                                                        ui.TextDirection.rtl,
                                                    style: const TextStyle(
                                                        fontSize: 16.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white))),
                                            const Spacer(
                                              flex: 1,
                                            ),
                                            Flexible(
                                                flex: 2,
                                                fit: FlexFit.loose,
                                                child: Text(
                                                    clinics[i].address ?? '',
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    textDirection:
                                                        ui.TextDirection.rtl,
                                                    style: const TextStyle(
                                                        fontSize: 15.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: AppColors
                                                            .secondaryColor2))),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ]),
                                ),
                                Visibility(
                                    visible: clinics[i].doctorUserId == _userId,
                                    child: SizedBox(
                                        height: 40,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Visibility(
                                                visible:
                                                    clinics[i].phoneNumber !=
                                                            null &&
                                                        clinics[i]
                                                            .phoneNumber!
                                                            .isNotEmpty,
                                                child: IconButton(
                                                  onPressed: () => socialMediaOperations
                                                      ?.launchStringUrl(
                                                          socialMediaOperations!
                                                              .getCallUrl(clinics[
                                                                      i]
                                                                  .phoneNumber
                                                                  .toString())),
                                                  icon: const Icon(
                                                    Icons.call,
                                                    color: Colors.white,
                                                    size: 25,
                                                  ),
                                                )),
                                            IconButton(
                                              onPressed: () {
                                                Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                        builder: (context) {
                                                  String path =
                                                      docs[i].reference.path;
                                                  String documentId =
                                                      docs[i].reference.id;
                                                  return DoctorClinicAvailableDaysScreen(
                                                      clinicDocumentPath: path,
                                                      clinic: clinics[i],
                                                      clinicId: documentId);
                                                }));
                                              },
                                              icon: const Icon(
                                                FontAwesomeIcons.calendarDays,
                                                color: Colors.white,
                                                size: 25,
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                        builder: (context) {
                                                  String path = snapshot.data!
                                                      .docs[i].reference.path;
                                                  return ClinicDataScreen(
                                                    userId: _userId,
                                                    selectedCountry:
                                                        _selectedCountry,
                                                    isNewItem: false,
                                                    clinicDocumentPath: path,
                                                    clinic: clinics[i],
                                                    doctor: _doctor,
                                                  );
                                                }));
                                              },
                                              icon: const Icon(
                                                Icons.edit,
                                                color: Colors.white,
                                                size: 25,
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                String path = snapshot.data!
                                                    .docs[i].reference.path;
                                                showDialog<String>(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) =>
                                                          AlertDialog(
                                                    title: const Text(
                                                      'حذف عيادة',
                                                      style: TextStyle(
                                                          color: Colors.black),
                                                      textDirection:
                                                          ui.TextDirection.rtl,
                                                    ),
                                                    content: Text(
                                                        'هل متأكد أنك تريد حذف ${clinics[i].name}',
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.black),
                                                        textDirection: ui
                                                            .TextDirection.rtl),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                context,
                                                                'Cancel'),
                                                        child: const Text(
                                                          'إلغاء',
                                                          style: TextStyle(
                                                              color: AppColors
                                                                  .primaryColor),
                                                        ),
                                                      ),
                                                      TextButton(
                                                        onPressed: () =>
                                                            deleteItem(path,
                                                                clinics[i]),
                                                        child: const Text(
                                                          'نعم',
                                                          style: TextStyle(
                                                              color: AppColors
                                                                  .primaryColor),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                              icon: const Icon(
                                                Icons.delete,
                                                color: Colors.white,
                                                size: 25,
                                              ),
                                            )
                                          ],
                                        ))),
                              ],
                            )),
                      ),
                    ));
              });
        }
        if (snapshot.hasError) {
          return const Center(
              child: Text(
            'عفواً، حدث خطأ ما!',
            style: TextStyle(color: Colors.red),
          ));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        return const Center(
            child: Text(
          'عفواً، حدث خطأ ما!',
          style: TextStyle(color: Colors.red),
        ));
      });

  int getTextsAreaFlex(bool isEditable, bool isCallable) =>
      (isEditable ? 14 : 16) - (isCallable ? 2 : 0);

  void deleteItem(String path, Clinic clinic) {
    FirebaseFirestore.instance.doc(path).delete().then((value) {
      firebaseStorage.refFromURL(clinic.logo!).delete();
      for (dynamic image in clinic.images!) {
        firebaseStorage.refFromURL(image).delete();
      }
      for (dynamic image in clinic.documents!) {
        firebaseStorage.refFromURL(image).delete();
      }
      Fluttertoast.showToast(msg: 'تم حذف العيادة بنجاح!');
      Navigator.pop(context, 'Ok');
    });
  }

  getNotActivatedWidget() => const Padding(
        padding: EdgeInsets.all(14),
        child: Center(
          child: Text(
            'عفواً، حسابك غير مفعل بعد !\n طلبك قيد المراجعة من قِبل الأدمن... ',
            style: TextStyle(color: AppColors.secondaryColor4, fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      );
}

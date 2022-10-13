import 'dart:ui' as ui;

import 'package:clinico/constants/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../constants/utils.dart';
import '../../../helper/shared_preferences.dart';
import '../../../model/ad.dart';
import '../../../model/user_data.dart';
import 'ad_data_screen.dart';

class AdsManagerScreen extends StatefulWidget {
  bool isDevicesAds = true;

  AdsManagerScreen({Key? key, required this.isDevicesAds}) : super(key: key);

  @override
  _AdsManagerScreenState createState() => _AdsManagerScreenState();
}

class _AdsManagerScreenState extends State<AdsManagerScreen> {
  DateFormat dateFormat = DateFormat('yyyy/MM/dd - hh:mm a');
  List<Ad> ads = <Ad>[];
  Query<Map<String, dynamic>>? adsQuery;
  late final AppData _appData;
  String? _selectedCountry, _userId, _adminId;
  FirebaseFirestore? _firebaseFirestore;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  late CollectionReference<Map<String, dynamic>>? adminsRef;

  @override
  void initState() {
    _firebaseFirestore = FirebaseFirestore.instance;
    adminsRef =
        _firebaseFirestore!.collection(FirestoreCollections.Admins.name);
    _appData = AppData();
    _appData.getSharedPreferencesInstance().then((pref) {
      _selectedCountry = _appData.getSelectedCountry(pref!)!;
      _userId = _appData.getUserId(pref)!;
      adminsRef?.where('userId', isEqualTo: _userId).get().then((snapshots) {
        QueryDocumentSnapshot<Map<String, dynamic>> queryDocumentSnapshot =
            snapshots.docs.first;
        if (queryDocumentSnapshot.exists) {
          setState(() {
            _adminId = queryDocumentSnapshot.reference.id;
          });
        }
      });
    });
    adsQuery = FirebaseFirestore.instance
        .collection(widget.isDevicesAds
            ? FirestoreCollections.DevicesAds.name
            : FirestoreCollections.ClinicsAds.name)
        .orderBy('selectedCountry', descending: false)
        .orderBy('isActive', descending: true)
        .orderBy('expiryDate', descending: true)
        .orderBy('priority', descending: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: ui.TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
                'إدارة إعلانات ${widget.isDevicesAds ? 'الأجهزة الطبية' : 'العيادات'}',
                style:
                    const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
          ),
          body: StreamBuilder(
              stream: adsQuery?.snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  List<QueryDocumentSnapshot> docs = snapshot.data!.docs;
                  if (docs.isEmpty) {
                    return const Center(
                        child: Text('عفواً، لا يوجد بيانات!',
                            style: TextStyle(color: Colors.blue)));
                  }
                  Map map = (docs).asMap();
                  ads.clear();
                  map.forEach((dynamic, json) => ads.add(Ad.fromJson(json)));
                  return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        return Directionality(
                            textDirection: ui.TextDirection.rtl,
                            child: GestureDetector(
                              onTap: () => openUrl(ads[index].redirectLink),
                              child: Card(
                                clipBehavior: Clip.antiAlias,
                                child: Container(
                                  height: 100,
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(7.0)),
                                    image: DecorationImage(
                                      image:
                                          NetworkImage(ads[index].image ?? ''),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  child: Row(children: [
                                    Expanded(
                                      flex: 3,
                                      child: Icon(
                                        FontAwesomeIcons.certificate,
                                        color: getAdBackgroundColor(
                                            ads[index].expiryDate!.toDate(),
                                            ads[index].isActive),
                                        size: 40,
                                      ),
                                    ),
                                    const Spacer(
                                      flex: 1,
                                    ),
                                    Expanded(
                                      flex: 14,
                                      child: Container(
                                        padding: const EdgeInsets.only(top: 5),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: <Widget>[
                                            Expanded(
                                                flex: 2,
                                                child: Text(
                                                    ads[index].title ?? '',
                                                    textDirection:
                                                        ui.TextDirection.rtl,
                                                    style: const TextStyle(
                                                        fontSize: 12.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white))),
                                            Expanded(
                                                flex: 1,
                                                child: Text(
                                                    'Country: ${ads[index].selectedCountry}',
                                                    textDirection:
                                                        ui.TextDirection.rtl,
                                                    style: const TextStyle(
                                                        fontSize: 12.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white))),
                                            Expanded(
                                                flex: 1,
                                                child: Text(
                                                    dateFormat.format(ads[index]
                                                        .expiryDate!
                                                        .toDate()),
                                                    textDirection:
                                                        ui.TextDirection.rtl,
                                                    style: const TextStyle(
                                                        fontSize: 12.0,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color: Colors.white))),
                                            Expanded(
                                                flex: 1,
                                                child: Text(
                                                    'Priority: ${ads[index].priority}',
                                                    textDirection:
                                                        ui.TextDirection.rtl,
                                                    style: const TextStyle(
                                                        fontSize: 12.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white))),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const Spacer(
                                      flex: 1,
                                    ),
                                    Expanded(
                                        flex: 3,
                                        child: ListView(
                                          children: [
                                            IconButton(
                                              onPressed: () {
                                                DatePicker.showDatePicker(
                                                    context,
                                                    showTitleActions: true,
                                                    minTime:
                                                        DateTime(2022, 1, 1),
                                                    maxTime:
                                                        DateTime(2040, 12, 31),
                                                    onConfirm: (newExpiryDate) {
                                                  String path = docs
                                                      .elementAt(index)
                                                      .reference
                                                      .path;
                                                  updateAdExpiryDate(
                                                      path, newExpiryDate);
                                                },
                                                    currentTime: ads[index]
                                                        .expiryDate!
                                                        .toDate(),
                                                    locale: LocaleType.ar);
                                              },
                                              icon: const Icon(
                                                Icons.wifi_protected_setup,
                                                color: Colors.white,
                                                size: 30,
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                String path = docs
                                                    .elementAt(index)
                                                    .reference
                                                    .path;
                                                showDialog<String>(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) =>
                                                          AlertDialog(
                                                    title: Text(
                                                      getActivationText(
                                                          ads[index].isActive),
                                                      style: const TextStyle(
                                                          color: Colors.black),
                                                      textDirection:
                                                          ui.TextDirection.rtl,
                                                    ),
                                                    content: Text(
                                                        ' هل متأكد من ${getActivationText(ads[index].isActive)}',
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
                                                        child:
                                                            const Text('إلغاء'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () =>
                                                            changeAdActivation(
                                                                path,
                                                                ads[index]
                                                                    .isActive),
                                                        child:
                                                            const Text('نعم'),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                              icon: Icon(
                                                getActivationIcon(
                                                    ads[index].isActive),
                                                color: Colors.white,
                                                size: 30,
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                        builder: (context) {
                                                  String path = docs
                                                      .elementAt(index)
                                                      .reference
                                                      .path;
                                                  return AdDataScreen(
                                                    adPath: path,
                                                    ad: ads[index],
                                                    isNew: false,
                                                    isDevicesAds:
                                                        widget.isDevicesAds,
                                                    adminId: _adminId,
                                                    selectedCountry:
                                                        _selectedCountry,
                                                  );
                                                }));
                                              },
                                              icon: const Icon(
                                                Icons.edit,
                                                color: Colors.white,
                                                size: 30,
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                String path = docs
                                                    .elementAt(index)
                                                    .reference
                                                    .path;
                                                showDialog<String>(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) =>
                                                          AlertDialog(
                                                    title: const Text(
                                                      'حذف عنصر',
                                                      style: TextStyle(
                                                          color: Colors.black),
                                                      textDirection:
                                                          ui.TextDirection.rtl,
                                                    ),
                                                    content: const Text(
                                                        'هل متأكد من حذف الإعلان ؟',
                                                        style: TextStyle(
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
                                                        child:
                                                            const Text('إلغاء'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () =>
                                                            deleteAd(
                                                                path,
                                                                ads[index]
                                                                    .image!),
                                                        child:
                                                            const Text('نعم'),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                              icon: const Icon(
                                                Icons.delete,
                                                color: Colors.white,
                                                size: 30,
                                              ),
                                            ),
                                          ],
                                        ))
                                  ]),
                                ),
                              ),
                            ));
                      });
                }
                if (snapshot.hasError) {
                  return const Text(
                    'حدث خطأ ما!',
                    style: TextStyle(color: Colors.red),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                return const Text(
                  'حدث خطأ ما!',
                  style: TextStyle(color: Colors.red),
                );
              }),
          floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return AdDataScreen(
                    adPath: null,
                    ad: null,
                    isNew: true,
                    isDevicesAds: widget.isDevicesAds,
                    adminId: _adminId,
                    selectedCountry: _selectedCountry,
                  );
                }));
              },
              backgroundColor: Colors.white,
              child: const Icon(
                Icons.add,
                color: Color(0xFF4772C6),
              )),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        ));
  }

  Color getAdBackgroundColor(DateTime expiryDate, bool running) {
    if (!running) return AppColors.secondaryColor4;

    DateTime now = Jiffy(DateTime.now()).dateTime;
    if (expiryDate.compareTo(now) >= 0)
      return AppColors.primaryColor;
    else
      return AppColors.secondaryColor2;
  }

  void updateAdExpiryDate(String path, DateTime newExpiryDate) {
    FirebaseFirestore.instance
        .doc(path)
        .update({"expiryDate": newExpiryDate}).then((value) =>
            Fluttertoast.showToast(
                msg: " تاريخ انتهاء الإعلان الجديد: ${newExpiryDate} "));
  }

  String getActivationText(bool isActive) => isActive ? 'إلغاء تفعيل' : 'تفعيل';

  IconData getActivationIcon(bool isActive) =>
      isActive ? Icons.pause : Icons.play_arrow;

  void changeAdActivation(String path, bool isActive) {
    FirebaseFirestore.instance
        .doc(path)
        .update({"isActive": !isActive}).then((value) => {
              Fluttertoast.showToast(
                  msg: " تم ${getActivationText(isActive)} الإعلان بنجاح "),
              Navigator.pop(context, 'Ok')
            });
  }

  void deleteAd(String path, String image) {
    FirebaseFirestore.instance.doc(path).delete().then((value) async => {
          if (Utils().isNetworkUrl(image))
            {
              await _firebaseStorage
                  .refFromURL(image)
                  .delete()
                  .then((value) => {
                        Fluttertoast.showToast(msg: "! تم حذف الإعلان بنجاح"),
                        Navigator.pop(context, 'Ok')
                      })
            },
        });
  }

  void openUrl(String? adRedirectLink) async {
    if (adRedirectLink != null && adRedirectLink.isNotEmpty) {
      Uri uri = Uri.parse(adRedirectLink);
      canLaunchUrl(uri).then((value) async {
        if (value) {
          await launchUrl(uri);
        }
      });
    }
  }
}

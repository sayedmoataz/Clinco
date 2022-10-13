import 'dart:ui' as ui;

import 'package:clinico/view/screens/physician_impersonators_map_screen.dart';
import 'package:clinico/view/screens/view_physician_impersonator_profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../constants/app_colors.dart';
import '../../../model/user_data.dart';
import '../../helper/shared_preferences.dart';
import '../../model/physician_impersonator.dart';
import 'admin_part/physician_impersonator_data_screen.dart';

class PhysicianImpersonatorListItemScreen extends StatefulWidget {
  const PhysicianImpersonatorListItemScreen({Key? key}) : super(key: key);

  @override
  _PhysicianImpersonatorListItemScreenState createState() =>
      _PhysicianImpersonatorListItemScreenState();
}

class _PhysicianImpersonatorListItemScreenState
    extends State<PhysicianImpersonatorListItemScreen> {
  Color primaryLightColor = AppColors.primaryColor;
  List<Color> primaryGradientColors = AppColors.primaryGradientColors;
  BuildContext? dialogContext;
  List<PhysicianImpersonator> physicianImpersonators =
      <PhysicianImpersonator>[];
  FirebaseFirestore? _firebaseFirestore;
  late Query<Map<String, dynamic>>? _defaultQuery;
  Query<Map<String, dynamic>>? _fetchingQuery;
  FirebaseStorage firebaseStorage = FirebaseStorage.instance;
  late final AppData _appData;
  String? _accountType, _adminUserId, _selectedCountry;
  bool _isAdmin = false;

  @override
  void initState() {
    _firebaseFirestore = FirebaseFirestore.instance;
    _defaultQuery = _firebaseFirestore!
        .collection(FirestoreCollections.PhysicianImpersonators.name)
        .orderBy('name', descending: false);

    _appData = AppData();
    _appData.getSharedPreferencesInstance().then((pref) {
      _adminUserId = _appData.getUserId(pref!)!;
      _accountType = _appData.getAccountType(pref)!;
      _isAdmin = (_accountType == AccountTypes.Admin.name);
      _selectedCountry = _appData.getSelectedCountry(pref)!;
      setState(() {
        _isAdmin
            ? _fetchingQuery = _defaultQuery
            : _fetchingQuery = _defaultQuery?.where('selectedCountry',
                isEqualTo: _selectedCountry);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('منتحلي صفة الأطباء',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            // flexibleSpace: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: primaryGradientColors),),),
            // actions: [IconButton(icon: const Icon(FontAwesomeIcons.mapLocationDot, color: AppColors.secondaryColor2,), onPressed: () => _mapButtonClicked(),),],
          ),
          floatingActionButton: Visibility(
              visible: _isAdmin,
              child: FloatingActionButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => PhysicianImpersonatorDataScreen(
                            adminUserId: _adminUserId,
                            isNewItem: true,
                            physicianImpersonatorDocumentPath: null,
                            physicianImpersonator: null,
                          ))),
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.add,
                    color: primaryLightColor,
                  ))),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          body: Column(
            children: [
              Expanded(
                child: itemList(),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => _mapButtonClicked(),
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                        color: AppColors.appPrimaryColor,
                        borderRadius: BorderRadius.circular(25)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          "عرض العيادات على الخريطة",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Icon(
                          FontAwesomeIcons.mapLocationDot,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              )
            ],
          ),
        ));
  }

  Widget itemList() => StreamBuilder(
      stream: _fetchingQuery?.snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          List<QueryDocumentSnapshot> docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return Center(
                child: Text(
              'عفواً، لا يوجد بيانات!',
              style: TextStyle(color: primaryLightColor),
            ));
          }
          Map map = (docs).asMap();
          physicianImpersonators.clear();
          map.forEach((dynamic, json) =>
              physicianImpersonators.add(PhysicianImpersonator.fromJson(json)));
          return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, i) {
                return Directionality(
                    textDirection: ui.TextDirection.rtl,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              ViewPhysicianImpersonatorProfileScreen(
                                  physicianImpersonator:
                                      physicianImpersonators[i]))),
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
                          height: 100,
                          padding: const EdgeInsets.all(2),
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
                                            physicianImpersonators[i].logo!),
                                        fit: BoxFit.fill)),
                              ),
                            ),
                            const Spacer(
                              flex: 1,
                            ),
                            Expanded(
                              flex: _isAdmin ? 14 : 16,
                              child: Container(
                                padding:
                                    const EdgeInsets.only(top: 10, bottom: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Flexible(
                                        flex: 6,
                                        fit: FlexFit.loose,
                                        child: Text(
                                            physicianImpersonators[i].name ??
                                                '',
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            textDirection: ui.TextDirection.rtl,
                                            style: const TextStyle(
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white))),
                                    const Spacer(
                                      flex: 1,
                                    ),
                                    Flexible(
                                        flex: 5,
                                        fit: FlexFit.loose,
                                        child: Text(
                                            physicianImpersonators[i]
                                                    .doctorName ??
                                                '',
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            textDirection: ui.TextDirection.rtl,
                                            style: const TextStyle(
                                                fontSize: 12.0,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors
                                                    .secondaryColor2))),
                                    const Spacer(
                                      flex: 1,
                                    ),
                                    Flexible(
                                        flex: 5,
                                        fit: FlexFit.loose,
                                        child: Text(
                                            physicianImpersonators[i].address ??
                                                '',
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            textDirection: ui.TextDirection.rtl,
                                            style: const TextStyle(
                                                fontSize: 12.0,
                                                fontWeight: FontWeight.normal,
                                                color: AppColors
                                                    .secondaryColor2))),
                                    const Spacer(
                                      flex: 1,
                                    ),
                                    Visibility(
                                        visible: _isAdmin,
                                        child: Flexible(
                                            flex: 5,
                                            fit: FlexFit.loose,
                                            child: Text(
                                                physicianImpersonators[i]
                                                        .selectedCountry ??
                                                    '',
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                textDirection:
                                                    ui.TextDirection.rtl,
                                                style: const TextStyle(
                                                    fontSize: 12.0,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color: AppColors
                                                        .secondaryColor2))))
                                  ],
                                ),
                              ),
                            ),
                            Visibility(
                                visible: _isAdmin,
                                child: Expanded(
                                    flex: 2,
                                    child: Column(
                                      children: [
                                        Flexible(
                                            flex: 2,
                                            fit: FlexFit.loose,
                                            child: IconButton(
                                              onPressed: () {
                                                Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                        builder: (context) {
                                                  String path = snapshot.data!
                                                      .docs[i].reference.path;
                                                  return PhysicianImpersonatorDataScreen(
                                                    adminUserId: _adminUserId,
                                                    isNewItem: false,
                                                    physicianImpersonatorDocumentPath:
                                                        path,
                                                    physicianImpersonator:
                                                        physicianImpersonators[
                                                            i],
                                                  );
                                                }));
                                              },
                                              icon: const Icon(
                                                Icons.edit,
                                                color: Colors.white,
                                                size: 25,
                                              ),
                                            )),
                                        Flexible(
                                            flex: 2,
                                            fit: FlexFit.loose,
                                            child: IconButton(
                                              onPressed: () {
                                                String path = snapshot.data!
                                                    .docs[i].reference.path;
                                                showDialog<String>(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) =>
                                                          AlertDialog(
                                                    title: const Text(
                                                      'حذف',
                                                      style: TextStyle(
                                                          color: Colors.black),
                                                      textDirection:
                                                          ui.TextDirection.rtl,
                                                    ),
                                                    content: Text(
                                                        'هل متأكد أنك تريد حذف ${physicianImpersonators[i].name}',
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
                                                        onPressed: () => deleteItem(
                                                            path,
                                                            physicianImpersonators[
                                                                i]),
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
                                            ))
                                      ],
                                    ))),
                          ]),
                        ),
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

  void deleteItem(String path, PhysicianImpersonator physicianImpersonator) {
    FirebaseFirestore.instance.doc(path).delete().then((value) {
      firebaseStorage.refFromURL(physicianImpersonator.logo!).delete();
      Fluttertoast.showToast(msg: 'تم الحذف بنجاح!');
      Navigator.pop(context, 'Ok');
    });
  }

  _mapButtonClicked() {
    if (physicianImpersonators.isNotEmpty) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => PhysicianImpersonatorsMapScreen(
                selectedCountry: _selectedCountry,
                isAdmin: _isAdmin,
              )));
    } else {
      Fluttertoast.showToast(msg: 'عفواً، لا يوجد عيادات لعرضها!');
      return;
    }
  }
}

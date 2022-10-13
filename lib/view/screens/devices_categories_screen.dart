import 'package:clinico/constants/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../helper/shared_preferences.dart';
import '../../model/devices_category.dart';
import '../../model/user_data.dart';
import 'category_data_screen.dart';
import 'device_list_screen.dart';

class DevicesCategoriesScreen extends StatefulWidget {
  final bool isNew, isAdmin;

  const DevicesCategoriesScreen(
      {Key? key, required this.isNew, required this.isAdmin})
      : super(key: key);

  @override
  _DevicesCategoriesScreenState createState() =>
      _DevicesCategoriesScreenState();
}

class _DevicesCategoriesScreenState extends State<DevicesCategoriesScreen> {
  List<DevicesCategory> devicesCategories = <DevicesCategory>[];
  CollectionReference? devicesCategoriesRef;
  Query<Object?>? _fetchingQuery;
  late final AppData _appData;
  String? _accountType, _selectedCountry;
  bool _isPatient = true;

  @override
  void initState() {
    super.initState();
    _appData = AppData();
    _appData.getSharedPreferencesInstance().then((pref) {
      setState(() {
        _accountType = _appData.getAccountType(pref!)!;
        _isPatient = (_accountType == AccountTypes.Patient.name);
        _selectedCountry = _appData.getSelectedCountry(pref);
        devicesCategoriesRef = FirebaseFirestore.instance
            .collection(FirestoreCollections.DevicesCategories.name);
        _fetchingQuery = devicesCategoriesRef
            ?.where('isNew', isEqualTo: widget.isNew)
            .where('selectedCountry', isEqualTo: _selectedCountry)
            .orderBy('arabicTitle', descending: false);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    if (devicesCategoriesRef != null) {
      return Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              Flexible(
                child: StreamBuilder(
                    stream: _isPatient
                        ? _fetchingQuery
                            ?.where('isAvailableForPatient', isEqualTo: true)
                            .snapshots()
                        : _fetchingQuery?.snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasData) {
                        List<QueryDocumentSnapshot> docs = snapshot.data!.docs;
                        if (docs.isEmpty) {
                          return const Center(
                              child: Text('عفواً، لا يوجد بيانات!',
                                  style: TextStyle(color: Colors.blue)));
                        }
                        Map map = (docs).asMap();
                        devicesCategories.clear();
                        map.forEach((dynamic, json) => devicesCategories
                            .add(DevicesCategory.fromJson(json)));
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Directionality(
                              textDirection: TextDirection.rtl,
                              child: GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        childAspectRatio: 0.75,
                                        mainAxisSpacing: 8,
                                        crossAxisSpacing: 8),
                                itemCount: devicesCategories.length,
                                padding: const EdgeInsets.all(2.0),
                                itemBuilder: (BuildContext context, int index) {
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(builder: (context) {
                                        String categoryDocumentPath = docs
                                            .elementAt(index)
                                            .reference
                                            .path;
                                        return DeviceListScreen(
                                          categoryDocumentPath:
                                              categoryDocumentPath,
                                          catTitle: devicesCategories[index]
                                                  .arabicTitle ??
                                              '',
                                          isNewCategory: widget.isNew,
                                        );
                                      }));
                                    },
                                    child: Container(
                                      // padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(11),
                                      ),
                                      child: SizedBox(
                                          width: (size.width / 3) - 2,
                                          height: 150,
                                          child: LayoutBuilder(builder:
                                              (BuildContext context,
                                                  BoxConstraints constraints) {
                                            return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    topRight:
                                                        Radius.circular(10),
                                                    topLeft:
                                                        Radius.circular(10),
                                                  ),
                                                  child: Image.network(
                                                    devicesCategories[index]
                                                            .image ??
                                                        '',
                                                    width: constraints.maxWidth,
                                                    height:
                                                        constraints.maxHeight *
                                                            (widget.isAdmin
                                                                ? 0.6
                                                                : 0.8),
                                                    fit: BoxFit.fill,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 1,
                                                ),
                                                Container(
                                                  alignment: Alignment.center,
                                                  height:
                                                      constraints.maxHeight *
                                                          0.15,
                                                  width: double.infinity,
                                                  decoration: BoxDecoration(
                                                    color: AppColors
                                                        .appPrimaryColor,
                                                    borderRadius: widget.isAdmin
                                                        ? BorderRadius.circular(
                                                            0)
                                                        : const BorderRadius
                                                            .only(
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    10),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    10),
                                                          ),
                                                  ),
                                                  child: Text(
                                                      devicesCategories[index]
                                                              .arabicTitle ??
                                                          '',
                                                      style: const TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color: Colors.black),
                                                      textAlign:
                                                          TextAlign.center),
                                                ),
                                                Visibility(
                                                    visible: widget.isAdmin,
                                                    child: Container(
                                                        alignment:
                                                            Alignment.center,
                                                        height: constraints
                                                                .maxHeight *
                                                            0.2,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: AppColors
                                                              .appPrimaryColor,
                                                          borderRadius:
                                                              const BorderRadius
                                                                  .only(
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    10),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    10),
                                                          ),
                                                        ),
                                                        width: double.infinity,
                                                        child: getManageIcons(
                                                            docs
                                                                .elementAt(
                                                                    index)
                                                                .reference
                                                                .path,
                                                            devicesCategories[
                                                                index]))),
                                              ],
                                            );
                                          })),
                                    ),
                                  );
                                },
                              )),
                        );
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
          ));
    } else {
      return const Center(child: CircularProgressIndicator());
      ;
    }
  }

  Widget getManageIcons(String documentPath, DevicesCategory devicesCategory) {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => CategoryDataScreen(
                    isNewCategory: widget.isNew,
                    isNewItem: false,
                    categoryDocumentPath: documentPath,
                    category: devicesCategory)));
          },
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
                  'حذف قسم',
                  style: TextStyle(color: Colors.black),
                  textDirection: TextDirection.rtl,
                ),
                content: Text(
                    'هل متأكد أنك تريد حذف ${devicesCategory.arabicTitle} ؟',
                    style: const TextStyle(color: Colors.black),
                    textDirection: TextDirection.rtl),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'Cancel'),
                    child: const Text('إلغاء'),
                  ),
                  TextButton(
                    onPressed: () =>
                        deleteCategory(documentPath, devicesCategory),
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

  void deleteCategory(String path, DevicesCategory devicesCategory) {
    FirebaseStorage.instance
        .refFromURL(devicesCategory.image!)
        .delete()
        .then((value) => {
              FirebaseFirestore.instance.doc(path).delete().then((value) => {
                    Fluttertoast.showToast(msg: 'تم الحذف بنجاح!'),
                    Navigator.pop(context, 'Ok')
                  })
            });
  }
}

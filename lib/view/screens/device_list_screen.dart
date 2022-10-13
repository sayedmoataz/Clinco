import 'dart:ui' as ui;

import 'package:clinico/constants/app_colors.dart';
import 'package:clinico/view/screens/view_device_details_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../constants/utils.dart';
import '../../helper/shared_preferences.dart';
import '../../model/device.dart';
import '../../model/user_data.dart';
import 'device_data_screen.dart';

class DeviceListScreen extends StatefulWidget {
  final String categoryDocumentPath;
  final String catTitle;
  final bool isNewCategory;

  const DeviceListScreen(
      {Key? key,
      required this.categoryDocumentPath,
      required this.catTitle,
      required this.isNewCategory})
      : super(key: key);

  @override
  _DeviceListScreenState createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends State<DeviceListScreen> {
  Color primaryLightColor = AppColors.primaryColor;
  List<Color> primaryGradientColors = AppColors.primaryGradientColors;
  bool isEnabled = false, _searchBoolean = false;
  final searchFieldController = TextEditingController();
  List<Device> devices = <Device>[];
  String? _devicesCollectionPath, _accountType, _userId, _selectedCountry;
  bool _isPatient = true;
  late Query<Map<String, dynamic>>? _defaultQuery, _defaultFetchingQuery;
  Query<Map<String, dynamic>>? _fetchingQuery;
  String searchText = '';
  late final AppData _appData;
  FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  @override
  void initState() {
    _devicesCollectionPath =
        '${widget.categoryDocumentPath}/${FirestoreCollections.Devices.name}';

    _defaultQuery =
        FirebaseFirestore.instance.collection(_devicesCollectionPath!);
    _defaultFetchingQuery = _defaultQuery?.orderBy('price', descending: false);
    _fetchingQuery = _defaultFetchingQuery;
    _appData = AppData();
    _appData.getSharedPreferencesInstance().then((pref) {
      _accountType = _appData.getAccountType(pref!)!;
      setState(() {
        _isPatient = (_accountType == AccountTypes.Patient.name);
      });
      _userId = _appData.getUserId(pref)!;
      _selectedCountry = _appData.getSelectedCountry(pref)!;
      int accountStatus = _appData.getAccountStatus(pref)!;
      String accountType = _appData.getAccountType(pref)!;
      if (accountStatus == 1 &&
          accountType != AccountTypes.Patient.name &&
          accountType != AccountTypes.Admin.name &&
          !(accountType == AccountTypes.Doctor.name && widget.isNewCategory)) {
        setState(() {
          isEnabled = true;
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    searchFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: ui.TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
              title: !_searchBoolean
                  ? Text(widget.catTitle,
                      style: const TextStyle(
                        fontSize: 20,
                        // fontWeight: FontWeight.bold
                      ))
                  : _searchTextField(),
              // flexibleSpace: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: primaryGradientColors),),),
              actions: appBarActions()),
          floatingActionButton: Visibility(
              visible: isEnabled,
              child: FloatingActionButton(
                  onPressed: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return DeviceDataScreen(
                        userId: _userId,
                        selectedCountry: _selectedCountry,
                        devicesCategoryCollectionPath: _devicesCollectionPath!,
                        isNewItem: true,
                        deviceDocumentPath: null,
                        device: null,
                      );
                    }));
                  },
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.add,
                    color: primaryLightColor,
                  ))),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          body: itemList(),
        ));
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
                    ?.orderBy('name', descending: false)
                    .where('name',
                        isGreaterThanOrEqualTo: Utils().capitalize(searchText))
                    .where('name',
                        isLessThanOrEqualTo:
                            "${Utils().capitalize(searchText)}\uf7ff")
                : _defaultFetchingQuery;
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
          IconButton(
              icon: const Icon(
                Icons.search,
                color: Colors.black,
              ),
              onPressed: () {
                setState(() {
                  _searchBoolean = true;
                });
              })
        ]
      : [
          IconButton(
              icon: const Icon(
                Icons.clear,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _searchBoolean = false;
                  _fetchingQuery = _defaultFetchingQuery;
                  searchFieldController.clear();
                });
              })
        ];

  Widget itemList() => StreamBuilder(
      stream: _isPatient
          ? _fetchingQuery
              ?.where('isAvailableForPatient', isEqualTo: true)
              .snapshots()
          : _fetchingQuery?.snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          List<QueryDocumentSnapshot> docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return Center(child: _getNoDataFoundMessage());
          }
          Map map = (docs).asMap();
          devices.clear();
          map.forEach((dynamic, json) => devices.add(Device.fromJson(json)));
          return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, i) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Directionality(
                      textDirection: ui.TextDirection.rtl,
                      child: GestureDetector(
                        onTap: () => {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  ViewDeviceDetailsScreen(device: devices[i])))
                        },
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
                            height: 160,
                            padding: const EdgeInsets.all(4),
                            child: Row(children: [
                              Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    image: DecorationImage(
                                        image: NetworkImage(
                                            devices[i].images?.first),
                                        fit: BoxFit.fill)),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.only(
                                      top: 10, bottom: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    // mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Flexible(
                                          child: Text(devices[i].name ?? '',
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              textDirection:
                                                  ui.TextDirection.rtl,
                                              style: const TextStyle(
                                                  fontSize: 20.0,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white))),
                                      Flexible(
                                          child: Text(devices[i].formattedPrice,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              textDirection:
                                                  ui.TextDirection.rtl,
                                              style: const TextStyle(
                                                  fontSize: 20.0,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors
                                                      .secondaryColor2))),
                                      Visibility(
                                          visible:
                                              devices[i].createdBy == _userId,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              IconButton(
                                                onPressed: () {
                                                  Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                          builder: (context) {
                                                    String path = snapshot.data!
                                                        .docs[i].reference.path;
                                                    return DeviceDataScreen(
                                                        userId: _userId,
                                                        selectedCountry:
                                                            _selectedCountry,
                                                        devicesCategoryCollectionPath:
                                                            _devicesCollectionPath!,
                                                        isNewItem: false,
                                                        deviceDocumentPath:
                                                            path,
                                                        device: devices[i]);
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
                                                    builder: (BuildContext
                                                            context) =>
                                                        AlertDialog(
                                                      title: const Text(
                                                        'حذف جهاز',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black),
                                                        textDirection: ui
                                                            .TextDirection.rtl,
                                                      ),
                                                      content: Text(
                                                          ' هل متأكد أنك تريد حذف ${devices[i].name} ',
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black),
                                                          textDirection: ui
                                                              .TextDirection
                                                              .rtl),
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
                                                                  devices[i]),
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
                                          )),
                                    ],
                                  ),
                                ),
                              ),
                              // Expanded(
                              //   flex: devices[i].createdBy != _userId ? 14 : 16,
                              //   child:
                              // ),
                            ]),
                          ),
                        ),
                      )),
                );
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

  void deleteItem(String path, Device device) {
    FirebaseFirestore.instance.doc(path).delete().then((value) {
      for (dynamic image in device.images!) {
        firebaseStorage.refFromURL(image).delete();
      }
      Fluttertoast.showToast(msg: "تم الحذف بنجاح");
      Navigator.pop(context, 'Ok');
    });
  }

  Widget _getNoDataFoundMessage() {
    if (isEnabled) {
      return const Text(
        'من فضلك أضف الجهاز الذي تريد عرضه!',
        style: TextStyle(color: AppColors.secondaryColor3),
      );
    } else {
      return Text(
        'عفواً، لا يوجد بيانات!',
        style: TextStyle(color: primaryLightColor),
      );
    }
  }
}

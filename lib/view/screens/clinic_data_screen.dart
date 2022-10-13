import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:clinico/constants/utils.dart';
import 'package:clinico/model/clinic.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_pick_place/google_maps_pick_place.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:path/path.dart';

import '../../constants/account_constants.dart';
import '../../constants/app_colors.dart';
import '../../model/clinic_available_day.dart';
import '../../model/doctor.dart';
import '../../model/speciality.dart';
import '../../model/user_data.dart';
import '../components/alert.dart';
import '../components/custom_circular_widget.dart';
import '../components/map_confirmation_selection_button_widget.dart';
import 'custom_google_maps_pick_place.dart';

class ClinicDataScreen extends StatefulWidget {
  String? userId, selectedCountry;
  bool isNewItem = true;
  String? clinicDocumentPath;
  Clinic? clinic;
  Doctor? doctor;

  ClinicDataScreen(
      {Key? key,
      required this.userId,
      required this.selectedCountry,
      required this.isNewItem,
      required this.clinicDocumentPath,
      required this.clinic,
      required this.doctor})
      : super(key: key);

  @override
  _ClinicDataScreenState createState() => _ClinicDataScreenState();
}

class _ClinicDataScreenState extends State<ClinicDataScreen> {
  BuildContext? dialogContext;
  Color primaryColor = AppColors.primaryColor;
  List<Color> primaryGradientColors = AppColors.primaryGradientColors;
  List<String> clinicRevealWays = AccountConstants.clinicRevealWays,
      clinicPaymentWays = AccountConstants.clinicPaymentWays;
  Clinic? _clinic;
  Speciality? _clinicSpeciality;
  String clinicsCollectionPath = FirestoreCollections.Clinics.name;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  late Reference clinicLogoFirebaseStorageReference,
      clinicImagesFirebaseStorageReference,
      clinicDocumentsFirebaseStorageReference;
  late final String initialLogo;
  String? currentLogo;
  late List<dynamic> initialImageList, initialDocumentList;
  List<dynamic> currentImageList = [], currentDocumentList = [];
  GeoPoint? clinicMapLocation;
  bool _trainingIsAvailable = false, _workIsAvailable = false;

  @override
  void initState() {
    if (!widget.isNewItem) {
      _clinic = widget.clinic;
      if (_clinic != null) {
        _trainingIsAvailable = _clinic!.trainingIsAvailable;
        _workIsAvailable = _clinic!.workIsAvailable;
      }
      if (_clinic?.geoLocation != null) {
        clinicMapLocation = _clinic!.geoLocation;
      }
      if (_clinic?.logo != null && _clinic!.logo!.isNotEmpty) {
        initialLogo = _clinic!.logo!;
        currentLogo = initialLogo;
      }
      if (_clinic?.images != null) {
        initialImageList = List.unmodifiable(_clinic!.images!);
        currentImageList.addAll(initialImageList);
      }
      if (_clinic?.documents != null) {
        initialDocumentList = List.unmodifiable(_clinic!.documents!);
        currentDocumentList.addAll(initialDocumentList);
      }
    } else {
      initialLogo = '';
      initialImageList = List.unmodifiable([]);
      initialDocumentList = List.unmodifiable([]);
      _clinic = Clinic(
          widget.userId,
          null,
          null,
          null,
          widget.doctor?.specialityId,
          null,
          null,
          widget.selectedCountry,
          null,
          0,
          0,
          0,
          0,
          <dynamic>[],
          <dynamic>[],
          false,
          false,
          false);
    }
    getClinicSpeciality();
    clinicLogoFirebaseStorageReference = _firebaseStorage
        .ref('${_clinic!.doctorUserId}/$clinicsCollectionPath/logos');
    clinicImagesFirebaseStorageReference = _firebaseStorage
        .ref('${_clinic!.doctorUserId}/$clinicsCollectionPath/images');
    clinicDocumentsFirebaseStorageReference = _firebaseStorage
        .ref('${_clinic!.doctorUserId}/$clinicsCollectionPath/documents');
    super.initState();
  }

  getClinicSpeciality() {
    _firebaseFirestore
        .collection(FirestoreCollections.Specialties.name)
        .doc(_clinic?.specialityId)
        .get()
        .then((value) {
      setState(() {
        _clinicSpeciality = Speciality.fromJson(value.data());
      });
    });
  }

  GlobalKey<FormState> formstate = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    LoadingIndicator dialog = loadingIndicatorWidget();

    return Directionality(
        textDirection: ui.TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: Text(getToolbarTitle(),
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: primaryGradientColors),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.save,
                  color: Colors.white,
                ),
                onPressed: () async {
                  await saveClinicData(context, widget.isNewItem, dialog);
                },
              ),
            ],
          ),
          body: Container(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: ListView(
                children: [
                  Form(
                      key: formstate,
                      child: Column(children: [
                        Container(
                          margin: const EdgeInsets.only(left: 1, right: 1),
                          width: 100,
                          height: 100,
                          child: CustomCircularWidget(
                            imageProvider: getImageByItem(currentLogo ?? ''),
                            borderColor: primaryColor,
                            isEditable: true,
                            isEdit: true,
                            onClicked: () async {
                              _showSelectImageBottomSheet(
                                  context, dialog, 'لوجو العيادة', true, null);
                            },
                          ),
                        ),
                        TextFormField(
                            enableInteractiveSelection: true,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.text,
                            initialValue: _clinic?.name ?? '',
                            validator: (val) {
                              String text = val.toString().trim();
                              if (text.length > 100) {
                                return 'أقصى عدد للأحرف هو ١٠٠';
                              }
                              if (text.length < 2) {
                                return 'أقل عدد للأحرف هو ٢';
                              }
                              return null;
                            },
                            onSaved: (val) {
                              _clinic?.name =
                                  Utils().capitalize(val.toString().trim());
                            },
                            maxLength: 100,
                            decoration: const InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: "إسم العيادة",
                                prefixIcon: Icon(
                                    FontAwesomeIcons.houseChimneyMedical))),
                        TextFormField(
                            enableInteractiveSelection: true,
                            keyboardType: TextInputType.multiline,
                            minLines: 1,
                            maxLines: 5,
                            textInputAction: TextInputAction.next,
                            initialValue: _clinic?.about ?? '',
                            validator: (val) {
                              String text = val.toString().trim();
                              if (text.length > 1000) {
                                return 'أقصى عدد للأحرف هو ١٠٠٠';
                              }
                              if (text.length < 10) {
                                return 'أقل عدد للأحرف هو ١٠';
                              }
                              return null;
                            },
                            onSaved: (val) {
                              _clinic?.about =
                                  Utils().capitalize(val.toString().trim());
                            },
                            maxLength: 1000,
                            decoration: const InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: "عن العيادة",
                                prefixIcon: Icon(FontAwesomeIcons.circleInfo))),
                        TextFormField(
                            enableInteractiveSelection: true,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.phone,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            initialValue: _clinic?.phoneNumber ?? '',
                            validator: (val) {
                              String text = val.toString().trim();
                              if (text.length !=
                                  AccountConstants
                                      .getPhoneNumberDigitCountByCountryName(
                                          widget.selectedCountry!)) {
                                return 'رقم الهاتف غير صحيح!';
                              }
                              return null;
                            },
                            onSaved: (val) {
                              _clinic?.phoneNumber =
                                  Utils().capitalize(val.toString().trim());
                            },
                            maxLength: AccountConstants
                                .getPhoneNumberDigitCountByCountryName(
                                    widget.selectedCountry!),
                            decoration: const InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: 'رقم الهاتف (010xxxxxxxx)',
                                prefixIcon: Icon(FontAwesomeIcons.phoneFlip))),
                        const SizedBox(height: 3),
                        TextFormField(
                            enableInteractiveSelection: false,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            initialValue: '${_clinic?.price ?? ''}',
                            validator: (val) {
                              String text = val.toString().trim();
                              if (text.isEmpty ||
                                  int.parse(text) <= 0 ||
                                  int.parse(text) > 1000) {
                                return 'السعر غير صالح!';
                              }
                              return null;
                            },
                            onSaved: (val) {
                              _clinic?.price = int.parse(val.toString().trim());
                            },
                            decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText:
                                    'سعر الكشف (${AccountConstants.getPriceCurrencyByCountry(widget.selectedCountry!)})',
                                prefixIcon:
                                    const Icon(FontAwesomeIcons.wallet))),
                        const SizedBox(height: 3),
                        SizedBox(
                            width: double.infinity,
                            height: 80,
                            child: Row(children: <Widget>[
                              Expanded(
                                flex: 4,
                                child: TextFormField(
                                    enableInteractiveSelection: true,
                                    textInputAction: TextInputAction.done,
                                    keyboardType: TextInputType.text,
                                    initialValue: _clinic?.address ?? '',
                                    validator: (val) {
                                      String text = val.toString().trim();
                                      if (text.length > 300) {
                                        return 'أقصى عدد للأحرف هو ٣٠٠';
                                      }
                                      if (text.length < 2) {
                                        return 'أقل عدد للأحرف هو ٢';
                                      }
                                      return null;
                                    },
                                    onSaved: (val) {
                                      _clinic?.address = Utils()
                                          .capitalize(val.toString().trim());
                                    },
                                    maxLength: 300,
                                    decoration: const InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        labelText: "العنوان",
                                        prefixIcon: Icon(
                                            FontAwesomeIcons.locationDot))),
                              ),
                              Expanded(
                                  flex: 1,
                                  child: Container(
                                    margin: const EdgeInsets.all(3),
                                    width: 50,
                                    height: double.infinity,
                                    decoration: const BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15.0)),
                                        color: Colors.black45),
                                    child: IconButton(
                                      iconSize: 30,
                                      icon: const Icon(
                                        FontAwesomeIcons.mapLocationDot,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                CustomGoogleMapsPickPlace(
                                              apiKey:
                                                  'AIzaSyD4QDlHKL7yilPEuuw646yIDLBFhUrCeGA',
                                              enableSearchButton: false,
                                              initialPosition: _clinic
                                                          ?.geoLocation !=
                                                      null
                                                  ? _clinic!.latLngLocation
                                                  : AccountConstants
                                                      .defaultInitialMapLocation,
                                              markerColor: MarkerColor.azure,
                                              doneButton:
                                                  mapConfirmationSelectionButtonWidget(),
                                              getResult: (FullAddress result) {
                                                Position? pickedPosition =
                                                    result.position;
                                                if (pickedPosition != null) {
                                                  clinicMapLocation = GeoPoint(
                                                      pickedPosition.latitude,
                                                      pickedPosition.longitude);
                                                }
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ))
                            ])),
                        const SizedBox(height: 2),
                        Row(
                          children: <Widget>[
                            Checkbox(
                              activeColor: primaryColor,
                              value: _trainingIsAvailable,
                              onChanged: (bool? value) {
                                if (value != null) {
                                  setState(() {
                                    _trainingIsAvailable = value;
                                  });
                                }
                              },
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'متاح تدريب لدى العيادة',
                              style: TextStyle(
                                  fontSize: 17.0, color: primaryColor),
                            ), //Text
                          ], //<Widget>[]
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: <Widget>[
                            Checkbox(
                              activeColor: primaryColor,
                              value: _workIsAvailable,
                              onChanged: (bool? value) {
                                if (value != null) {
                                  setState(() {
                                    _workIsAvailable = value;
                                  });
                                }
                              },
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'متاح عمل لدى العيادة',
                              style: TextStyle(
                                  fontSize: 17.0, color: primaryColor),
                            ), //Text
                          ], //<Widget>[]
                        ),
                        ListTile(
                          leading: const SizedBox(
                              height: double.infinity,
                              child: Icon(FontAwesomeIcons.stethoscope)),
                          title: const Text(
                            'التخصص',
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                          subtitle: Text(_clinicSpeciality?.arabicTitle ?? '',
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.black)),
                        ),
                        const SizedBox(height: 6),
                        Container(
                            margin: const EdgeInsets.only(left: 10, right: 10),
                            alignment: Alignment.centerRight,
                            child: Row(
                              children: [
                                const Text('طرق الكشف المتاحة',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.black)),
                                SizedBox(width: size.width * 0.03),
                                _clinic!.paymentWay ==
                                        clinicPaymentWays.length - 1
                                    ? _buildStaticRevealWayTextWidget()
                                    : _buildRevealWaysDropDownButtonWidget(),
                              ],
                            )),
                        const SizedBox(height: 6),
                        Container(
                          margin: const EdgeInsets.only(left: 10, right: 10),
                          alignment: Alignment.centerRight,
                          child: const Text('صور العيادة',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              )),
                        ),
                        const SizedBox(height: 2),
                        SizedBox(
                            width: double.infinity,
                            height: 80,
                            child: Row(children: <Widget>[
                              Expanded(
                                flex: 3,
                                child: ReorderableListView(
                                    scrollDirection: Axis.horizontal,
                                    children: currentImageList
                                        .map((item) => Container(
                                              key: Key("$item"),
                                              margin: const EdgeInsets.only(
                                                  left: 1, right: 1),
                                              width: 80,
                                              height: double.infinity,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.rectangle,
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(15.0)),
                                                image: DecorationImage(
                                                  image: getImageByItem(item),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              child: IconButton(
                                                icon: const Icon(
                                                  Icons.delete,
                                                  size: 30,
                                                  color: Colors.black,
                                                ),
                                                iconSize: 5,
                                                onPressed: () {
                                                  if (currentImageList.length <
                                                      2) {
                                                    Fluttertoast.showToast(
                                                        msg:
                                                            "يجب أن يكون للعيادة صورة واحدة على الأقل!");
                                                    return;
                                                  }
                                                  showDialog<String>(
                                                    context: context,
                                                    barrierDismissible: false,
                                                    builder: (BuildContext
                                                            context) =>
                                                        AlertDialog(
                                                      title: const Text(
                                                        'حذف صورة',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black),
                                                        textDirection: ui
                                                            .TextDirection.rtl,
                                                      ),
                                                      content: const Text(
                                                          'هل متأكد أنك تريد حذف هذه الصورة؟',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black),
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
                                                              'إلغاء'),
                                                        ),
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context, 'Ok');
                                                            setState(() {
                                                              currentImageList
                                                                  .remove(item);
                                                            });
                                                          },
                                                          child:
                                                              const Text('نعم'),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            ))
                                        .toList(),
                                    onReorder: (int start, int current) {
                                      if (start < current) {
                                        int end = current - 1;
                                        String startItem =
                                            currentImageList[start];
                                        int i = 0;
                                        int local = start;
                                        do {
                                          currentImageList[local] =
                                              currentImageList[++local];
                                          i++;
                                        } while (i < end - start);
                                        currentImageList[end] = startItem;
                                      } else if (start > current) {
                                        String startItem =
                                            currentImageList[start];
                                        for (int i = start; i > current; i--) {
                                          currentImageList[i] =
                                              currentImageList[i - 1];
                                        }
                                        currentImageList[current] = startItem;
                                      }
                                      setState(() {});
                                    }),
                              ),
                              Expanded(
                                  flex: 1,
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        left: 1, right: 1),
                                    width: 80,
                                    height: double.infinity,
                                    decoration: const BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15.0)),
                                        color: Colors.black45),
                                    child: IconButton(
                                      iconSize: 40,
                                      icon: const Icon(
                                        Icons.add,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        if (currentImageList.length > 3) {
                                          Fluttertoast.showToast(
                                              msg: "أقصى عدد للصور هو ٤");
                                          return;
                                        }
                                        _showSelectImageBottomSheet(
                                            context,
                                            dialog,
                                            'صورة العيادة',
                                            false,
                                            currentImageList);
                                      },
                                    ),
                                  ))
                            ])),
                        const SizedBox(height: 3),
                        Container(
                          margin: const EdgeInsets.only(left: 10, right: 10),
                          alignment: Alignment.centerRight,
                          child: const Text('مستندات العيادة',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              )),
                        ),
                        const SizedBox(height: 2),
                        SizedBox(
                            width: double.infinity,
                            height: 80,
                            child: Row(children: <Widget>[
                              Expanded(
                                flex: 3,
                                child: ReorderableListView(
                                    scrollDirection: Axis.horizontal,
                                    children: currentDocumentList
                                        .map((item) => Container(
                                              key: Key("$item"),
                                              margin: const EdgeInsets.only(
                                                  left: 1, right: 1),
                                              width: 80,
                                              height: double.infinity,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.rectangle,
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(15.0)),
                                                image: DecorationImage(
                                                  image: getImageByItem(item),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              child: IconButton(
                                                icon: const Icon(
                                                  Icons.delete,
                                                  size: 30,
                                                  color: Colors.black,
                                                ),
                                                iconSize: 5,
                                                onPressed: () {
                                                  if (currentDocumentList
                                                          .length <
                                                      2) {
                                                    Fluttertoast.showToast(
                                                        msg:
                                                            "يجب أن يكون للعيادة مستند واحد على الأقل!");
                                                    return;
                                                  }
                                                  showDialog<String>(
                                                    context: context,
                                                    barrierDismissible: false,
                                                    builder: (BuildContext
                                                            context) =>
                                                        AlertDialog(
                                                      title: const Text(
                                                        'حذف مستند',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black),
                                                        textDirection: ui
                                                            .TextDirection.rtl,
                                                      ),
                                                      content: const Text(
                                                          'هل متأكد أنك تريد حذف هذا المستند؟',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black),
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
                                                              'إلغاء'),
                                                        ),
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context, 'Ok');
                                                            setState(() {
                                                              currentDocumentList
                                                                  .remove(item);
                                                            });
                                                          },
                                                          child:
                                                              const Text('نعم'),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            ))
                                        .toList(),
                                    onReorder: (int start, int current) {
                                      if (start < current) {
                                        int end = current - 1;
                                        String startItem =
                                            currentDocumentList[start];
                                        int i = 0;
                                        int local = start;
                                        do {
                                          currentDocumentList[local] =
                                              currentDocumentList[++local];
                                          i++;
                                        } while (i < end - start);
                                        currentDocumentList[end] = startItem;
                                      } else if (start > current) {
                                        String startItem =
                                            currentDocumentList[start];
                                        for (int i = start; i > current; i--) {
                                          currentDocumentList[i] =
                                              currentDocumentList[i - 1];
                                        }
                                        currentDocumentList[current] =
                                            startItem;
                                      }
                                      setState(() {});
                                    }),
                              ),
                              Expanded(
                                  flex: 1,
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        left: 1, right: 1),
                                    width: 80,
                                    height: double.infinity,
                                    decoration: const BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15.0)),
                                        color: Colors.black45),
                                    child: IconButton(
                                      iconSize: 40,
                                      icon: const Icon(
                                        Icons.add,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        if (currentDocumentList.length > 3) {
                                          Fluttertoast.showToast(
                                              msg: "أقصى عدد للمستندات هو ٤");
                                          return;
                                        }
                                        _showSelectImageBottomSheet(
                                            context,
                                            dialog,
                                            'مستند العيادة',
                                            false,
                                            currentDocumentList);
                                      },
                                    ),
                                  ))
                            ])),
                      ]))
                ],
              )),
        ));
  }

  getImageByItem(String image) => Utils().isNetworkUrl(image)
      ? NetworkImage(image)
      : FileImage(File(image));

  String getToolbarTitle() =>
      widget.isNewItem ? 'إضافة عيادة جديدة' : 'تعديل بيانات العيادة';

  _showSelectImageBottomSheet(context, LoadingIndicator dialog,
      String imageTypeTitle, bool isLogo, List<dynamic>? currentList) {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return Directionality(
              textDirection: ui.TextDirection.rtl,
              child: Container(
                padding: const EdgeInsets.all(20),
                height: 210,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "إختيار $imageTypeTitle",
                      style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: primaryColor),
                    ),
                    InkWell(
                      onTap: () async {
                        var picked = await ImagePicker()
                            .getImage(source: ImageSource.gallery);
                        if (picked != null) {
                          setState(() {
                            if (isLogo) {
                              currentLogo = picked.path;
                            } else {
                              currentList!.add(picked.path);
                            }
                          });
                          Navigator.of(context).pop();
                        }
                      },
                      child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              Icon(
                                Icons.photo_outlined,
                                size: 30,
                                color: primaryColor,
                              ),
                              const SizedBox(width: 20),
                              Text(
                                "من المعرض",
                                style: TextStyle(
                                    fontSize: 20, color: primaryColor),
                              )
                            ],
                          )),
                    ),
                    InkWell(
                      onTap: () async {
                        var picked = await ImagePicker()
                            .getImage(source: ImageSource.camera);
                        if (picked != null) {
                          setState(() {
                            if (isLogo) {
                              currentLogo = picked.path;
                            } else {
                              currentList!.add(picked.path);
                            }
                          });
                          Navigator.of(context).pop();
                        }
                      },
                      child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              Icon(
                                Icons.camera,
                                size: 30,
                                color: primaryColor,
                              ),
                              const SizedBox(width: 20),
                              Text(
                                "من الكاميرا",
                                style: TextStyle(
                                    fontSize: 20, color: primaryColor),
                              )
                            ],
                          )),
                    ),
                  ],
                ),
              ));
        });
  }

  saveClinicData(context, isNew, LoadingIndicator dialog) async {
    var formData = formstate.currentState;
    if (formData!.validate()) {
      if (clinicMapLocation == null) {
        Fluttertoast.showToast(msg: "برجاء إختيار موقع العيادة على الخريطة!");
        return;
      } else {
        _clinic!.geoLocation = clinicMapLocation;
      }
      if (currentLogo == null || currentLogo!.isEmpty) {
        Fluttertoast.showToast(msg: "إختار لوجو العيادة!");
        return;
      }
      if (currentImageList.isEmpty) {
        Fluttertoast.showToast(msg: "أضف على الأقل صورة واحدة للعيادة!");
        return;
      }
      if (currentDocumentList.isEmpty) {
        Fluttertoast.showToast(msg: "أضف على الأقل مستند واحد للعيادة!");
        return;
      }
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            dialogContext = context;
            return dialog;
          });
      formData.save();
      _clinic?.trainingIsAvailable = _trainingIsAvailable;
      _clinic?.workIsAvailable = _workIsAvailable;
      await getReadyLogo(
              clinicLogoFirebaseStorageReference, initialLogo, currentLogo!)
          .then((logoUrl) => _clinic!.logo = logoUrl);
      await getReadyImageList(clinicImagesFirebaseStorageReference,
              initialImageList, currentImageList)
          .then((imageList) => _clinic!.images = imageList);
      await getReadyImageList(clinicDocumentsFirebaseStorageReference,
              initialDocumentList, currentDocumentList)
          .then((imageList) => _clinic!.documents = imageList);
      DocumentReference clinicDocumentRef = isNew
          ? _firebaseFirestore.collection(clinicsCollectionPath).doc()
          : _firebaseFirestore.doc(widget.clinicDocumentPath!);
      await clinicDocumentRef.set(_clinic?.toJson()).then((value) async {
        if (widget.isNewItem) {
          ClinicAvailableDay defaultClinicAvailableDay =
              ClinicAvailableDay('defaultDay');
          await clinicDocumentRef
              .collection(FirestoreCollections.ClinicAvailableDays.name)
              .doc('defaultDay')
              .set(defaultClinicAvailableDay.toJson())
              .then((value) => {
                    Fluttertoast.showToast(msg: "تم الحفظ بنجاح!"),
                    Navigator.pop(dialogContext!),
                    Navigator.pop(context),
                  })
              .catchError((error) {
            Fluttertoast.showToast(msg: "حدث خطأ ما!");
          });
        } else {
          Fluttertoast.showToast(msg: "تم الحفظ بنجاح!");
          Navigator.pop(dialogContext!);
          Navigator.pop(context);
        }
      }).catchError((error) {
        Fluttertoast.showToast(msg: "حدث خطأ ما!");
      });
    }
  }

  Future<String> getReadyLogo(Reference firebaseStorageReference,
      String initialLogo, String currentLogo) async {
    String readyLogo = '';
    if (currentLogo == initialLogo) {
      readyLogo = initialLogo;
    } else {
      if (Utils().isNetworkUrl(initialLogo)) {
        await _firebaseStorage.refFromURL(initialLogo).delete();
      }
      File file = File(currentLogo);
      String randomDigits = Random().nextInt(10000000).toString();
      var imageName = randomDigits + basename(currentLogo);
      Reference ref = firebaseStorageReference.child(imageName);
      await ref.putFile(file);
      await ref.getDownloadURL().then((uploadedImageUrl) => setState(() {
            readyLogo = uploadedImageUrl;
          }));
    }
    return readyLogo;
  }

  Future<List> getReadyImageList(Reference firebaseStorageReference,
      List<dynamic> initialList, List<dynamic> currentList) async {
    for (var imageUrl in initialList) {
      if (!currentList.contains(imageUrl)) {
        await _firebaseStorage.refFromURL(imageUrl).delete();
      }
    }
    List<dynamic> readyList = [];
    for (var imagePath in currentList) {
      if (Utils().isNetworkUrl(imagePath)) {
        readyList.add(imagePath);
      } else {
        File file = File(imagePath);
        String randomDigits = Random().nextInt(10000000).toString();
        var imageName = randomDigits + basename(imagePath);
        Reference ref = firebaseStorageReference.child(imageName);
        await ref.putFile(file);
        await ref.getDownloadURL().then((uploadedImageUrl) => setState(() {
              readyList.add(uploadedImageUrl);
            }));
      }
    }
    return readyList;
  }

  _buildStaticRevealWayTextWidget() =>
      Text(clinicRevealWays[_clinic!.revealWay],
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: Colors.black));

  _buildRevealWaysDropDownButtonWidget() {
    return Container(
      alignment: Alignment.center,
      child: DropdownButton<String>(
        value: clinicRevealWays[_clinic!.revealWay],
        icon: const Icon(FontAwesomeIcons.caretDown),
        elevation: 16,
        style: const TextStyle(color: Colors.grey),
        underline: Container(
          height: 2,
          color: Colors.grey,
        ),
        onChanged: (String? newValue) {
          setState(() {
            // print(clinicRevealWays.indexOf(newValue!));
            _clinic!.revealWay = clinicRevealWays.indexOf(newValue!);
          });
        },
        items: clinicRevealWays.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            alignment: Alignment.center,
            child: Text(value,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: Colors.black)),
          );
        }).toList(),
      ),
    );
  }
}

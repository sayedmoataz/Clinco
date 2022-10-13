import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:clinico/constants/utils.dart';
import 'package:clinico/view/screens/doctor_part/doctor_speciality_selection_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_pick_place/config/units.dart';
import 'package:google_maps_pick_place/models/address_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:path/path.dart';

import '../../../constants/account_constants.dart';
import '../../../constants/app_colors.dart';
import '../../../model/physician_impersonator.dart';
import '../../../model/selected_speciality.dart';
import '../../../model/speciality.dart';
import '../../../model/user_data.dart';
import '../../components/alert.dart';
import '../../components/custom_circular_widget.dart';
import '../../components/map_confirmation_selection_button_widget.dart';
import '../custom_google_maps_pick_place.dart';

class PhysicianImpersonatorDataScreen extends StatefulWidget {
  String? adminUserId;
  bool isNewItem = true;
  String? physicianImpersonatorDocumentPath;
  PhysicianImpersonator? physicianImpersonator;

  PhysicianImpersonatorDataScreen(
      {Key? key,
      required this.adminUserId,
      required this.isNewItem,
      required this.physicianImpersonatorDocumentPath,
      required this.physicianImpersonator})
      : super(key: key);

  @override
  _PhysicianImpersonatorDataScreenState createState() =>
      _PhysicianImpersonatorDataScreenState();
}

class _PhysicianImpersonatorDataScreenState
    extends State<PhysicianImpersonatorDataScreen> {
  BuildContext? dialogContext;
  Color primaryColor = AppColors.primaryColor;
  List<Color> primaryGradientColors = AppColors.primaryGradientColors;
  PhysicianImpersonator? _physicianImpersonator;
  SelectedSpeciality? _selectedSpeciality;
  String physicianImpersonatorsCollectionPath =
      FirestoreCollections.PhysicianImpersonators.name;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  late Reference physicianImpersonatorsLogoFirebaseStorageReference;
  late final String initialLogo;
  String? currentLogo;
  String _selectedCountry = Countries.Egypt.name;
  GeoPoint? physicianImpersonatorMapLocation;

  @override
  void initState() {
    if (!widget.isNewItem) {
      _physicianImpersonator = widget.physicianImpersonator;
      if (_physicianImpersonator?.geoLocation != null) {
        physicianImpersonatorMapLocation = _physicianImpersonator!.geoLocation;
      }
      if (_physicianImpersonator?.selectedCountry != null &&
          _physicianImpersonator!.selectedCountry!.isNotEmpty) {
        setState(() {
          _selectedCountry = _physicianImpersonator!.selectedCountry!;
        });
      }
      if (_physicianImpersonator?.logo != null &&
          _physicianImpersonator!.logo!.isNotEmpty) {
        initialLogo = _physicianImpersonator!.logo!;
        currentLogo = initialLogo;
      }
      if (_physicianImpersonator?.specialityId != null &&
          _physicianImpersonator!.specialityId!.isNotEmpty) {
        _getSelectedSpecialityBySpecialityId(
            _physicianImpersonator!.specialityId!);
      }
    } else {
      initialLogo = '';
      _physicianImpersonator = PhysicianImpersonator(
          widget.adminUserId, null, null, null, null, null, null, null, null);
    }
    physicianImpersonatorsLogoFirebaseStorageReference =
        _firebaseStorage.ref('PhysicianImpersonators/logos');
    super.initState();
  }

  _getSelectedSpecialityBySpecialityId(String specialityId) async {
    await _firebaseFirestore
        .collection(FirestoreCollections.Specialties.name)
        .doc(specialityId)
        .get()
        .then((value) {
      if (value.exists) {
        setState(() {
          Speciality speciality = Speciality.fromJson(value.data());
          _selectedSpeciality = SelectedSpeciality(specialityId, speciality);
        });
      }
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
                  await savePhysicianImpersonatorData(
                      context, widget.isNewItem, dialog);
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
                              _showSelectLogoImageBottomSheet(
                                  context, dialog, 'لوجو العيادة');
                            },
                          ),
                        ),
                        TextFormField(
                            enableInteractiveSelection: true,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.text,
                            initialValue: _physicianImpersonator?.name ?? '',
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
                              _physicianImpersonator?.name =
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
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.text,
                            initialValue:
                                _physicianImpersonator?.doctorName ?? '',
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
                              _physicianImpersonator?.doctorName =
                                  Utils().capitalize(val.toString().trim());
                            },
                            maxLength: 100,
                            decoration: const InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: "إسم الطبيب",
                                prefixIcon: Icon(FontAwesomeIcons.userDoctor))),
                        TextFormField(
                            enableInteractiveSelection: true,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.phone,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            initialValue:
                                _physicianImpersonator?.phoneNumber ?? '',
                            validator: (val) => null,
                            onSaved: (val) {
                              String enteredPhoneNumber = val.toString().trim();
                              if (enteredPhoneNumber.isNotEmpty) {
                                _physicianImpersonator?.phoneNumber =
                                    enteredPhoneNumber;
                              }
                            },
                            maxLength: AccountConstants
                                .getPhoneNumberDigitCountByCountryName(
                                    _selectedCountry),
                            decoration: const InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: 'رقم الهاتف (010xxxxxxxx)',
                                prefixIcon: Icon(FontAwesomeIcons.phoneFlip))),
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
                                    initialValue:
                                        _physicianImpersonator?.address ?? '',
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
                                      _physicianImpersonator?.address = Utils()
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
                                              initialPosition:
                                                  _physicianImpersonator
                                                              ?.geoLocation !=
                                                          null
                                                      ? _physicianImpersonator!
                                                          .latLngLocation
                                                      : AccountConstants
                                                          .defaultInitialMapLocation,
                                              markerColor: MarkerColor.azure,
                                              doneButton:
                                                  mapConfirmationSelectionButtonWidget(),
                                              getResult: (FullAddress result) {
                                                Position? pickedPosition =
                                                    result.position;
                                                if (pickedPosition != null) {
                                                  physicianImpersonatorMapLocation =
                                                      GeoPoint(
                                                          pickedPosition
                                                              .latitude,
                                                          pickedPosition
                                                              .longitude);
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
                        Container(
                            alignment: Alignment.centerLeft,
                            margin: const EdgeInsets.symmetric(horizontal: 40),
                            child: Row(
                              children: [
                                const Text('الدولة',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.black)),
                                SizedBox(width: size.width * 0.015),
                                Container(
                                  alignment: Alignment.centerLeft,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 40),
                                  child: DropdownButton<String>(
                                    value: _selectedCountry,
                                    icon:
                                        const Icon(FontAwesomeIcons.caretDown),
                                    elevation: 16,
                                    style: const TextStyle(color: Colors.grey),
                                    underline: Container(
                                      height: 2,
                                      color: Colors.grey,
                                    ),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        _selectedCountry = newValue!;
                                      });
                                    },
                                    items: getCountries()
                                        .map<DropdownMenuItem<String>>(
                                            (Countries value) {
                                      return DropdownMenuItem<String>(
                                        value: value.name,
                                        child: Text(value.name,
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.normal,
                                                color: Colors.black)),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            )),
                        const SizedBox(height: 2),
                        Container(
                          color: primaryColor,
                          alignment: Alignment.center,
                          height: 40,
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 10),
                          child: GestureDetector(
                            onTap: () =>
                                _startSpecialitySelectionScreen(context),
                            child: Text(
                              _selectedSpeciality?.speciality.arabicTitle ??
                                  'إختيار التخصص',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        )
                      ]))
                ],
              )),
        ));
  }

  getImageByItem(String image) => Utils().isNetworkUrl(image)
      ? NetworkImage(image)
      : FileImage(File(image));

  String getToolbarTitle() =>
      widget.isNewItem ? 'إضافة منتحل جديد' : 'تعديل بيانات المنتحل';

  _showSelectLogoImageBottomSheet(
      context, LoadingIndicator dialog, String imageTypeTitle) {
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
                            currentLogo = picked.path;
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
                            currentLogo = picked.path;
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

  savePhysicianImpersonatorData(context, isNew, LoadingIndicator dialog) async {
    var formData = formstate.currentState;
    if (formData!.validate()) {
      if (physicianImpersonatorMapLocation == null) {
        Fluttertoast.showToast(msg: "برجاء إختيار موقع العيادة على الخريطة!");
        return;
      } else {
        _physicianImpersonator!.geoLocation = physicianImpersonatorMapLocation;
      }
      if (currentLogo == null || currentLogo!.isEmpty) {
        Fluttertoast.showToast(msg: "إختار لوجو العيادة!");
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
      if (_selectedSpeciality?.id == null) {
        Fluttertoast.showToast(msg: "التخصص مطلوب!");
        Navigator.pop(context!);
        return;
      }
      _physicianImpersonator?.specialityId = _selectedSpeciality!.id;
      _physicianImpersonator?.selectedCountry = _selectedCountry;
      await getReadyLogo(physicianImpersonatorsLogoFirebaseStorageReference,
              initialLogo, currentLogo!)
          .then((logoUrl) => _physicianImpersonator!.logo = logoUrl);
      DocumentReference physicianImpersonatorDocumentRef = isNew
          ? _firebaseFirestore
              .collection(physicianImpersonatorsCollectionPath)
              .doc()
          : _firebaseFirestore.doc(widget.physicianImpersonatorDocumentPath!);
      await physicianImpersonatorDocumentRef
          .set(_physicianImpersonator?.toJson())
          .then((value) {
        Fluttertoast.showToast(msg: "تم الحفظ بنجاح!");
        Navigator.pop(dialogContext!);
        Navigator.pop(context);
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

  _startSpecialitySelectionScreen(BuildContext context) async =>
      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  const DoctorSpecialitySelectionScreen())).then((value) => {
            if (value != null)
              {
                setState(() {
                  _selectedSpeciality = value as SelectedSpeciality;
                })
              }
          });

  List<Countries> getCountries() => Countries.values.cast().toList().cast();
}

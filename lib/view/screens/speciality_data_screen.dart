import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:clinico/constants/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:path/path.dart';

import '../../../helper/shared_preferences.dart';
import '../../constants/app_colors.dart';
import '../../model/speciality.dart';
import '../../model/user_data.dart';
import '../components/alert.dart';

class SpecialityDataScreen extends StatefulWidget {
  bool isNewItem = true;
  String? specialityDocumentPath;
  Speciality? speciality;

  SpecialityDataScreen(
      {Key? key,
      required this.isNewItem,
      required this.specialityDocumentPath,
      required this.speciality})
      : super(key: key);

  @override
  _SpecialityDataScreenState createState() => _SpecialityDataScreenState();
}

class _SpecialityDataScreenState extends State<SpecialityDataScreen> {
  BuildContext? dialogContext;
  Color primaryColor = AppColors.primaryColor;
  List<Color> primaryGradientColors = AppColors.primaryGradientColors;
  late final AppData _appData;
  String? _userId, _selectedCountry;
  Speciality? _speciality;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  late Reference specialityImagesFirebaseStorageReference;
  late String? _initialImage;

  @override
  void initState() {
    super.initState();
    _appData = AppData();
    _appData.getSharedPreferencesInstance().then((pref) {
      setState(() {
        _userId = _appData.getUserId(pref!)!;
        _selectedCountry = _appData.getSelectedCountry(pref)!;
      });

      if (!widget.isNewItem) {
        _firebaseFirestore
            .doc(widget.specialityDocumentPath!)
            .get()
            .then((value) {
          setState(() {
            _speciality = Speciality.fromJson(value.data());
            _initialImage = _speciality?.image;
            specialityImagesFirebaseStorageReference = FirebaseStorage.instance
                .ref('${_speciality?.createdBy}/specialityImages');
          });
        });
      } else {
        _speciality = Speciality(_userId, null, null, null, _selectedCountry);
        _initialImage = _speciality?.image;
        specialityImagesFirebaseStorageReference = FirebaseStorage.instance
            .ref('${_speciality?.createdBy}/specialityImages');
      }
    });
  }

  GlobalKey<FormState> formstate = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    LoadingIndicator dialog = loadingIndicatorWidget();
    return Directionality(
        textDirection: ui.TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: Text(getToolbarTitle(),
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
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
                  await saveSpecialityData(context, widget.isNewItem, dialog);
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
                        Text(
                          'سوف يكون متاح في ${_speciality?.selectedCountry ?? ''}',
                          style: TextStyle(color: primaryColor),
                        ),
                        const SizedBox(height: 5),
                        TextFormField(
                            key: Key(_speciality?.arabicTitle ?? '' + 'A'),
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.text,
                            initialValue: _speciality?.arabicTitle ?? '',
                            validator: (val) {
                              String text = val.toString().trim();
                              if (text.length > 30) {
                                return 'أقصى عدد للأحرف هو ٣٠';
                              }
                              if (text.length < 2) {
                                return 'أقل عدد للأحرف هو ٢';
                              }
                              return null;
                            },
                            onSaved: (val) {
                              _speciality?.arabicTitle =
                                  Utils().capitalize(val.toString().trim());
                            },
                            maxLength: 30,
                            maxLines: 1,
                            decoration: const InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: 'الإسم بالعربي',
                                prefixIcon: Icon(Icons.title))),
                        const SizedBox(height: 2),
                        TextFormField(
                            key: Key(_speciality?.englishTitle ?? ' ' + 'B'),
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.text,
                            initialValue: _speciality?.englishTitle ?? '',
                            validator: (val) {
                              String text = val.toString().trim();
                              if (text.length > 30) {
                                return 'أقصى عدد للأحرف هو ٣٠';
                              }
                              if (text.length < 2) {
                                return 'أقل عدد للأحرف هو ٢';
                              }
                              return null;
                            },
                            onSaved: (val) {
                              _speciality?.englishTitle =
                                  Utils().capitalize(val.toString().trim());
                            },
                            maxLength: 30,
                            maxLines: 1,
                            decoration: const InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: 'الإسم بالإنجليزي',
                                prefixIcon: Icon(Icons.title))),
                        const SizedBox(height: 5),
                        Container(
                          margin: const EdgeInsets.only(left: 10, right: 10),
                          alignment: Alignment.centerRight,
                          child: const Text('صورة التخصص',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              )),
                        ),
                        const SizedBox(height: 5),
                        SizedBox(
                            width: 100,
                            height: 100,
                            child: Container(
                              margin: const EdgeInsets.only(left: 1, right: 1),
                              width: double.infinity,
                              height: double.infinity,
                              decoration: _speciality?.image != null
                                  ? BoxDecoration(
                                      shape: BoxShape.rectangle,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(15.0)),
                                      image: DecorationImage(
                                        image:
                                            getImageByItem(_speciality!.image!),
                                        fit: BoxFit.cover,
                                      ))
                                  : const BoxDecoration(
                                      shape: BoxShape.rectangle,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(15.0)),
                                      color: Colors.grey),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.add_a_photo_rounded,
                                  size: 30,
                                  color: Colors.black,
                                ),
                                iconSize: 5,
                                onPressed: () {
                                  _showBottomSheet(context, dialog);
                                },
                              ),
                            )),
                      ]))
                ],
              )),
        ));
  }

  getImageByItem(String image) => Utils().isNetworkUrl(image)
      ? NetworkImage(image)
      : FileImage(File(image));

  String getToolbarTitle() =>
      widget.isNewItem ? 'إضافة تخصص جديد' : 'تعديل بيانات التخصص';

  _showBottomSheet(context, LoadingIndicator dialog) {
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
                      'إختيار صورة التخصص',
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
                            _speciality?.image = picked.path;
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
                                'من المعرض',
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
                            _speciality?.image = picked.path;
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
                                'من الكاميرا',
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

  saveSpecialityData(context, isNew, LoadingIndicator dialog) async {
    var formData = formstate.currentState;
    if (formData!.validate()) {
      if (_speciality?.image == null) {
        Fluttertoast.showToast(msg: 'برجاء إختيار صورة التخصص!');
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
      if (_speciality?.image != _initialImage &&
          !Utils().isNetworkUrl(_speciality!.image!)) {
        await getNewImageUrl().then((image) => _speciality!.image = image);
      }
      DocumentReference specialityDocumentRef = isNew
          ? _firebaseFirestore
              .collection(FirestoreCollections.Specialties.name)
              .doc()
          : _firebaseFirestore.doc(widget.specialityDocumentPath!);
      await specialityDocumentRef.set(_speciality?.toJson()).then((value) {
        Fluttertoast.showToast(msg: 'تم الحفظ بنجاح!');
        Navigator.pop(dialogContext!);
        Navigator.pop(context);
      }).catchError((error) {
        Fluttertoast.showToast(msg: 'حدث خطأ ما!');
      });
    }
  }

  Future<String?> getNewImageUrl() async {
    if (_initialImage != null) {
      await _firebaseStorage.refFromURL(_initialImage!).delete();
    }
    String? newImageUrl;
    File file = File(_speciality!.image!);
    String randomDigits = Random().nextInt(10000000).toString();
    var imageName = randomDigits + basename(_speciality!.image!);
    Reference ref = specialityImagesFirebaseStorageReference.child(imageName);
    await ref.putFile(file);
    await ref.getDownloadURL().then((uploadedImageUrl) => setState(() {
          newImageUrl = uploadedImageUrl;
        }));
    return newImageUrl;
  }
}

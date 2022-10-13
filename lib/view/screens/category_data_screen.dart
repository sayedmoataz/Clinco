import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:clinico/constants/utils.dart';
import 'package:clinico/model/devices_category.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:path/path.dart';

import '../../../helper/shared_preferences.dart';
import '../../constants/app_colors.dart';
import '../../model/user_data.dart';
import '../components/alert.dart';

class CategoryDataScreen extends StatefulWidget {
  String? categoryDocumentPath;
  bool isNewCategory = false, isNewItem = true;
  DevicesCategory? category;

  CategoryDataScreen(
      {Key? key,
      required this.isNewCategory,
      required this.isNewItem,
      required this.categoryDocumentPath,
      required this.category})
      : super(key: key);

  @override
  _CategoryDataScreenState createState() => _CategoryDataScreenState();
}

class _CategoryDataScreenState extends State<CategoryDataScreen> {
  BuildContext? dialogContext;
  Color primaryColor = AppColors.primaryColor;
  List<Color> primaryGradientColors = AppColors.primaryGradientColors;
  late final AppData _appData;
  String? _userId, _selectedCountry;
  DevicesCategory? _category;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  late Reference categoryImagesFirebaseStorageReference;
  late String? _initialImage;
  bool _isAvailableForPatient = false;

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
            .doc(widget.categoryDocumentPath!)
            .get()
            .then((value) {
          setState(() {
            _category = DevicesCategory.fromJson(value.data());
            _initialImage = _category?.image;
            _isAvailableForPatient = _category!.isAvailableForPatient;
            categoryImagesFirebaseStorageReference = FirebaseStorage.instance
                .ref('${_category?.createdBy}/categoryImages');
          });
        });
      } else {
        _category = DevicesCategory(_userId, null, null, null, _selectedCountry,
            widget.isNewCategory, false);
        _initialImage = _category?.image;
        categoryImagesFirebaseStorageReference = FirebaseStorage.instance
            .ref('${_category?.createdBy}/categoryImages');
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
                  await saveCategoryData(context, widget.isNewItem, dialog);
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
                          'سوف يكون متاح في ${_category?.selectedCountry ?? ''}, قسم ${_category?.isNew == true ? 'الجديد' : 'المستعمل'}',
                          style: TextStyle(color: primaryColor),
                        ),
                        const SizedBox(height: 5),
                        TextFormField(
                            key: Key(_category?.arabicTitle ?? '' + 'A'),
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.text,
                            initialValue: _category?.arabicTitle ?? '',
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
                              _category?.arabicTitle =
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
                            key: Key(_category?.englishTitle ?? ' ' + 'B'),
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.text,
                            initialValue: _category?.englishTitle ?? '',
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
                              _category?.englishTitle =
                                  Utils().capitalize(val.toString().trim());
                            },
                            maxLength: 30,
                            maxLines: 1,
                            decoration: const InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: 'الإسم بالإنجليزي',
                                prefixIcon: Icon(Icons.title))),
                        const SizedBox(height: 2),
                        Row(
                          children: <Widget>[
                            Checkbox(
                              activeColor: primaryColor,
                              value: _isAvailableForPatient,
                              onChanged: (bool? value) {
                                if (value != null) {
                                  setState(() {
                                    _isAvailableForPatient = value;
                                  });
                                }
                              },
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'القسم يظهر للمرضى',
                              style: TextStyle(
                                  fontSize: 17.0, color: primaryColor),
                            ), //Text
                          ], //<Widget>[]
                        ),
                        const SizedBox(height: 5),
                        Container(
                          margin: const EdgeInsets.only(left: 10, right: 10),
                          alignment: Alignment.centerRight,
                          child: const Text('صورة القسم',
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
                              decoration: _category?.image != null
                                  ? BoxDecoration(
                                      shape: BoxShape.rectangle,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(15.0)),
                                      image: DecorationImage(
                                        image:
                                            getImageByItem(_category!.image!),
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
      widget.isNewItem ? 'إضافة قسم جديد' : 'تعديل بيانات القسم';

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
                      'إختيار صورة القسم',
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
                            _category?.image = picked.path;
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
                            _category?.image = picked.path;
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

  saveCategoryData(context, isNew, LoadingIndicator dialog) async {
    var formData = formstate.currentState;
    if (formData!.validate()) {
      if (_category?.image == null) {
        Fluttertoast.showToast(msg: 'برجاء إختيار صورة القسم!');
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
      if (_category?.englishTitle == _category?.arabicTitle) {
        Fluttertoast.showToast(
            msg: 'يجب أن يكون إسم القسم بالعربي مختلف عنهُ بالإنجليزي!');
        Navigator.pop(context);
        return;
      }
      _category?.isAvailableForPatient = _isAvailableForPatient;
      if (_category?.image != _initialImage &&
          !Utils().isNetworkUrl(_category!.image!)) {
        await getNewImageUrl().then((image) => _category!.image = image);
      }
      DocumentReference categoryDocumentRef = isNew
          ? _firebaseFirestore
              .collection(FirestoreCollections.DevicesCategories.name)
              .doc()
          : _firebaseFirestore.doc(widget.categoryDocumentPath!);
      await categoryDocumentRef.set(_category?.toJson()).then((value) {
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
    File file = File(_category!.image!);
    String randomDigits = Random().nextInt(10000000).toString();
    var imageName = randomDigits + basename(_category!.image!);
    Reference ref = categoryImagesFirebaseStorageReference.child(imageName);
    await ref.putFile(file);
    await ref.getDownloadURL().then((uploadedImageUrl) => setState(() {
          newImageUrl = uploadedImageUrl;
        }));
    return newImageUrl;
  }
}

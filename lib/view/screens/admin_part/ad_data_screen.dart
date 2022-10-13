import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:path/path.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/utils.dart';
import '../../../model/ad.dart';
import '../../../model/user_data.dart';
import '../../components/alert.dart';

class AdDataScreen extends StatefulWidget {
  final String? adPath, adminId, selectedCountry;
  final Ad? ad;
  bool isNew = true, isDevicesAds = true;

  AdDataScreen(
      {Key? key,
      required this.adPath,
      required this.ad,
      required this.isNew,
      required this.isDevicesAds,
      required this.adminId,
      required this.selectedCountry})
      : super(key: key);

  @override
  _AdDataScreenState createState() => _AdDataScreenState();
}

class _AdDataScreenState extends State<AdDataScreen> {
  List<Color> primaryGradientColors = AppColors.primaryGradientColors;
  Color primaryLightColor = AppColors.primaryColor;
  DateFormat dateFormat = DateFormat('a hh:mm - yyyy/MM/dd');
  BuildContext? dialogContext;
  Ad? ad;
  List<DropdownMenuItem<String>>? countryListDropdownItems;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  late Reference adsImagesFirebaseStorageReference;
  late final String initialImage;
  String? currentImage;

  @override
  void initState() {
    super.initState();
    countryListDropdownItems =
        getCountries().map<DropdownMenuItem<String>>((Countries value) {
      return DropdownMenuItem<String>(
          value: value.name,
          alignment: AlignmentDirectional.center,
          child: Text(value.name));
    }).toList();
    widget.isNew ? setValuesForNewAd() : setValuesForOldAd();
    adsImagesFirebaseStorageReference = _firebaseStorage.ref(
        'Ads/${widget.isDevicesAds ? FirestoreCollections.DevicesAds.name : FirestoreCollections.ClinicsAds.name}');
  }

  void setValuesForNewAd() {
    DateTime expiryDate = Jiffy(DateTime.now()).add(weeks: 1).dateTime;
    ad = Ad(widget.adminId, '', '', widget.selectedCountry, '', null, false,
        Timestamp.fromDate(expiryDate));
    initialImage = '';
  }

  void setValuesForOldAd() {
    ad = widget.ad;

    if (ad?.image != null && ad!.image!.isNotEmpty) {
      initialImage = ad!.image!;
      currentImage = initialImage;
    }
  }

  GlobalKey<FormState> formstate = new GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    LoadingIndicator dialog = loadingIndicatorWidget();
    return Directionality(
        textDirection: ui.TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: primaryGradientColors),
              ),
            ),
            title: Text(getToolbarTitle(),
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.save,
                  color: Colors.white,
                ),
                onPressed: () async => await saveAdData(context, dialog),
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
                        TextFormField(
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.text,
                            initialValue: ad!.title,
                            validator: (val) {
                              String text = val.toString().trim();
                              if (text.length > 100) {
                                return 'لا يمكن أن تكون أكثر من ١٠٠ حرف';
                              }
                              if (text.length < 2) {
                                return 'لا يمكن أن تكون أقل من حرفين';
                              }
                              return null;
                            },
                            onSaved: (val) {
                              ad!.title = val.toString().trim();
                            },
                            maxLength: 100,
                            decoration: const InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: 'عنوان الإعلان (تطبيق Clinico)',
                                prefixIcon: Icon(Icons.title))),
                        TextFormField(
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.text,
                            initialValue: ad!.redirectLink,
                            onSaved: (val) {
                              ad!.redirectLink = val.toString().trim();
                            },
                            maxLength: 1000,
                            decoration: const InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: 'رابط الإعلان (https://www.blabla)',
                                prefixIcon: Icon(FontAwesomeIcons.link))),
                        TextFormField(
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.number,
                            initialValue: ad?.priority != null
                                ? ad!.priority.toString()
                                : '',
                            validator: (val) {
                              String text = val.toString().trim();
                              if (text.length > 6) {
                                return 'لا يمكن أن تكون أكثر من ٦ أرقام';
                              }
                              if (text.isEmpty) {
                                return 'لا يمكن أن تكون أقل من رقم واحد';
                              }
                              return null;
                            },
                            onSaved: (val) {
                              ad!.priority = int.parse(val.toString().trim());
                            },
                            maxLength: 6,
                            decoration: const InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: 'الأولوية (1)',
                                prefixIcon:
                                    Icon(FontAwesomeIcons.arrowDownShortWide))),
                        TextFormField(
                            enabled: false,
                            initialValue: ad!.createdBy.toString(),
                            validator: (val) {
                              return null;
                            },
                            decoration: const InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: 'Created by',
                                prefixIcon: Icon(FontAwesomeIcons.userTie))),
                        TextFormField(
                            enabled: false,
                            initialValue: ad!.isActive.toString(),
                            validator: (val) {
                              return null;
                            },
                            decoration: const InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: "isActive",
                                prefixIcon: Icon(FontAwesomeIcons.play))),
                        TextFormField(
                            enabled: false,
                            initialValue:
                                dateFormat.format(ad!.expiryDate!.toDate()),
                            validator: (val) {
                              return null;
                            },
                            decoration: const InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: "ينتهي الإعلان في",
                                prefixIcon:
                                    Icon(FontAwesomeIcons.calendarDay))),
                        ListTile(
                          title: const Text(
                            'الدولة التي سوف يكون متاح فيها',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          leading: const Icon(FontAwesomeIcons.flag),
                          subtitle: DropdownButton<String>(
                            value: ad!.selectedCountry,
                            icon: const Icon(
                              Icons.arrow_drop_down,
                              color: Colors.black,
                            ),
                            elevation: 16,
                            style: const TextStyle(color: Colors.black),
                            underline: Container(
                              height: 2,
                              color: Colors.black,
                            ),
                            onChanged: (String? newValue) {
                              setState(() {
                                ad!.selectedCountry = newValue!;
                              });
                            },
                            items: countryListDropdownItems,
                          ),
                        ),
                        Container(
                            margin: const EdgeInsets.only(left: 1, right: 1),
                            width: MediaQuery.of(context).size.width,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              color: Colors.grey,
                              image: getAdImage(),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.image,
                                size: 20,
                                color: Colors.black,
                              ),
                              iconSize: 7,
                              onPressed: () async {
                                _showSelectImageBottomSheet(context, dialog);
                              },
                            )),
                      ]))
                ],
              )),
        ));
  }

  String getToolbarTitle() =>
      widget.isNew ? 'إضافة إعلان جديد' : 'تعديل بيانات الإعلان';

  DecorationImage? getAdImage() =>
      (currentImage != null && currentImage!.isNotEmpty)
          ? DecorationImage(
              image: getImageByItem(currentImage!),
              fit: BoxFit.cover,
            )
          : null;

  getImageByItem(String image) => Utils().isNetworkUrl(image)
      ? NetworkImage(image)
      : FileImage(File(image));

  _showSelectImageBottomSheet(context, LoadingIndicator dialog) {
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
                      "إختيار صورة",
                      style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: primaryLightColor),
                    ),
                    InkWell(
                      onTap: () async {
                        var picked = await ImagePicker()
                            .getImage(source: ImageSource.gallery);
                        if (picked != null) {
                          setState(() {
                            currentImage = picked.path;
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
                                color: primaryLightColor,
                              ),
                              const SizedBox(width: 20),
                              Text(
                                "من المعرض",
                                style: TextStyle(
                                    fontSize: 20, color: primaryLightColor),
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
                            currentImage = picked.path;
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
                                color: primaryLightColor,
                              ),
                              const SizedBox(width: 20),
                              Text(
                                "من الكاميرا",
                                style: TextStyle(
                                    fontSize: 20, color: primaryLightColor),
                              )
                            ],
                          )),
                    ),
                  ],
                ),
              ));
        });
  }

  saveAdData(context, LoadingIndicator dialog) async {
    var formData = formstate.currentState;
    if (formData!.validate()) {
      if (currentImage == null || currentImage!.isEmpty) {
        Fluttertoast.showToast(msg: 'برجاء إختيار صورة الإعلان!');
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
      await _getReadyImage(initialImage, currentImage!)
          .then((imageUrl) => ad!.image = imageUrl);
      DocumentReference adDocumentRef = widget.isNew
          ? _firebaseFirestore
              .collection(widget.isDevicesAds
                  ? FirestoreCollections.DevicesAds.name
                  : FirestoreCollections.ClinicsAds.name)
              .doc()
          : _firebaseFirestore.doc(widget.adPath!);

      await adDocumentRef
          .set(ad?.toJson())
          .then((value) => {
                Fluttertoast.showToast(msg: 'تم الحفظ بنجاح!'),
                Navigator.pop(dialogContext!),
                Navigator.pop(context)
              })
          .catchError((error) {
        Fluttertoast.showToast(msg: 'حدث خطأ ما!');
      });
    }
  }

  Future<String> _getReadyImage(
      String initialImage, String currentImage) async {
    String readyImage = '';
    if (currentImage == initialImage) {
      readyImage = initialImage;
    } else {
      if (Utils().isNetworkUrl(initialImage)) {
        await _firebaseStorage.refFromURL(initialImage).delete();
      }
      File file = File(currentImage);
      String randomDigits = Random().nextInt(10000000).toString();
      var imageName = randomDigits + basename(currentImage);
      Reference ref = adsImagesFirebaseStorageReference.child(imageName);
      await ref.putFile(file);
      await ref.getDownloadURL().then((uploadedImageUrl) => setState(() {
            readyImage = uploadedImageUrl;
          }));
    }
    return readyImage;
  }

  List<Countries> getCountries() => Countries.values.cast().toList().cast();
}

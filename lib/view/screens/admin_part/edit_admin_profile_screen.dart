import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:clinico/constants/utils.dart';
import 'package:clinico/model/admin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:path/path.dart';

import '../../../constants/account_constants.dart';
import '../../../constants/app_colors.dart';
import '../../components/alert.dart';
import '../../components/custom_circular_widget.dart';

class EditAdminProfileScreen extends StatefulWidget {
  String? adminDocumentReferencePath, adminDocumentReferenceId;
  Admin admin;

  EditAdminProfileScreen(
      {Key? key,
      required this.adminDocumentReferencePath,
      required this.adminDocumentReferenceId,
      required this.admin})
      : super(key: key);

  @override
  _EditAdminProfileScreenState createState() => _EditAdminProfileScreenState();
}

class _EditAdminProfileScreenState extends State<EditAdminProfileScreen> {
  BuildContext? dialogContext;
  Color primaryColor = AppColors.primaryColor;
  List<Color> primaryGradientColors = AppColors.primaryGradientColors;
  Admin? _admin;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  late Reference usersProfileImagesFirebaseStorageReference;
  late final String initialImage;
  String? currentImage;

  @override
  void initState() {
    _admin = widget.admin;
    if (_admin?.image != null && _admin!.image!.isNotEmpty) {
      initialImage = _admin!.image!;
      currentImage = initialImage;
    } else {
      initialImage = '';
    }

    usersProfileImagesFirebaseStorageReference =
        _firebaseStorage.ref('Users/profile/profileImage');
    super.initState();
  }

  GlobalKey<FormState> formstate = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    LoadingIndicator dialog = loadingIndicatorWidget();

    return Directionality(
        textDirection: ui.TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('تعديل الملف الشخصي',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                onPressed: () async => await _saveProfileData(context, dialog),
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
                            imageProvider: getImageByItem(currentImage ?? ''),
                            borderColor: primaryColor,
                            isEditable: true,
                            isEdit: true,
                            onClicked: () async {
                              _showSelectImageBottomSheet(
                                  context, dialog, 'الصورة الشخصية');
                            },
                          ),
                        ),
                        TextFormField(
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.name,
                            initialValue: _admin?.name ?? '',
                            validator: (val) {
                              String text = val.toString().trim();
                              if (text.length > 30) {
                                return 'أقصى عدد للأحرف هو ٣٠';
                              }
                              if (text.length < 5) {
                                return 'أقل عدد للأحرف هو ٥';
                              }
                              return null;
                            },
                            onSaved: (val) {
                              _admin?.name =
                                  Utils().capitalize(val.toString().trim());
                            },
                            maxLength: 30,
                            decoration: const InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: "الإسم",
                                prefixIcon: Icon(FontAwesomeIcons.user))),
                        TextFormField(
                            textInputAction: TextInputAction.done,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            keyboardType: TextInputType.phone,
                            initialValue: _admin?.phoneNumber ?? '',
                            validator: (val) {
                              String text = val.toString().trim();
                              if (text.length !=
                                  AccountConstants
                                      .getPhoneNumberDigitCountByCountryName(
                                          _admin!.selectedCountry!)) {
                                return 'رقم الهاتف غير صحيح!';
                              }
                              return null;
                            },
                            onSaved: (val) {
                              _admin?.phoneNumber =
                                  Utils().capitalize(val.toString().trim());
                            },
                            maxLength: AccountConstants
                                .getPhoneNumberDigitCountByCountryName(
                                    _admin!.selectedCountry!),
                            decoration: const InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: 'رقم الهاتف (010xxxxxxxx)',
                                prefixIcon: Icon(FontAwesomeIcons.phoneFlip))),
                        TextFormField(
                            enabled: false,
                            initialValue: _admin?.email ?? '',
                            validator: (val) => null,
                            decoration: const InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: "البريد الإلكتروني",
                                prefixIcon: Icon(FontAwesomeIcons.envelope))),
                        TextFormField(
                            enabled: false,
                            initialValue: AccountConstants
                                .accountStatusTitleList[_admin!.accountStatus],
                            style: TextStyle(
                                color: AccountConstants
                                    .accountStatusColor[_admin!.accountStatus]),
                            validator: (val) => null,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              labelText: "حالة الحساب",
                              prefixIcon: AccountConstants
                                  .accountStatusIconList[_admin!.accountStatus],
                            )),
                      ]))
                ],
              )),
        ));
  }

  getImageByItem(String image) => Utils().isNetworkUrl(image)
      ? NetworkImage(image)
      : FileImage(File(image));

  _showSelectImageBottomSheet(
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

  _saveProfileData(context, LoadingIndicator dialog) async {
    var formData = formstate.currentState;
    if (formData!.validate()) {
      if (currentImage == null || currentImage!.isEmpty) {
        Fluttertoast.showToast(msg: 'برجاء إختيار الصورة الشخصية!');
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
      await _getReadyImage(usersProfileImagesFirebaseStorageReference,
              initialImage, currentImage!)
          .then((imageUrl) => _admin!.image = imageUrl);
      DocumentReference accountDocumentRef =
          _firebaseFirestore.doc(widget.adminDocumentReferencePath!);
      await accountDocumentRef.set(_admin?.toJson()).then((value) {
        Fluttertoast.showToast(msg: 'تم الحفظ بنجاح!');
        Navigator.pop(dialogContext!);
        Navigator.pop(context);
      }).catchError((error) {
        Fluttertoast.showToast(msg: 'حدث خطأ ما!');
      });
    }
  }

  Future<String> _getReadyImage(Reference firebaseStorageReference,
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
      Reference ref = firebaseStorageReference.child(imageName);
      await ref.putFile(file);
      await ref.getDownloadURL().then((uploadedImageUrl) => setState(() {
            readyImage = uploadedImageUrl;
          }));
    }
    return readyImage;
  }
}

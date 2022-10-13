import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:clinico/constants/utils.dart';
import 'package:clinico/model/company.dart';
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

class EditCompanyProfileScreen extends StatefulWidget {
  String? companyDocumentReferencePath, companyDocumentReferenceId;
  Company company;

  EditCompanyProfileScreen(
      {Key? key,
      required this.companyDocumentReferencePath,
      required this.companyDocumentReferenceId,
      required this.company})
      : super(key: key);

  @override
  _EditCompanyProfileScreenState createState() =>
      _EditCompanyProfileScreenState();
}

class _EditCompanyProfileScreenState extends State<EditCompanyProfileScreen> {
  BuildContext? dialogContext;
  Color primaryColor = AppColors.primaryColor;
  List<Color> primaryGradientColors = AppColors.primaryGradientColors;
  Company? _company;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  late Reference usersProfileImagesFirebaseStorageReference,
      usersProfileDocumentsFirebaseStorageReference;
  late final String initialImage;
  String? currentImage;
  late List<dynamic> initialDocumentList;
  List<dynamic> currentDocumentList = [];

  @override
  void initState() {
    _company = widget.company;
    if (_company?.image != null && _company!.image!.isNotEmpty) {
      initialImage = _company!.image!;
      currentImage = initialImage;
    } else {
      initialImage = '';
    }

    if (_company?.documents != null && _company!.documents!.isNotEmpty) {
      initialDocumentList = List.unmodifiable(_company!.documents!);
      currentDocumentList.addAll(initialDocumentList);
    } else {
      initialDocumentList = List.unmodifiable([]);
    }

    usersProfileImagesFirebaseStorageReference =
        _firebaseStorage.ref('Users/profile/profileImage');
    usersProfileDocumentsFirebaseStorageReference =
        _firebaseStorage.ref('Users/profile/documents');
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
                                  context, dialog, 'شعار الشركة', true, null);
                            },
                          ),
                        ),
                        TextFormField(
                            enableInteractiveSelection: true,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.name,
                            initialValue: _company?.name ?? '',
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
                              _company?.name =
                                  Utils().capitalize(val.toString().trim());
                            },
                            maxLength: 30,
                            decoration: const InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: "الإسم",
                                prefixIcon: Icon(FontAwesomeIcons.user))),
                        TextFormField(
                            enableInteractiveSelection: true,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.name,
                            initialValue: _company?.address ?? '',
                            validator: (val) {
                              String text = val.toString().trim();
                              if (text.length > 80) {
                                return 'أقصى عدد للأحرف هو ٨٠';
                              }
                              if (text.length < 5) {
                                return 'أقل عدد للأحرف هو ٥';
                              }
                              return null;
                            },
                            onSaved: (val) {
                              _company?.address =
                                  Utils().capitalize(val.toString().trim());
                            },
                            maxLength: 80,
                            decoration: const InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: "العنوان",
                                prefixIcon:
                                    Icon(FontAwesomeIcons.locationDot))),
                        TextFormField(
                            enableInteractiveSelection: true,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.phone,
                            initialValue: _company?.phoneNumber ?? '',
                            validator: (val) {
                              String text = val.toString().trim();
                              if (text.length !=
                                  AccountConstants
                                      .getPhoneNumberDigitCountByCountryName(
                                          _company!.selectedCountry!)) {
                                return 'رقم الهاتف غير صحيح!';
                              }
                              return null;
                            },
                            onSaved: (val) {
                              _company?.phoneNumber =
                                  Utils().capitalize(val.toString().trim());
                            },
                            maxLength: AccountConstants
                                .getPhoneNumberDigitCountByCountryName(
                                    _company!.selectedCountry!),
                            decoration: const InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: 'رقم الهاتف (010xxxxxxxx)',
                                prefixIcon: Icon(FontAwesomeIcons.phoneFlip))),
                        TextFormField(
                            enableInteractiveSelection: true,
                            keyboardType: TextInputType.multiline,
                            minLines: 1,
                            maxLines: 5,
                            textInputAction: TextInputAction.done,
                            initialValue: _company?.about ?? '',
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
                              _company?.about =
                                  Utils().capitalize(val.toString().trim());
                            },
                            maxLength: 1000,
                            decoration: const InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: "من نحن؟",
                                prefixIcon:
                                    Icon(FontAwesomeIcons.addressCard))),
                        TextFormField(
                            enableInteractiveSelection: true,
                            enabled: false,
                            initialValue: _company?.email ?? '',
                            validator: (val) => null,
                            decoration: const InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: "البريد الإلكتروني",
                                prefixIcon: Icon(FontAwesomeIcons.envelope))),
                        TextFormField(
                            enableInteractiveSelection: true,
                            enabled: false,
                            initialValue:
                                AccountConstants.accountStatusTitleList[
                                    _company!.accountStatus],
                            style: TextStyle(
                                color: AccountConstants.accountStatusColor[
                                    _company!.accountStatus]),
                            validator: (val) => null,
                            decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: "حالة الحساب",
                                prefixIcon:
                                    AccountConstants.accountStatusIconList[
                                        _company!.accountStatus])),
                        const SizedBox(height: 3),
                        Container(
                          margin: const EdgeInsets.only(left: 10, right: 10),
                          alignment: Alignment.centerRight,
                          child: const Text('المستندات',
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
                                                            'يجب أن يكون لديك على الأقل مستند واحد!');
                                                    return;
                                                  }
                                                  showDialog<String>(
                                                      context: context,
                                                      barrierDismissible: false,
                                                      builder: (BuildContext
                                                              context) =>
                                                          Directionality(
                                                            textDirection: ui
                                                                .TextDirection
                                                                .rtl,
                                                            child: AlertDialog(
                                                              title: const Text(
                                                                'حذف مستند',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black),
                                                                textDirection: ui
                                                                    .TextDirection
                                                                    .rtl,
                                                              ),
                                                              content: const Text(
                                                                  'هل متأكد من حذف هذا المستند ؟',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .black),
                                                                  textDirection:
                                                                      ui.TextDirection
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
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.pop(
                                                                        context,
                                                                        'Ok');
                                                                    setState(
                                                                        () {
                                                                      currentDocumentList
                                                                          .remove(
                                                                              item);
                                                                    });
                                                                  },
                                                                  child:
                                                                      const Text(
                                                                          'نعم'),
                                                                ),
                                                              ],
                                                            ),
                                                          ));
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
                                              msg: 'أقصى عدد للمستندات هو ٤');
                                          return;
                                        }
                                        _showSelectImageBottomSheet(
                                            context,
                                            dialog,
                                            'المستند',
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
                              currentImage = picked.path;
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
                              currentImage = picked.path;
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

  _saveProfileData(context, LoadingIndicator dialog) async {
    var formData = formstate.currentState;
    if (formData!.validate()) {
      if (currentImage == null || currentImage!.isEmpty) {
        Fluttertoast.showToast(msg: 'برجاء صورة شعار الشركة!');
        return;
      }
      if (currentDocumentList.isEmpty) {
        Fluttertoast.showToast(msg: 'برجاء إختيار مستند واحد على الأقل!');
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
          .then((imageUrl) => _company!.image = imageUrl);
      await getReadyDocumentList(usersProfileDocumentsFirebaseStorageReference,
              initialDocumentList, currentDocumentList)
          .then((imageList) => _company!.documents = imageList);
      DocumentReference accountDocumentRef =
          _firebaseFirestore.doc(widget.companyDocumentReferencePath!);
      await accountDocumentRef.set(_company?.toJson()).then((value) {
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

  Future<List> getReadyDocumentList(Reference firebaseStorageReference,
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
}

import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:clinico/constants/account_constants.dart';
import 'package:clinico/constants/utils.dart';
import 'package:clinico/model/doctor.dart';
import 'package:clinico/model/selected_speciality.dart';
import 'package:clinico/model/update_doctor_speciality_request.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:path/path.dart';

import '../../../constants/app_colors.dart';
import '../../../model/speciality.dart';
import '../../../model/update_doctor_level_request.dart';
import '../../../model/user_data.dart';
import '../../components/alert.dart';
import '../../components/custom_circular_widget.dart';
import 'doctor_level_selection_screen.dart';
import 'doctor_speciality_selection_screen.dart';

class EditDoctorProfileScreen extends StatefulWidget {
  String? doctorDocumentReferencePath, doctorDocumentReferenceId;
  Doctor doctor;
  Speciality? doctorSpeciality;

  EditDoctorProfileScreen(
      {Key? key,
      required this.doctorDocumentReferencePath,
      required this.doctorDocumentReferenceId,
      required this.doctor,
      required this.doctorSpeciality})
      : super(key: key);

  @override
  _EditDoctorProfileScreenState createState() =>
      _EditDoctorProfileScreenState();
}

class _EditDoctorProfileScreenState extends State<EditDoctorProfileScreen> {
  BuildContext? dialogContext;
  Color primaryColor = AppColors.primaryColor;
  List<Color> primaryGradientColors = AppColors.primaryGradientColors;
  Doctor? _doctor;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  late Reference usersProfileImagesFirebaseStorageReference,
      usersProfileDocumentsFirebaseStorageReference;
  late final String initialImage;
  String? currentImage;
  late List<dynamic> initialDocumentList;
  List<dynamic> currentDocumentList = [];
  late final String? initialSelectedDoctorLevel;
  String? newSelectedDoctorLevel;
  late final SelectedSpeciality? initialSelectedSpeciality;
  SelectedSpeciality? newSelectedSpeciality;

  @override
  void initState() {
    _doctor = widget.doctor;

    _getInitialSelectedDoctorLevel();
    _getInitialSelectedDoctorSpecialityId();

    if (_doctor?.image != null && _doctor!.image!.isNotEmpty) {
      initialImage = _doctor!.image!;
      currentImage = initialImage;
    } else {
      initialImage = '';
    }

    if (_doctor?.documents != null && _doctor!.documents!.isNotEmpty) {
      initialDocumentList = List.unmodifiable(_doctor!.documents!);
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

  _getInitialSelectedDoctorLevel() async {
    await _firebaseFirestore
        .collection(FirestoreCollections.UpdateDoctorLevelRequests.name)
        .doc(widget.doctorDocumentReferenceId)
        .get()
        .then((value) {
      setState(() {
        if (value.exists) {
          initialSelectedDoctorLevel =
              UpdateDoctorLevelRequest.fromJson(value.data()).newLevel;
          newSelectedDoctorLevel = initialSelectedDoctorLevel;
        } else {
          initialSelectedDoctorLevel = null;
        }
      });
    });
  }

  _getInitialSelectedDoctorSpecialityId() async {
    await _firebaseFirestore
        .collection(FirestoreCollections.UpdateDoctorSpecialityRequests.name)
        .doc(widget.doctorDocumentReferenceId)
        .get()
        .then((value) {
      if (value.exists) {
        String? initialSpecialityId =
            UpdateDoctorSpecialityRequest.fromJson(value.data())
                .newSpecialityId;
        if (initialSpecialityId != null) {
          _firebaseFirestore
              .collection(FirestoreCollections.Specialties.name)
              .doc(initialSpecialityId)
              .get()
              .then((value) {
            if (value.exists) {
              setState(() {
                Speciality initialSpeciality =
                    Speciality.fromJson(value.data());
                initialSelectedSpeciality =
                    SelectedSpeciality(initialSpecialityId, initialSpeciality);
                newSelectedSpeciality = initialSelectedSpeciality;
              });
            }
          });
        }
      } else {
        setState(() {
          initialSelectedSpeciality = null;
        });
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
            title: const Text('?????????? ?????????? ????????????',
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
                              _showSelectImageBottomSheet(context, dialog,
                                  '???????????? ??????????????', true, null);
                            },
                          ),
                        ),
                        TextFormField(
                            enableInteractiveSelection: true,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.name,
                            initialValue: _doctor?.name ?? '',
                            validator: (val) {
                              String text = val.toString().trim();
                              if (text.length > 30) {
                                return '???????? ?????? ???????????? ???? ????';
                              }
                              if (text.length < 5) {
                                return '?????? ?????? ???????????? ???? ??';
                              }
                              return null;
                            },
                            onSaved: (val) {
                              _doctor?.name =
                                  Utils().capitalize(val.toString().trim());
                            },
                            maxLength: 30,
                            decoration: const InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: "??????????",
                                prefixIcon: Icon(FontAwesomeIcons.user))),
                        TextFormField(
                            enableInteractiveSelection: true,
                            textInputAction: TextInputAction.next,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            keyboardType: TextInputType.phone,
                            initialValue: _doctor?.phoneNumber ?? '',
                            validator: (val) {
                              String text = val.toString().trim();
                              if (text.length !=
                                  AccountConstants
                                      .getPhoneNumberDigitCountByCountryName(
                                          _doctor!.selectedCountry!)) {
                                return '?????? ???????????? ?????? ????????!';
                              }
                              return null;
                            },
                            onSaved: (val) {
                              _doctor?.phoneNumber =
                                  Utils().capitalize(val.toString().trim());
                            },
                            maxLength: AccountConstants
                                .getPhoneNumberDigitCountByCountryName(
                                    _doctor!.selectedCountry!),
                            decoration: const InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: '?????? ???????????? (010xxxxxxxx)',
                                prefixIcon: Icon(FontAwesomeIcons.phoneFlip))),
                        TextFormField(
                            enableInteractiveSelection: true,
                            keyboardType: TextInputType.multiline,
                            minLines: 1,
                            maxLines: 5,
                            textInputAction: TextInputAction.done,
                            initialValue: _doctor?.about ?? '',
                            validator: (val) {
                              String text = val.toString().trim();
                              if (text.length > 1000) {
                                return '???????? ?????? ???????????? ???? ????????';
                              }
                              if (text.length < 10) {
                                return '?????? ?????? ???????????? ???? ????';
                              }
                              return null;
                            },
                            onSaved: (val) {
                              _doctor?.about =
                                  Utils().capitalize(val.toString().trim());
                            },
                            maxLength: 1000,
                            decoration: const InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: "???? ????????",
                                prefixIcon:
                                    Icon(FontAwesomeIcons.addressCard))),
                        TextFormField(
                            enableInteractiveSelection: true,
                            enabled: false,
                            initialValue: _doctor?.email ?? '',
                            validator: (val) => null,
                            decoration: const InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: "???????????? ????????????????????",
                                prefixIcon: Icon(FontAwesomeIcons.envelope))),
                        TextFormField(
                            enableInteractiveSelection: true,
                            enabled: false,
                            initialValue: AccountConstants
                                .accountStatusTitleList[_doctor!.accountStatus],
                            style: TextStyle(
                                color: AccountConstants.accountStatusColor[
                                    _doctor!.accountStatus]),
                            validator: (val) => null,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              labelText: "???????? ????????????",
                              prefixIcon:
                                  AccountConstants.accountStatusIconList[
                                      _doctor!.accountStatus],
                            )),
                        ListTile(
                          leading: const SizedBox(
                              height: double.infinity,
                              child: Icon(FontAwesomeIcons.userDoctor)),
                          title: const Text(
                            '?????????? ????????????',
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                          subtitle: _updateDoctorLevelDescriptionWidget(),
                          trailing: IconButton(
                            onPressed: () =>
                                _startDoctorLevelSelectionScreen(context),
                            icon: const SizedBox(
                                height: double.infinity,
                                child: Icon(FontAwesomeIcons.penToSquare)),
                          ),
                        ),
                        ListTile(
                          leading: const SizedBox(
                              height: double.infinity,
                              child: Icon(FontAwesomeIcons.stethoscope)),
                          title: const Text(
                            '????????????',
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                          subtitle: _updateSpecialityDescriptionWidget(),
                          trailing: IconButton(
                            onPressed: () =>
                                _startSpecialitySelectionScreen(context),
                            icon: const SizedBox(
                                height: double.infinity,
                                child: Icon(FontAwesomeIcons.penToSquare)),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Container(
                            margin: const EdgeInsets.only(left: 10, right: 10),
                            alignment: Alignment.centerRight,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('??????????????????',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    )),
                                _updateDocumentsTextWidget()
                              ],
                            )),
                        const SizedBox(height: 3),
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
                                                            '?????? ???? ???????? ???????? ?????? ?????????? ?????????? ????????!');
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
                                                                '?????? ??????????',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black),
                                                                textDirection: ui
                                                                    .TextDirection
                                                                    .rtl,
                                                              ),
                                                              content: const Text(
                                                                  '???? ?????????? ???? ?????? ?????? ?????????????? ??',
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
                                                                      '??????????'),
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
                                                                          '??????'),
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
                                              msg: '???????? ?????? ?????????????????? ???? ??');
                                          return;
                                        }
                                        _showSelectImageBottomSheet(
                                            context,
                                            dialog,
                                            '??????????????',
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
                      "???????????? $imageTypeTitle",
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
                                "???? ????????????",
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
                                "???? ????????????????",
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

  _startDoctorLevelSelectionScreen(BuildContext context) async =>
      await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const DoctorLevelSelectionScreen()))
          .then((value) => {
                if (value != null)
                  {
                    setState(() {
                      newSelectedDoctorLevel = value as String;
                    })
                  }
              });

  _startSpecialitySelectionScreen(BuildContext context) async =>
      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  const DoctorSpecialitySelectionScreen())).then((value) => {
            if (value != null)
              {
                setState(() {
                  newSelectedSpeciality = value as SelectedSpeciality;
                })
              }
          });

  Widget _updateDoctorLevelDescriptionWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_doctor?.doctorLevel}',
          style: const TextStyle(fontSize: 13, color: Colors.black),
        ),
        Visibility(
          visible: newSelectedDoctorLevel != null &&
              newSelectedDoctorLevel != _doctor?.doctorLevel,
          child: Row(
            children: [
              const Icon(
                FontAwesomeIcons.spinner,
                color: Colors.orangeAccent,
                size: 11,
              ),
              const SizedBox(width: 4),
              Text('?????????? ??????: $newSelectedDoctorLevel',
                  style:
                      const TextStyle(fontSize: 10, color: Colors.orangeAccent))
            ],
          ),
        ),
      ],
    );
  }

  Widget _updateSpecialityDescriptionWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${widget.doctorSpeciality?.arabicTitle}',
          style: const TextStyle(fontSize: 13, color: Colors.black),
        ),
        Visibility(
          visible: newSelectedSpeciality != null &&
              newSelectedSpeciality!.id != _doctor?.specialityId,
          child: Row(
            children: [
              const Icon(
                FontAwesomeIcons.spinner,
                color: Colors.orangeAccent,
                size: 11,
              ),
              const SizedBox(width: 4),
              Text(
                  '?????????? ??????: ${newSelectedSpeciality?.speciality.arabicTitle}',
                  style:
                      const TextStyle(fontSize: 10, color: Colors.orangeAccent))
            ],
          ),
        ),
      ],
    );
  }

  _updateDocumentsTextWidget() {
    return Visibility(
      visible: newSelectedDoctorLevel != null &&
              newSelectedDoctorLevel != _doctor?.doctorLevel ||
          newSelectedSpeciality != null &&
              newSelectedSpeciality!.id != _doctor?.specialityId,
      child: const Text(
          '* ?????????? ???????????? ???? ???? ???????????????? ?????????? ?????????? ??????????????/???????????? ???????????? ?????? ?????? ??????????.',
          style: TextStyle(fontSize: 8, color: Colors.red)),
    );
  }

  _saveProfileData(context, LoadingIndicator dialog) async {
    var formData = formstate.currentState;
    if (formData!.validate()) {
      if (currentImage == null || currentImage!.isEmpty) {
        Fluttertoast.showToast(msg: '?????????? ???????????? ???????????? ??????????????!');
        return;
      }
      if (currentDocumentList.isEmpty) {
        Fluttertoast.showToast(msg: '?????????? ???????????? ?????????? ???????? ?????? ??????????!');
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

      if (initialSelectedDoctorLevel != null &&
          newSelectedDoctorLevel != null &&
          initialSelectedDoctorLevel != newSelectedDoctorLevel &&
          newSelectedDoctorLevel == _doctor?.doctorLevel) {
        _deleteUpdateDoctorLevelRequest();
      }
      if (initialSelectedSpeciality != null &&
          newSelectedSpeciality != null &&
          initialSelectedSpeciality?.id != newSelectedSpeciality?.id &&
          newSelectedSpeciality?.id == _doctor?.specialityId) {
        _deleteUpdateDoctorSpecialityRequest();
      }

      if (newSelectedDoctorLevel != null &&
              newSelectedDoctorLevel != _doctor?.doctorLevel &&
              newSelectedDoctorLevel != initialSelectedDoctorLevel ||
          newSelectedSpeciality != null &&
              newSelectedSpeciality!.id != _doctor?.specialityId &&
              newSelectedSpeciality != initialSelectedSpeciality) {
        if (newSelectedDoctorLevel != null &&
            newSelectedDoctorLevel != _doctor?.doctorLevel &&
            newSelectedDoctorLevel != initialSelectedDoctorLevel)
          await _requestUpdateDoctorLevel();
        if (newSelectedSpeciality != null &&
            newSelectedSpeciality!.id != _doctor?.specialityId &&
            newSelectedSpeciality != initialSelectedSpeciality)
          await _requestUpdateDoctorSpeciality();
        _updateDoctorDocumentDataInFirestore(context);
      } else {
        _updateDoctorDocumentDataInFirestore(context);
      }
    }
  }

  _deleteUpdateDoctorLevelRequest() async {
    await _firebaseFirestore
        .collection(FirestoreCollections.UpdateDoctorLevelRequests.name)
        .doc(widget.doctorDocumentReferenceId)
        .delete()
        .then((value) => {})
        .catchError((error) {
      Fluttertoast.showToast(msg: '?????? ?????? ????!');
    });
  }

  _deleteUpdateDoctorSpecialityRequest() async {
    await _firebaseFirestore
        .collection(FirestoreCollections.UpdateDoctorSpecialityRequests.name)
        .doc(widget.doctorDocumentReferenceId)
        .delete()
        .then((value) => {})
        .catchError((error) {
      Fluttertoast.showToast(msg: '?????? ?????? ????!');
    });
  }

  _requestUpdateDoctorLevel() async {
    UpdateDoctorLevelRequest updateDoctorLevelRequest =
        UpdateDoctorLevelRequest(
            widget.doctorDocumentReferencePath, newSelectedDoctorLevel);
    await _firebaseFirestore
        .collection(FirestoreCollections.UpdateDoctorLevelRequests.name)
        .doc(widget.doctorDocumentReferenceId)
        .set(updateDoctorLevelRequest.toJson())
        .then((value) => {})
        .catchError((error) {
      Fluttertoast.showToast(msg: '?????? ?????? ????!');
    });
  }

  _requestUpdateDoctorSpeciality() async {
    UpdateDoctorSpecialityRequest updateDoctorSpecialityRequest =
        UpdateDoctorSpecialityRequest(
            widget.doctorDocumentReferencePath, newSelectedSpeciality?.id);
    await _firebaseFirestore
        .collection(FirestoreCollections.UpdateDoctorSpecialityRequests.name)
        .doc(widget.doctorDocumentReferenceId)
        .set(updateDoctorSpecialityRequest.toJson())
        .then((value) => {})
        .catchError((error) {
      Fluttertoast.showToast(msg: '?????? ?????? ????!');
    });
  }

  void _updateDoctorDocumentDataInFirestore(context) async {
    await _getReadyImage(usersProfileImagesFirebaseStorageReference,
            initialImage, currentImage!)
        .then((imageUrl) => _doctor!.image = imageUrl);
    await getReadyDocumentList(usersProfileDocumentsFirebaseStorageReference,
            initialDocumentList, currentDocumentList)
        .then((imageList) => _doctor!.documents = imageList);
    DocumentReference accountDocumentRef =
        _firebaseFirestore.doc(widget.doctorDocumentReferencePath!);
    await accountDocumentRef.set(_doctor?.toJson()).then((value) {
      Fluttertoast.showToast(msg: '???? ?????????? ??????????!');
      Navigator.pop(dialogContext!);
      Navigator.pop(context);
    }).catchError((error) {
      Fluttertoast.showToast(msg: '?????? ?????? ????!');
    });
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

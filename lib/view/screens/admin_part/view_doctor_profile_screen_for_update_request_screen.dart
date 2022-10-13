import 'dart:ui' as ui;

import 'package:clinico/constants/app_colors.dart';
import 'package:clinico/model/update_doctor_level_request.dart';
import 'package:clinico/model/update_doctor_speciality_request.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_indicator/loading_indicator.dart';

import '../../../model/speciality.dart';
import '../../../model/user_data.dart';
import '../../components/alert.dart';
import '../../components/user_profile_widget.dart';

class ViewDoctorProfileScreenForUpdateRequestScreen extends StatefulWidget {
  final bool isDoctorLevelUpdate, isDoctorSpecialityUpdate;
  final Map<String, dynamic>? doctorAccountJsonMap;
  final String? doctorId;
  final UpdateDoctorLevelRequest? updateDoctorLevelRequest;
  final UpdateDoctorSpecialityRequest? updateDoctorSpecialityRequest;

  const ViewDoctorProfileScreenForUpdateRequestScreen(
      {Key? key,
      required this.isDoctorLevelUpdate,
      required this.isDoctorSpecialityUpdate,
      required this.doctorAccountJsonMap,
      required this.doctorId,
      required this.updateDoctorLevelRequest,
      required this.updateDoctorSpecialityRequest})
      : super(key: key);

  @override
  _ViewDoctorProfileScreenForUpdateRequestScreenState createState() =>
      _ViewDoctorProfileScreenForUpdateRequestScreenState();
}

class _ViewDoctorProfileScreenForUpdateRequestScreenState
    extends State<ViewDoctorProfileScreenForUpdateRequestScreen> {
  BuildContext? dialogContext;
  List<Color> primaryGradientColors = AppColors.primaryGradientColors;
  Color primaryLightColor = AppColors.primaryColor;
  late final FirebaseFirestore _firebaseFirestore;
  Speciality? _doctorSpeciality, _requestedDoctorSpeciality;

  @override
  void initState() {
    _firebaseFirestore = FirebaseFirestore.instance;
    if (widget.doctorAccountJsonMap?['specialityId'] != null &&
        widget.doctorAccountJsonMap!['specialityId']
            .toString()
            .trim()
            .isNotEmpty) {
      getDoctorSpeciality();
    }
    if (widget.isDoctorSpecialityUpdate) _getRequestedSpeciality();
    super.initState();
  }

  void getDoctorSpeciality() {
    _firebaseFirestore
        .collection(FirestoreCollections.Specialties.name)
        .doc(widget.doctorAccountJsonMap!['specialityId'])
        .get()
        .then((value) {
      setState(() {
        _doctorSpeciality = Speciality.fromJson(value.data());
      });
    });
  }

  void _getRequestedSpeciality() {
    _firebaseFirestore
        .collection(FirestoreCollections.Specialties.name)
        .doc(widget.updateDoctorSpecialityRequest?.newSpecialityId)
        .get()
        .then((value) {
      setState(() {
        _requestedDoctorSpeciality = Speciality.fromJson(value.data());
      });
    });
  }

  @override
  Widget build(BuildContext mContext) {
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
              actions: [
                TextButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.orange),
                  ),
                  onPressed: () {
                    showDialog<String>(
                        context: mContext,
                        barrierDismissible: false,
                        builder: (BuildContext context) => Directionality(
                            textDirection: ui.TextDirection.rtl,
                            child: AlertDialog(
                              title: const Text(
                                'تحديث بيانات الطبيب',
                                style: TextStyle(color: Colors.black),
                                textDirection: ui.TextDirection.rtl,
                              ),
                              content: const Text(
                                  'هل متأكد من تحديث بيانات الطبيب ؟',
                                  style: TextStyle(color: Colors.black),
                                  textDirection: ui.TextDirection.rtl),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, 'Cancel'),
                                  child: const Text('إلغاء'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context, 'Ok');
                                    widget.isDoctorLevelUpdate
                                        ? updateDoctorLevelInFirestoreDB(
                                            mContext, dialog)
                                        : updateDoctorSpecialityInFirestoreDB(
                                            mContext, dialog);
                                  },
                                  child: const Text('نعم'),
                                ),
                              ],
                            )));
                  },
                  child: Text(
                    _getUpdateText(),
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                )
              ],
            ),
            body: UserProfileWidget(
              userAccountJsonMap: widget.doctorAccountJsonMap,
              doctorSpeciality: _doctorSpeciality,
            )));
  }

  String _getUpdateText() => widget.isDoctorLevelUpdate
      ? 'تهيئة المستوى إلى: ${widget.updateDoctorLevelRequest?.newLevel ?? ''}'
      : 'تهيئة التخصص إلى: ${_requestedDoctorSpeciality?.arabicTitle ?? ''}';

  updateDoctorLevelInFirestoreDB(context, LoadingIndicator dialog) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          dialogContext = context;
          return dialog;
        });
    await _firebaseFirestore
        .doc(widget.updateDoctorLevelRequest!.doctorDocumentReferencePath!)
        .update({
      'doctorLevel': widget.updateDoctorLevelRequest!.newLevel
    }).then((value) async {
      await _firebaseFirestore
          .collection(FirestoreCollections.UpdateDoctorLevelRequests.name)
          .doc(widget.doctorId)
          .delete()
          .then((value) {
        Fluttertoast.showToast(msg: 'تم التعديل بنجاح!');
        Navigator.pop(dialogContext!);
        Navigator.pop(context);
      }).catchError((error) {
        Fluttertoast.showToast(msg: 'حدث خطأ ما!');
      });
    });
  }

  updateDoctorSpecialityInFirestoreDB(context, LoadingIndicator dialog) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          dialogContext = context;
          return dialog;
        });
    await _firebaseFirestore
        .doc(widget.updateDoctorSpecialityRequest!.doctorDocumentReferencePath!)
        .update({
      'specialityId': widget.updateDoctorSpecialityRequest!.newSpecialityId
    }).then((value) async {
      await _firebaseFirestore
          .collection(FirestoreCollections.UpdateDoctorSpecialityRequests.name)
          .doc(widget.doctorId)
          .delete()
          .then((value) {
        Fluttertoast.showToast(msg: 'تم التعديل بنجاح!');
        Navigator.pop(dialogContext!);
        Navigator.pop(context);
      }).catchError((error) {
        Fluttertoast.showToast(msg: 'حدث خطأ ما!');
      });
    });
  }
}

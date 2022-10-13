import 'dart:ui' as ui;

import 'package:clinico/constants/app_colors.dart';
import 'package:clinico/view/screens/patient_part/patient_clinic_appointment_booking_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_indicator/loading_indicator.dart';

import '../../helper/shared_preferences.dart';
import '../../model/clinic.dart';
import '../../model/doctor.dart';
import '../../model/speciality.dart';
import '../../model/user_data.dart';
import '../components/alert.dart';
import '../components/clinic_profile_widget.dart';
import 'doctor_part/doctor_clinic_appointment_booking_screen.dart';

class ViewClinicProfileScreen extends StatefulWidget {
  final Clinic? clinic;
  final String? clinicId;

  const ViewClinicProfileScreen(
      {Key? key, required this.clinic, required this.clinicId})
      : super(key: key);

  @override
  _ViewClinicProfileScreenState createState() =>
      _ViewClinicProfileScreenState();
}

class _ViewClinicProfileScreenState extends State<ViewClinicProfileScreen> {
  BuildContext? dialogContext;
  List<Color> primaryGradientColors = AppColors.primaryGradientColors;
  Color primaryColor = AppColors.primaryColor;
  Color secondaryColor2 = AppColors.secondaryColor2;
  late final AppData _appData;
  String? _accountType = AccountTypes.Doctor.name, _userId;
  late final FirebaseFirestore _firebaseFirestore;
  Doctor? _doctor;
  Speciality? _clinicSpeciality;
  bool isClinicHaveAvailableTimes = false;

  @override
  void initState() {
    _firebaseFirestore = FirebaseFirestore.instance;
    _appData = AppData();
    _appData.getSharedPreferencesInstance().then((pref) {
      setState(() {
        _userId = _appData.getUserId(pref!)!;
        _accountType = _appData.getAccountType(pref)!;
      });
    });
    if (widget.clinic?.doctorUserId != null &&
        widget.clinic!.doctorUserId.toString().trim().isNotEmpty) {
      getClinicDoctor();
    }
    if (widget.clinic?.specialityId != null &&
        widget.clinic!.specialityId.toString().trim().isNotEmpty) {
      getClinicSpeciality();
    }
    checkIfClinicHaveAvailableTimes();
    super.initState();
  }

  void getClinicDoctor() async {
    await _firebaseFirestore
        .collection(FirestoreCollections.Doctors.name)
        .where('userId', isEqualTo: widget.clinic!.doctorUserId)
        .get()
        .then((snapshots) {
      QueryDocumentSnapshot<Map<String, dynamic>> queryDocumentSnapshot =
          snapshots.docs.first;
      if (queryDocumentSnapshot.exists) {
        setState(() {
          _doctor = Doctor.fromJson(queryDocumentSnapshot.data());
        });
      }
    });
  }

  void getClinicSpeciality() async {
    _firebaseFirestore
        .collection(FirestoreCollections.Specialties.name)
        .doc(widget.clinic!.specialityId)
        .get()
        .then((value) {
      setState(() {
        _clinicSpeciality = Speciality.fromJson(value.data());
      });
    });
  }

  void checkIfClinicHaveAvailableTimes() async {
    DocumentReference clinicRef = _firebaseFirestore
        .collection(FirestoreCollections.Clinics.name)
        .doc(widget.clinicId);
    await _firebaseFirestore
        .collectionGroup('ClinicAvailableTimes')
        .orderBy(FieldPath.documentId)
        .startAt([clinicRef.path])
        .endAt(["${clinicRef.path}\uf8ff"])
        .get()
        .then((snapshots) {
          setState(() {
            setState(() {
              isClinicHaveAvailableTimes = (snapshots.size > 0);
            });
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
              title: const Text(
                "بيانات العيادة",
                style: TextStyle(fontSize: 20),
              ),
              // flexibleSpace: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: primaryGradientColors),),),
              // actions: [
              //
              // ],
            ),
            body: Column(
              children: [
                Expanded(
                  child: ClinicProfileWidget(
                    accountType: _accountType,
                    clinic: widget.clinic,
                    doctor: _doctor,
                    clinicSpeciality: _clinicSpeciality,
                  ),
                ),
                Column(
                  children: [
                    Visibility(
                        visible: (_accountType == AccountTypes.Patient.name ||
                                (_accountType == AccountTypes.Doctor.name &&
                                    widget.clinic?.doctorUserId != _userId)) &&
                            !widget.clinic!.isBookingFromClinicOnly &&
                            widget.clinic!.accountStatus == 1,
                        child: TextButton(
                          style: ElevatedButton.styleFrom(
                              primary: AppColors.appPrimaryColor,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20))),
                          onPressed: () => isClinicHaveAvailableTimes
                              ? Navigator.of(mContext).push(MaterialPageRoute(
                                  builder: (context) => _accountType ==
                                          AccountTypes.Patient.name
                                      ? PatientClinicAppointmentBookingScreen(
                                          clinic: widget.clinic,
                                          clinicId: widget.clinicId,
                                          doctor: _doctor,
                                          clinicSpeciality: _clinicSpeciality,
                                        )
                                      : DoctorClinicAppointmentBookingScreen(
                                          clinic: widget.clinic,
                                          clinicId: widget.clinicId,
                                          doctor: _doctor,
                                          clinicSpeciality: _clinicSpeciality,
                                        )))
                              : null,
                          child: Text(
                            isClinicHaveAvailableTimes
                                ? 'إضغط لحجز موعد'
                                : 'لا يوجد مواعيد متاحة',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.white),
                          ),
                        )),
                    Visibility(
                        visible: _accountType == AccountTypes.Admin.name,
                        child: TextButton(
                          style: ElevatedButton.styleFrom(
                              primary: AppColors.appPrimaryColor,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20))),
                          onPressed: () {
                            showDialog<String>(
                                context: mContext,
                                barrierDismissible: false,
                                builder: (BuildContext context) =>
                                    Directionality(
                                        textDirection: ui.TextDirection.rtl,
                                        child: AlertDialog(
                                          title: const Text(
                                            'تحديث طريقة الحجز',
                                            style:
                                                TextStyle(color: Colors.black),
                                            textDirection: ui.TextDirection.rtl,
                                          ),
                                          content: Text(
                                              'هل متأكد من تحديث طريقة الحجز إلى  ${_getBookingWayText()} ؟',
                                              style: const TextStyle(
                                                  color: Colors.black),
                                              textDirection:
                                                  ui.TextDirection.rtl),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () => Navigator.pop(
                                                  context, 'Cancel'),
                                              child: const Text('إلغاء'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context, 'Ok');
                                                _updateClinicBookingWayInFirestoreDB(
                                                    mContext,
                                                    dialog,
                                                    !widget.clinic!
                                                        .isBookingFromClinicOnly);
                                              },
                                              child: const Text('نعم'),
                                            ),
                                          ],
                                        )));
                          },
                          child: Text(
                            _getBookingWayText(),
                            style: const TextStyle(
                                fontSize: 16, color: Colors.white),
                          ),
                        ))
                  ],
                ),
                const SizedBox(
                  height: 10,
                )
              ],
            )));
  }

  _updateClinicBookingWayInFirestoreDB(
      context, LoadingIndicator dialog, bool newBookingWay) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          dialogContext = context;
          return dialog;
        });
    await _firebaseFirestore
        .doc('${FirestoreCollections.Clinics.name}/${widget.clinicId}')
        .update({'isBookingFromClinicOnly': newBookingWay}).then((value) async {
      Fluttertoast.showToast(msg: 'تم التحديث بنجاح!');
      Navigator.pop(dialogContext!);
      Navigator.pop(context);
    }).catchError((error) {
      Fluttertoast.showToast(msg: 'حدث خطأ ما!');
    });
  }

  String _getBookingWayText() => widget.clinic!.isBookingFromClinicOnly
      ? 'الحجز من خلال التطبيق'
      : 'الحجز من خلال العيادة';
}

import 'dart:convert';
import 'dart:ui' as ui;

import 'package:clinico/constants/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../constants/account_constants.dart';
import '../../helper/shared_preferences.dart';
import '../../model/Payment Models/constants.dart';
import '../../model/Payment Models/track_payment.dart';
import '../../model/booking_request.dart';
import '../../model/clinic.dart';
import '../../model/doctor.dart';
import '../../model/speciality.dart';
import '../../model/user_data.dart';
import '../components/alert.dart';
import 'CallPage.dart';
import 'package:http/http.dart' as http;

class ViewAppointmentDetailsScreen extends StatefulWidget {
  final BookingRequest bookingRequest;
  final String bookingRequestDocumentPath, bookingRequestDocumentId;

  const ViewAppointmentDetailsScreen(
      {Key? key,
      required this.bookingRequest,
      required this.bookingRequestDocumentPath,
      required this.bookingRequestDocumentId})
      : super(key: key);

  @override
  _ViewAppointmentDetailsScreenState createState() =>
      _ViewAppointmentDetailsScreenState();
}

class _ViewAppointmentDetailsScreenState
    extends State<ViewAppointmentDetailsScreen> {
  BuildContext? dialogContext;
  List<Color> primaryGradientColors = AppColors.primaryGradientColors;
  Color primaryLightColor = AppColors.primaryColor;
  Color secondaryColor2 = AppColors.secondaryColor2;
  Color secondaryColor4 = AppColors.secondaryColor4;
  late final AppData _appData;
  String? _accountType = AccountTypes.Admin.name, _userId;
  final DateFormat timeFormat =
      DateFormat('EEEE  yyyy/MM/dd - hh:mm a', 'ar_KSA');
  final List<String> _accountTypes = AccountConstants.accountTypes,
      _genderTypes = AccountConstants.genderTypes,
      _clinicPaymentWays = AccountConstants.clinicPaymentWays,
      _clinicRevealWays = AccountConstants.clinicRevealWays,
      _appointmentStatus = AccountConstants.appointmentStatus;
  late final FirebaseFirestore _firebaseFirestore;
  Clinic? _clinic;
  Doctor? _doctor;
  Speciality? _clinicSpeciality;

  @override
  void initState() {
    _appData = AppData();
    _appData.getSharedPreferencesInstance().then((pref) {
      setState(() {
        _userId = _appData.getUserId(pref!)!;
        _accountType = _appData.getAccountType(pref)!;
      });
    });
    _firebaseFirestore = FirebaseFirestore.instance;
    fetchClinicInfo();
    fetchDoctorInfo();
    super.initState();
  }


  void fetchClinicInfo() async {
    await _firebaseFirestore
        .collection(FirestoreCollections.Clinics.name)
        .doc(widget.bookingRequest.clinicId)
        .get()
        .then((value) => {
              setState(() {
                _clinic = Clinic.fromJson(value.data());
              }),
              fetchClinicSpecialityInfo()
            });
  }

  void fetchClinicSpecialityInfo() {
    _firebaseFirestore
        .collection(FirestoreCollections.Specialties.name)
        .doc(_clinic!.specialityId)
        .get()
        .then((value) {
      setState(() {
        _clinicSpeciality = Speciality.fromJson(value.data());
      });
    });
  }

  void fetchDoctorInfo() {
    _firebaseFirestore
        .collection(FirestoreCollections.Doctors.name)
        .where('userId', isEqualTo: widget.bookingRequest.doctorUserId)
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

  @override
  Widget build(BuildContext mContext) {
    LoadingIndicator dialog = loadingIndicatorWidget();
    return Directionality(
        textDirection: ui.TextDirection.rtl,
        child: Scaffold(
            appBar: AppBar(
              title: const Text('تفاصيل الحجز',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: primaryGradientColors),
                ),
              ),
              actions: [
                Visibility(
                    visible: widget.bookingRequest.isCallJoinEnable(
                        _accountType == AccountTypes.Admin.name),
                    child: TextButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.white),
                      ),
                      onPressed: onJoinCall,
                      child: const Text(
                        'إبدأ الكشف',
                        style: TextStyle(
                            fontSize: 14,
                            color: AppColors.secondaryColor4,
                            fontWeight: FontWeight.bold),
                      ),
                    ))
              ],
            ),
            body: _buildAppointmentDetailsWidget(mContext, dialog)));
  }

  Future<void> onJoinCall() async {
    bool cameraPermissionIsGranted =
        await _handleCameraAndMic(Permission.camera);
    bool microphonePermissionIsGranted =
        await _handleCameraAndMic(Permission.microphone);
    if (!cameraPermissionIsGranted || !microphonePermissionIsGranted) return;
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            CallPage(channelName: widget.bookingRequestDocumentId)));
  }

  Future<bool> _handleCameraAndMic(Permission permission) async {
    final status = await permission.request();
    return status == PermissionStatus.granted;
  }

  _buildAppointmentDetailsWidget(
      BuildContext mContext, LoadingIndicator dialog) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: ListView(
        children: [
          _buildDetailsHeaderWidget('بيانات المريض', FontAwesomeIcons.hospitalUser),
          _buildHeaderDivider(),
          _buildDetailsWidget(
              _buildDetailsTitleWidget('الإسم:'),
              _buildDetailsSubtitleWidget(
                  widget.bookingRequest.patientName ?? '', null)),
          _buildDetailsWidget(
              _buildDetailsTitleWidget('الصفة:'),
              _buildDetailsSubtitleWidget(
                  _accountTypes[widget.bookingRequest.accountType], null)),
          _buildDetailsWidget(
              _buildDetailsTitleWidget('النوع:'),
              _buildDetailsSubtitleWidget(
                  _genderTypes[widget.bookingRequest.patientGender], null)),
          _buildDetailsWidget(
              _buildDetailsTitleWidget('السن:'),
              _buildDetailsSubtitleWidget(
                  _getAgeText(widget.bookingRequest.patientAge), null)),
          _buildDetailsWidget(
              _buildDetailsTitleWidget('الأعراض:'),
              _buildDetailsSubtitleWidget(
                  widget.bookingRequest.symptoms ?? '', null)),
          _buildDetailsHeaderWidget(
              'بيانات العيادة', FontAwesomeIcons.houseChimneyMedical),
          _buildHeaderDivider(),
          if (_clinic?.name != null)
            _buildDetailsWidget(_buildDetailsTitleWidget('الإسم:'),
                _buildDetailsSubtitleWidget(_clinic?.name ?? '', null)),
          if (_clinicSpeciality?.arabicTitle != null)
            _buildDetailsWidget(
                _buildDetailsTitleWidget('التخصص:'),
                _buildDetailsSubtitleWidget(
                    _clinicSpeciality?.arabicTitle ?? '', null)),
          if (_clinic?.address != null)
            _buildDetailsWidget(_buildDetailsTitleWidget('العنوان:'),
                _buildDetailsSubtitleWidget(_clinic?.address ?? '', null)),
          _buildDetailsHeaderWidget(
              'بيانات الطبيب', FontAwesomeIcons.userDoctor),
          _buildHeaderDivider(),
          if (_doctor?.name != null)
            _buildDetailsWidget(_buildDetailsTitleWidget('الإسم:'),
                _buildDetailsSubtitleWidget(_doctor?.name ?? '', null)),
          if (_doctor?.doctorLevel != null)
            _buildDetailsWidget(_buildDetailsTitleWidget('المستوى:'),
                _buildDetailsSubtitleWidget(_doctor?.doctorLevel ?? '', null)),
          _buildDetailsHeaderWidget(
              'تفاصيل الحجز', FontAwesomeIcons.calendarDay),
          _buildHeaderDivider(),
          _buildDetailsWidget(
              _buildDetailsTitleWidget('التوقيت:'),
              _buildDetailsSubtitleWidget(
                  timeFormat.format(widget.bookingRequest.date!.toDate()),
                  null)),
          _buildDetailsWidget(
              _buildDetailsTitleWidget('مدة الكشف:'),
              _buildDetailsSubtitleWidget(
                  '${widget.bookingRequest.durationInMinutes} ${widget.bookingRequest.minuteText}',
                  null)),
          _buildDetailsWidget(
              _buildDetailsTitleWidget('طريقة الكشف:'),
              _buildDetailsSubtitleWidget(
                  _clinicRevealWays[widget.bookingRequest.revealWay], null)),
          _buildDetailsWidget(
              _buildDetailsTitleWidget('حالة الكشف:'),
              _buildDetailsSubtitleWidget(
                  _appointmentStatus[widget.bookingRequest.isBookingExpired
                      ? 4
                      : widget.bookingRequest.appointmentStatus],
                  getAppointmentStatusColor(
                      widget.bookingRequest.isBookingExpired
                          ? 4
                          : widget.bookingRequest.appointmentStatus))),
          _buildDetailsWidget(
              _buildDetailsTitleWidget('سعر الكشف:'),
              _buildDetailsSubtitleWidget(
                  '${getFinalPrice(widget.bookingRequest.price)} ${AccountConstants.getPriceCurrencyByCountry(widget.bookingRequest.country!)}',
                  null)),
          _buildDetailsWidget(
              _buildDetailsTitleWidget('طريقة الدفع:'),
              _buildDetailsSubtitleWidget(
                  _clinicPaymentWays[widget.bookingRequest.paymentWay], null)),
          _buildDetailsWidget(
              _buildDetailsTitleWidget('حالة الدفع:'),
              _buildDetailsSubtitleWidget(
                   widget.bookingRequest.pending == "true" ? 'لم يتم الدفع، الطلب معلق' : widget.bookingRequest.success == "true"? "تم الدفع" : 'لم يتم بعد',
                  null)),
          Visibility(
            visible: ((_accountType == AccountTypes.Patient.name ||
                    (_accountType == AccountTypes.Doctor.name &&
                        _clinic?.doctorUserId != _userId)) &&
                widget.bookingRequest.appointmentStatus == 0 &&
                !widget.bookingRequest.isBookingExpired),
            child: TextButton(
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(secondaryColor4),
              ),
              onPressed: () => showDialog<String>(
                  context: mContext,
                  barrierDismissible: false,
                  builder: (BuildContext context) => Directionality(
                      textDirection: ui.TextDirection.rtl,
                      child: AlertDialog(
                        title: const Text(
                          'إلغاء الحجز',
                          style: TextStyle(color: Colors.black),
                          textDirection: ui.TextDirection.rtl,
                        ),
                        content: const Text('هل متأكد من إلغاء الحجز ؟',
                            style: TextStyle(color: Colors.black),
                            textDirection: ui.TextDirection.rtl),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.pop(context, 'Cancel'),
                            child: const Text('لا'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context, 'Ok');
                              _updateAppointmentStatus(mContext, dialog, 3);
                            },
                            child: const Text('نعم'),
                          ),
                        ],
                      ))),
              child: const Text(
                'إلغاء الحجز',
                style: TextStyle(fontSize: 15, color: Colors.white),
              ),
            ),
          ),
          Visibility(
              visible: (_accountType == AccountTypes.Doctor.name &&
                  _clinic?.doctorUserId == _userId &&
                  widget.bookingRequest.appointmentStatus == 0),
              child: Row(
                children: [
                  Expanded(
                      child: TextButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(primaryLightColor),
                    ),
                    onPressed: () => showDialog<String>(
                        context: mContext,
                        barrierDismissible: false,
                        builder: (BuildContext context) => Directionality(
                            textDirection: ui.TextDirection.rtl,
                            child: AlertDialog(
                              title: const Text(
                                'تحديث حالة الكشف',
                                style: TextStyle(color: Colors.black),
                                textDirection: ui.TextDirection.rtl,
                              ),
                              content: const Text(
                                  'هل متأكد من تحديث حالة الكشف إلى "تم الكشف" ؟',
                                  style: TextStyle(color: Colors.black),
                                  textDirection: ui.TextDirection.rtl),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, 'Cancel'),
                                  child: const Text('لا'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context, 'Ok');
                                    _updateAppointmentStatus(
                                        mContext, dialog, 1);
                                  },
                                  child: const Text('نعم'),
                                ),
                              ],
                            ))),
                    child: const Text(
                      'تم الكشف',
                      style: TextStyle(fontSize: 15, color: Colors.white),
                    ),
                  )),
                  const SizedBox(width: 20),
                  Expanded(
                      child: Visibility(
                    visible: !widget.bookingRequest.isBookingExpired,
                    child: TextButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(secondaryColor4),
                      ),
                      onPressed: () => showDialog<String>(
                          context: mContext,
                          barrierDismissible: false,
                          builder: (BuildContext context) => Directionality(
                              textDirection: ui.TextDirection.rtl,
                              child: AlertDialog(
                                title: const Text(
                                  'إلغاء الحجز',
                                  style: TextStyle(color: Colors.black),
                                  textDirection: ui.TextDirection.rtl,
                                ),
                                content: const Text('هل متأكد من إلغاء الحجز ؟',
                                    style: TextStyle(color: Colors.black),
                                    textDirection: ui.TextDirection.rtl),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, 'Cancel'),
                                    child: const Text('لا'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context, 'Ok');
                                      _updateAppointmentStatus(
                                          mContext, dialog, 2);
                                    },
                                    child: const Text('نعم'),
                                  ),
                                ],
                              ))),
                      child: const Text(
                        'إلغاء الحجز',
                        style: TextStyle(fontSize: 15, color: Colors.white),
                      ),
                    ),
                  ))
                ],
              )),
        ],
      ),
    );
  }

  _buildDetailsHeaderWidget(String titleText, IconData leadingIcon) => ListTile(
      title: Text(
        titleText,
        style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: secondaryColor2),
      ),
      leading: SizedBox(
        height: double.infinity,
        child: Icon(leadingIcon, color: secondaryColor2, size: 20),
      ));

  _buildHeaderDivider() => Divider(color: secondaryColor2);

  _buildDetailsTitleWidget(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      );

  _buildDetailsSubtitleWidget(String text, Color? textColor) => Text(
        text,
        style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: textColor ?? primaryLightColor),
      );

  _buildDetailsWidget(Widget titleText, Widget subTitleText) => Card(
      color: Colors.white,
      child: Padding(
          padding: const EdgeInsets.all(5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(flex: 1, child: titleText),
              Expanded(flex: 2, child: subTitleText)
            ],
          )));

  String _getAgeText(int patientAge) {
    if (patientAge == 0) {
      return 'أقل من سنة';
    } else if (patientAge == 1) {
      return 'سنة واحدة';
    } else if (patientAge == 2) {
      return 'سنتان';
    } else if (patientAge >= 3 && patientAge <= 10) {
      return '$patientAge سنوات';
    } else {
      return '$patientAge سنة';
    }
  }

  String getFinalPrice(int price) =>
      widget.bookingRequest.paymentWay != _clinicPaymentWays.length - 1
          ? AccountConstants.getPriceWithOffer(price)
          : price.toString();

  _updateAppointmentStatus(
      mContext, LoadingIndicator dialog, int newStatus) async {
    showDialog(
        context: mContext,
        barrierDismissible: false,
        builder: (context) {
          dialogContext = context;
          return dialog;
        });
    await _firebaseFirestore
        .doc(widget.bookingRequestDocumentPath)
        .update({'appointmentStatus': newStatus}).then((value) {
      Fluttertoast.showToast(msg: 'تم بنجاح!');
      Navigator.pop(dialogContext!);
      Navigator.pop(mContext);
    }).catchError((error) {
      Fluttertoast.showToast(msg: 'حدث خطأ ما!');
    });
  }

  Color getAppointmentStatusColor(int appointmentStatus) {
    switch (appointmentStatus) {
      case 0:
        return AppColors.secondaryColor2;
        break;
      case 1:
        return AppColors.secondaryColor3;
        break;
      case 4:
        return AppColors.secondaryColor5;
        break;
      default:
        return AppColors.secondaryColor4;
        break;
    }
  }
}

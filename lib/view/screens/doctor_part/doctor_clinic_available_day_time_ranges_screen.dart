import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';

import '../../../constants/app_colors.dart';
import '../../../model/clinic.dart';
import '../../../model/clinic_available_time_range.dart';
import '../../../model/user_data.dart';
import '../../../model/week_day.dart';
import '../../components/alert.dart';
import 'clinic_available_day_time_range_data_screen.dart';

class DoctorClinicAvailableDayTimeRangesScreen extends StatefulWidget {
  String? clinicDocumentPath, clinicId;
  Clinic? clinic;
  WeekDay weekDay;

  DoctorClinicAvailableDayTimeRangesScreen(
      {Key? key,
      required this.clinicDocumentPath,
      required this.clinic,
      required this.weekDay,
      required this.clinicId})
      : super(key: key);

  @override
  _DoctorClinicAvailableDayTimeRangesScreenState createState() =>
      _DoctorClinicAvailableDayTimeRangesScreenState();
}

class _DoctorClinicAvailableDayTimeRangesScreenState
    extends State<DoctorClinicAvailableDayTimeRangesScreen> {
  BuildContext? dialogContext;
  Color primaryLightColor = AppColors.primaryColor;
  Color color3 = AppColors.secondaryColor4;
  List<Color> primaryGradientColors = AppColors.primaryGradientColors;
  final DateFormat timeFormat = DateFormat('hh:mm a', 'ar_KSA');
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  DocumentReference? _clinicAvailableDaysDocumentReference;
  CollectionReference? _clinicAvailableTimesCollectionReference;
  Query<Object?>? _availableDayTimesQuery;
  final List<ClinicAvailableTimeRange> _clinicAvailableTimeRanges =
      <ClinicAvailableTimeRange>[];
  String? _dayNameInThreeDigit;

  @override
  void initState() {
    _dayNameInThreeDigit = widget.weekDay.dayNameEnglish.substring(0, 3);
    _clinicAvailableDaysDocumentReference = _firebaseFirestore.doc(
        '${widget.clinicDocumentPath}/${FirestoreCollections.ClinicAvailableDays.name}/$_dayNameInThreeDigit');
    _clinicAvailableTimesCollectionReference =
        _clinicAvailableDaysDocumentReference
            ?.collection(FirestoreCollections.ClinicAvailableTimes.name);
    _availableDayTimesQuery = _clinicAvailableTimesCollectionReference
        ?.orderBy('startAt', descending: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    LoadingIndicator dialog = loadingIndicatorWidget();
    return Directionality(
        textDirection: ui.TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: Text('مواعيد عمل يوم ${widget.weekDay.dayNameArabic ?? ''}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: primaryGradientColors),
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ClinicAvailableDayTimeRangeDataScreen(
                        clinicAvailableDaysDocumentReference:
                            _clinicAvailableDaysDocumentReference!,
                        clinicAvailableTimeRanges: _clinicAvailableTimeRanges,
                        weekDay: widget.weekDay,
                        dayNameInThreeDigit: _dayNameInThreeDigit!,
                      ))),
              //_addNewAvailableTime(context, dialog),
              backgroundColor: Colors.white,
              child: Icon(
                Icons.add,
                color: primaryLightColor,
              )),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          body: Column(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  color: primaryLightColor,
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Text(
                      'تنبيه: الرجاء تحديد فترات عمل العيادة تصاعديا، علماً بأن بينَ كل فترة والأخرى ١٠ دقائق على الأقل.',
                      style: TextStyle(
                          color: AppColors.secondaryColor2,
                          fontWeight: FontWeight.w700,
                          fontSize: 15),
                    ),
                  ),
                ),
              ),
              Expanded(flex: 9, child: getDayTimeList(dialog))
            ],
          ),
        ));
  }

  Widget getDayTimeList(LoadingIndicator dialog) => StreamBuilder(
      stream: _availableDayTimesQuery?.snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          List<QueryDocumentSnapshot> docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return Center(
                child: Text(
              'لا يوجد فترات عمل متاحة لهذا اليوم!',
              style: TextStyle(color: primaryLightColor),
            ));
          }
          Map map = (docs).asMap();
          _clinicAvailableTimeRanges.clear();
          map.forEach((dynamic, json) => _clinicAvailableTimeRanges
              .add(ClinicAvailableTimeRange.fromJson(json)));
          return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, i) {
                return Directionality(
                    textDirection: ui.TextDirection.rtl,
                    child: _buildDayTimeWidget(
                        _clinicAvailableTimeRanges[i], docs[i], dialog));
              });
        }
        if (snapshot.hasError) {
          return const Center(
              child: Text(
            'عفواً، حدث خطأ ما!',
            style: TextStyle(color: Colors.red),
          ));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        return const Center(
            child: Text(
          'عفواً، حدث خطأ ما!',
          style: TextStyle(color: Colors.red),
        ));
      });

  _buildDayTimeWidget(
    ClinicAvailableTimeRange clinicAvailableTimeRange,
    QueryDocumentSnapshot<Object?> clinicAvailableTimeRangeDoc,
    LoadingIndicator dialog,
  ) {
    return Card(
      color: primaryLightColor,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: InkWell(
          child: ListTile(
            title: Text(
              getTimeRangeText(clinicAvailableTimeRange),
              style: const TextStyle(fontSize: 20, color: Colors.white),
            ),
            trailing: SizedBox(
                height: double.infinity,
                child: InkWell(
                    child: const Icon(FontAwesomeIcons.calendarXmark,
                        color: Colors.white, size: 20),
                    onTap: () => showDialog<String>(
                          context: context,
                          builder: (BuildContext confirmationDialogContext) =>
                              AlertDialog(
                            title: const Text(
                              'حذف الفترة',
                              style: TextStyle(color: Colors.black),
                              textDirection: ui.TextDirection.rtl,
                            ),
                            content: const Text(
                                'هل متأكد من حذف هذه الفترة، علماً بأنه قد يكون هناك مواعيد محجوزة خلال هذه الفترة ؟',
                                style: TextStyle(color: Colors.black),
                                textDirection: ui.TextDirection.rtl),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, 'Cancel'),
                                child: const Text(
                                  'إلغاء',
                                  style:
                                      TextStyle(color: AppColors.primaryColor),
                                ),
                              ),
                              TextButton(
                                onPressed: () => _deleteTime(
                                    clinicAvailableTimeRange,
                                    clinicAvailableTimeRangeDoc,
                                    dialog,
                                    confirmationDialogContext),
                                child: const Text(
                                  'نعم',
                                  style:
                                      TextStyle(color: AppColors.primaryColor),
                                ),
                              ),
                            ],
                          ),
                        ))),
          ),
        ),
      ),
    );
  }

  String getTimeRangeText(ClinicAvailableTimeRange clinicAvailableTimeRange) =>
      'من ${timeFormat.format(clinicAvailableTimeRange.startAt!.toDate())} _ إلى ${timeFormat.format(clinicAvailableTimeRange.endAt!.toDate())} \nكل ${clinicAvailableTimeRange.duration} ${getMinuteText(clinicAvailableTimeRange.duration!)}';

  getMinuteText(int duration) => (duration < 11) ? 'دقائق' : 'دقيقة';

  _deleteTime(
      ClinicAvailableTimeRange clinicAvailableTime,
      QueryDocumentSnapshot<Object?> clinicAvailableTimeRangeDoc,
      LoadingIndicator dialog,
      BuildContext confirmationDialogContext) {
    Navigator.pop(confirmationDialogContext);
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          dialogContext = context;
          return dialog;
        });
    _firebaseFirestore
        .doc(clinicAvailableTimeRangeDoc.reference.path)
        .delete()
        .then((value) => {
              _firebaseFirestore
                  .collection(FirestoreCollections.ClinicBookingRequests.name)
                  .where('timeRangeDocumentId',
                      isEqualTo: clinicAvailableTimeRangeDoc.reference.id)
                  .where('appointmentStatus', isEqualTo: 0)
                  .where('date',
                      isGreaterThanOrEqualTo:
                          Timestamp.fromDate(DateTime.now()))
                  .get()
                  .then((snapshot) {
                for (DocumentSnapshot ds in snapshot.docs) {
                  ds.reference.update({'appointmentStatus': 2});
                }
                Fluttertoast.showToast(msg: 'تم حذف الفترة بنجاح!');
                Navigator.pop(dialogContext!);
                Navigator.pop(context);
              }).catchError((error) {
                Fluttertoast.showToast(msg: 'حدث خطأ ما!');
              })
            })
        .catchError((error) {
      Fluttertoast.showToast(msg: 'حدث خطأ ما!');
    });
  }
}

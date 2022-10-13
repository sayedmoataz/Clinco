import 'dart:ui' as ui;

import 'package:clinico/constants/app_colors.dart';
import 'package:clinico/constants/utils.dart';
import 'package:clinico/model/Payment%20Models/cubit.dart';
import 'package:clinico/model/Payment%20Models/states.dart';
import 'package:clinico/model/booking_request.dart';
import 'package:clinico/model/patient.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:date_picker_timeline/extra/dimen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../constants/account_constants.dart';
import '../../../helper/shared_preferences.dart';
import '../../../helper/time_helper.dart';
import '../../../model/Payment Models/constants.dart';
import '../../../model/clinic.dart';
import '../../../model/clinic_available_day_range.dart';
import '../../../model/clinic_available_time_range.dart';
import '../../../model/clinic_available_time_range_with_document_id.dart';
import '../../../model/clinic_available_time_slot.dart';
import '../../../model/doctor.dart';
import '../../../model/speciality.dart';
import '../../../model/user_data.dart';
import '../../components/alert.dart';

class PatientClinicAppointmentBookingScreen extends StatefulWidget {
  final Clinic? clinic;
  final String? clinicId;
  final Doctor? doctor;
  final Speciality? clinicSpeciality;

  const PatientClinicAppointmentBookingScreen(
      {Key? key,
      required this.clinic,
      required this.clinicId,
      required this.doctor,
      required this.clinicSpeciality})
      : super(key: key);

  @override
  _PatientClinicAppointmentBookingScreenState createState() =>
      _PatientClinicAppointmentBookingScreenState();
}

class _PatientClinicAppointmentBookingScreenState
    extends State<PatientClinicAppointmentBookingScreen> {
  BuildContext? dialogContext;
  List<Color> primaryGradientColors = AppColors.primaryGradientColors;
  Color primaryColor = AppColors.primaryColor;
  final List<String> _weekDaysInEnglishLanguageStartingByMonday =
          AccountConstants.weekDaysInEnglishLanguageStartingByMonday,
      _genderTypes = AccountConstants.genderTypes,
      _clinicPaymentWays = AccountConstants.clinicPaymentWays,
      _clinicRevealWays = AccountConstants.clinicRevealWays;
  final DateFormat dayFormatArabic = DateFormat('EEEE  yyyy/MM/dd', 'ar_KSA'),
      timeFormat = DateFormat('hh:mm a', 'ar_KSA');
  bool includesOnlinePaymentOffer = false;
  String _symptoms = '', offerPrice = '';
  String? _patientId, _patientUserId;
  late final AppData _appData;
  int _activeCurrentStep = 0,
      revealSelectedWayIndex = 1,
      genderSelectedValue = 0;
  int? _age;
  DateTime? _selectedDay;
  final DatePickerController _controller = DatePickerController();
  TimeHelper? timeHelper;
  Set<DateTime> weekDates = {};
  List<ClinicAvailableTimeSlot> timeSlotList = [];
  ClinicAvailableTimeSlot? _selectedTimeSlot;
  DateTime currentDate = DateTime.now();
  Set<DateTime>? availableDates;
  List<ClinicAvailableDayRange> clinicAvailableDayRanges =
      <ClinicAvailableDayRange>[];
  List<BookingRequest> clinicBookingRequest = <BookingRequest>[];
  List<QueryDocumentSnapshot> clinicBookingRequestDocs =
      <QueryDocumentSnapshot>[];
  late CollectionReference clinicBookingRequestsRef;
  final GlobalKey<FormState> _symptomsStepFormKeys = GlobalKey<FormState>();
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  Patient? _patient;

  @override
  void initState() {
    super.initState();
    clinicBookingRequestsRef = _firebaseFirestore.collection(FirestoreCollections.ClinicBookingRequests.name);
    includesOnlinePaymentOffer = widget.clinic?.paymentWay != _clinicPaymentWays.length - 1;
    if (includesOnlinePaymentOffer)
      offerPrice = AccountConstants.getPriceWithOffer(widget.clinic!.price);

    timeHelper = TimeHelper();
    getAvailableTimes();
    _appData = AppData();
    _appData.getSharedPreferencesInstance().then((pref) {
      _patientUserId = _appData.getUserId(pref!)!;
      _getPatientData();
    });
  }

  void getAvailableTimes() async {
    DocumentReference clinicRef = _firebaseFirestore.collection(FirestoreCollections.Clinics.name).doc(widget.clinicId);
    await _firebaseFirestore
        .collectionGroup('ClinicAvailableTimes')
        .orderBy(FieldPath.documentId)
        .startAt([clinicRef.path])
        .endAt(["${clinicRef.path}\uf8ff"])
        .get()
        .then((snapshots) {
          setState(() {
            List<QueryDocumentSnapshot<Map<String, dynamic>>>
                queryDocumentSnapshotsAllClinicAvailableTimes = snapshots.docs;
            for (QueryDocumentSnapshot<Map<String, dynamic>> doc
                in queryDocumentSnapshotsAllClinicAvailableTimes) {
              DocumentReference documentReference = doc.reference;
              String dayId = documentReference.parent.parent!.id;
              final bool isListContainThisDay =
                  clinicAvailableDayRanges.any((day) => day.dayName == dayId);
              if (!isListContainThisDay) {
                clinicAvailableDayRanges.add(ClinicAvailableDayRange(
                    _weekDaysInEnglishLanguageStartingByMonday.indexOf(dayId) +
                        1,
                    dayId,
                    {}));
              }
              clinicAvailableDayRanges
                  .firstWhere((element) => element.dayName == dayId)
                  .clinicAvailableTimeRangeWithDocumentId
                  ?.add(ClinicAvailableTimeRangeWithDocumentId(
                      ClinicAvailableTimeRange.fromJson(doc),
                      doc.reference.id));
            }
            declareWeekDays();
            getActivatedDays();
          });
        });
  }

  void declareWeekDays() {
    weekDates.clear();
    for (var d = 0; d <= 6; d++) {
      weekDates.add(currentDate.add(Duration(days: d)));
    }
  }

  void getActivatedDays() {
    availableDates = {};
    for (DateTime date in weekDates) {
      final bool isActiveDate =
          clinicAvailableDayRanges.any((day) => day.dayNumber == date.weekday);
      if (isActiveDate) {
        setState(() {
          availableDates?.add(date);
        });
      }
    }
  }

  void _getPatientData() {
    _firebaseFirestore
        .collection(FirestoreCollections.Patients.name)
        .where('userId', isEqualTo: _patientUserId)
        .get()
        .then((snapshots) {
      QueryDocumentSnapshot<Map<String, dynamic>> queryDocumentSnapshot =
          snapshots.docs.first;
      if (queryDocumentSnapshot.exists) {
        setState(() {
          _patientId = queryDocumentSnapshot.reference.id;
          _patient = Patient.fromJson(queryDocumentSnapshot.data());
        });
      }
    });
  }

  List<Step> stepList() => [
        Step(
            state: _activeCurrentStep <= 0
                ? StepState.editing
                : StepState.complete,
            isActive: _activeCurrentStep >= 0,
            title: const Text('اليوم'),
            content: Column(
              children: [
                DatePicker(
                  currentDate,
                  width: 60,
                  height: 100,
                  locale: 'ar_KSA',
                  daysCount: 7,
                  controller: _controller,
                  deactivatedColor: AppColors.secondaryColor4,
                  dateTextStyle: TextStyle(
                    color: primaryColor,
                    fontSize: Dimen.dateTextSize,
                    fontWeight: FontWeight.w500,
                  ),
                  monthTextStyle: TextStyle(
                    color: primaryColor,
                    fontSize: Dimen.monthTextSize,
                    fontWeight: FontWeight.w500,
                  ),
                  dayTextStyle: TextStyle(
                    color: primaryColor,
                    fontSize: Dimen.dayTextSize,
                    fontWeight: FontWeight.w500,
                  ),
                  selectionColor: primaryColor,
                  selectedTextColor: Colors.white,
                  activeDates: availableDates?.toList() ?? [],
                  onDateChange: (date) {
                    setState(() {
                      _selectedDay = date;
                      _selectedTimeSlot = null;
                      if (_selectedDay != null) {
                        updateAvailableTimeSlotListOfSelectedDate(
                            _selectedDay!);
                      }
                    });
                  },
                ),
              ],
            )),
        Step(
            state: _activeCurrentStep <= 1
                ? StepState.editing
                : StepState.complete,
            isActive: _activeCurrentStep >= 1,
            title: const Text('التوقيت'),
            content: Column(
              children: [
                StreamBuilder(
                    stream: clinicBookingRequestsRef
                        .where('clinicId', isEqualTo: widget.clinicId)
                        .where('appointmentStatus',
                            whereNotIn: [2, 3]).snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasData) {
                        clinicBookingRequestDocs = snapshot.data!.docs;
                        if (clinicBookingRequestDocs.isEmpty) {
                          return SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.045,
                              child: ListView.builder(
                                  itemCount: timeSlotList.length,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index) {
                                    return _buildAvailableTimeWidget(
                                        timeSlotList.elementAt(index), false);
                                  }));
                        }
                        Map map = (clinicBookingRequestDocs).asMap();
                        clinicBookingRequest.clear();
                        map.forEach((dynamic, json) => clinicBookingRequest
                            .add(BookingRequest.fromJson(json)));
                        return SizedBox(
                            height: MediaQuery.of(context).size.height * 0.045,
                            child: ListView.builder(
                                itemCount: timeSlotList.length,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  final bool isBookedTime = clinicBookingRequest
                                      .any((bookingRequest) =>
                                          bookingRequest.date ==
                                          Timestamp.fromDate(timeSlotList
                                              .elementAt(index)
                                              .timeSlot));
                                  return _buildAvailableTimeWidget(
                                      timeSlotList.elementAt(index),
                                      isBookedTime);
                                }));
                      } else if (snapshot.hasError) {
                        return const Center(
                            child: Text(
                          'عفواً، حدث خطأ ما!',
                          style: TextStyle(color: AppColors.secondaryColor4),
                        ));
                      } else if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return const Center(
                          child: Text(
                        'عفواً، حدث خطأ ما!',
                        style: TextStyle(color: AppColors.secondaryColor4),
                      ));
                    }),
              ],
            )),
        Step(
            state: _activeCurrentStep <= 2
                ? StepState.editing
                : StepState.complete,
            isActive: _activeCurrentStep >= 2,
            title: const Text('الأعراض'),
            content: Form(
              key: _symptomsStepFormKeys,
              child: SingleChildScrollView(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Row(
                            children: const [
                              Expanded(
                                child: Text('النوع'),
                              )
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Row(
                            children: [
                              Radio<int>(
                                value: 0,
                                groupValue: genderSelectedValue,
                                onChanged: (index) {
                                  setState(() {
                                    genderSelectedValue = index!;
                                  });
                                },
                                activeColor: primaryColor,
                              ),
                              Expanded(child: Text(_genderTypes.first))
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Row(
                            children: [
                              Radio<int>(
                                value: 1,
                                groupValue: genderSelectedValue,
                                onChanged: (index) {
                                  setState(() {
                                    genderSelectedValue = index!;
                                  });
                                },
                                activeColor: primaryColor,
                              ),
                              Expanded(child: Text(_genderTypes[1]))
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    TextFormField(
                        enableInteractiveSelection: false,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        initialValue: '${_age ?? ''}',
                        validator: (val) {
                          String text = val.toString().trim();
                          if (text.isEmpty) {
                            return 'السن مطلوب!';
                          } else if (int.parse(text) <= 0 ||
                              int.parse(text) > 200) {
                            return 'السن غير صحيح!';
                          }
                          return null;
                        },
                        maxLines: 1,
                        maxLength: 3,
                        onChanged: (val) => setState(() {
                              _age = int.parse(val.toString().trim());
                            }),
                        onSaved: (val) {
                          _age = int.parse(val.toString().trim());
                        },
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                            labelText: 'السن',
                            prefixIcon: Icon(FontAwesomeIcons.cakeCandles))),
                    const SizedBox(height: 5),
                    TextFormField(
                        enableInteractiveSelection: true,
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.text,
                        initialValue: _symptoms,
                        validator: (val) => null,
                        maxLines: 1,
                        maxLength: 100,
                        onChanged: (val) => setState(() {
                              _symptoms = val.toString().trim();
                            }),
                        onSaved: (val) {
                          _symptoms = val.toString().trim();
                        },
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                            labelText: 'الأعراض (مثل الكحة وما إلى ذلك...)',
                            prefixIcon: Icon(FontAwesomeIcons.hospitalUser))),
                  ])),
            )),
        Step(
            state: _activeCurrentStep <= 3
                ? StepState.editing
                : StepState.complete,
            isActive: _activeCurrentStep >= 3,
            title: const Text('تأكيد البيانات'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (_patient?.name != null)
                  Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Expanded(
                            flex: 1,
                            child: Text(
                              'الإسم:',
                              style: TextStyle(color: Colors.black),
                            )),
                        Expanded(
                            flex: 1,
                            child: Text(
                              _patient!.name!.isNotEmpty
                                  ? _patient!.name!
                                  : '---',
                              style: TextStyle(color: primaryColor),
                            ))
                      ]),
                if (_patient?.phoneNumber != null)
                  Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Expanded(
                            flex: 1,
                            child: Text(
                              'رقم الهاتف:',
                              style: TextStyle(color: Colors.black),
                            )),
                        Expanded(
                            flex: 1,
                            child: Text(
                              _patient!.phoneNumber!.isNotEmpty
                                  ? _patient!.phoneNumber!
                                  : '---',
                              style: TextStyle(color: primaryColor),
                            ))
                      ]),
                if (_patient?.email != null)
                  Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Expanded(
                            flex: 1,
                            child: Text(
                              'البريد الإلكتروني:',
                              style: TextStyle(color: Colors.black),
                            )),
                        Expanded(
                            flex: 1,
                            child: Text(
                              _patient!.email!.isNotEmpty
                                  ? _patient!.email!
                                  : '---',
                              style: TextStyle(color: primaryColor),
                            ))
                      ]),
                if (_selectedTimeSlot != null)
                  Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Expanded(
                            flex: 1,
                            child: Text(
                              'اليوم:',
                              style: TextStyle(color: Colors.black),
                            )),
                        Expanded(
                            flex: 1,
                            child: Text(
                              dayFormatArabic
                                  .format(_selectedTimeSlot!.timeSlot),
                              style: TextStyle(color: primaryColor),
                            ))
                      ]),
                if (_selectedTimeSlot != null)
                  Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Expanded(
                            flex: 1,
                            child: Text(
                              'التوقيت:',
                              style: TextStyle(color: Colors.black),
                            )),
                        Expanded(
                            flex: 1,
                            child: Text(
                              timeFormat.format(_selectedTimeSlot!.timeSlot),
                              style: TextStyle(color: primaryColor),
                            ))
                      ]),
                if (_selectedTimeSlot != null)
                  Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Expanded(
                            flex: 1,
                            child: Text(
                              'مدة الكشف:',
                              style: TextStyle(color: Colors.black),
                            )),
                        Expanded(
                            flex: 1,
                            child: Text(
                              '${_selectedTimeSlot!.durationInMinutes} ${_selectedTimeSlot!.minuteText}',
                              style: TextStyle(color: primaryColor),
                            ))
                      ]),
                Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Expanded(
                          flex: 1,
                          child: Text(
                            'النوع:',
                            style: TextStyle(color: Colors.black),
                          )),
                      Expanded(
                          flex: 1,
                          child: Text(
                            _genderTypes[genderSelectedValue],
                            style: TextStyle(color: primaryColor),
                          ))
                    ]),
                Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Expanded(
                          flex: 1,
                          child: Text(
                            'السن:',
                            style: TextStyle(color: Colors.black),
                          )),
                      Expanded(
                          flex: 1,
                          child: Text(
                            _age.toString(),
                            style: TextStyle(color: primaryColor),
                          ))
                    ]),
                Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Expanded(
                          flex: 1,
                          child: Text(
                            'الأعراض:',
                            style: TextStyle(color: Colors.black),
                          )),
                      Expanded(
                          flex: 1,
                          child: Text(
                            _symptoms.isNotEmpty ? _symptoms : '---',
                            style: TextStyle(color: primaryColor),
                          ))
                    ]),
              ],
            )),
        Step(
            state: _activeCurrentStep <= 4
                ? StepState.editing
                : StepState.complete,
            isActive: _activeCurrentStep >= 4,
            title: const Text('طريقة الكشف'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                widget.clinic?.revealWay == 0
                    ? _buildRevealRadioButtonSelectionWidget()
                    : _buildOneRevealWayWidget()
              ],
            )),
        Step(
            state: _activeCurrentStep <= 5
                ? StepState.editing
                : StepState.complete,
            isActive: _activeCurrentStep >= 5,
            title: const Text('الدفع'),
            content: Container(
                child:
                    widget.clinic?.paymentWay != _clinicPaymentWays.length - 1
                        ? _buildPaymentWaysSelectionWidget()
                        : _buildCashPaymentOnlyWidget()))
      ];

  void updateAvailableTimeSlotListOfSelectedDate(DateTime selectedDay) {
    timeSlotList.clear();
    List<ClinicAvailableTimeRangeWithDocumentId>
        clinicAvailableTimeRangeWithDocumentId = clinicAvailableDayRanges
            .firstWhere((element) => element.dayNumber == selectedDay.weekday)
            .clinicAvailableTimeRangeWithDocumentId!
            .toList();
    for (ClinicAvailableTimeRangeWithDocumentId range
        in clinicAvailableTimeRangeWithDocumentId) {
      ClinicAvailableTimeRange clinicAvailableTimeRange =
          range.clinicAvailableTimeRange;
      List<DateTime> slots = timeHelper!
          .getTimes(
              selectedDay,
              clinicAvailableTimeRange.startAt!,
              clinicAvailableTimeRange.endAt!,
              clinicAvailableTimeRange.duration ?? 10)
          .toList();

      for (DateTime slot in slots) {
        timeSlotList.add(ClinicAvailableTimeSlot(
            slot,
            range.timeRangeDocumentId,
            clinicAvailableTimeRange.duration ?? 10));
      }
    }
    timeSlotList.sort((a, b) => a.timeSlot.compareTo(b.timeSlot));
  }

  @override
  Widget build(BuildContext mContext) {
    LoadingIndicator dialog = loadingIndicatorWidget();
    return BlocConsumer<HomeCubit, HomeStates>(
      listener: (context, states){},
      builder: (context, states){
        var cubit = HomeCubit.get(context);
        return Directionality(
            textDirection: ui.TextDirection.rtl,
            child: Scaffold(
                appBar: AppBar(
                  title: const Text('حجز موعد',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  flexibleSpace: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: primaryGradientColors),
                    ),
                  ),
                ),
                body: Theme(
                    data: ThemeData(
                        primarySwatch: Colors.orange,
                        colorScheme: ColorScheme.light(primary: primaryColor)),
                    child: ListView(
                      children: [
                        _buildClinicInformationCardWidget(),
                        _buildPriceWidget(),
                        _buildAppointmentBookingStepperWidget(),
                        //For testing...
                        TextButton(
                          style: _stepperControlButtonStyle(),
                          onPressed: () => requestBooking(mContext, dialog),
                          child: const Text(
                            'حجـــــز',
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      ],
                    ))));
      },
    );
  }

  _buildClinicInformationCardWidget() {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        height: 80,
        padding: const EdgeInsets.all(4),
        child: Row(children: [
          Expanded(
            flex: 4,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: primaryColor,
                    width: 2,
                  ),
                  image: DecorationImage(
                      image: NetworkImage(widget.clinic?.logo ?? ''),
                      fit: BoxFit.fill)),
            ),
          ),
          const Spacer(
            flex: 1,
          ),
          Expanded(
            flex: 16,
            child: Container(
              padding: const EdgeInsets.only(top: 5, bottom: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                      flex: 6,
                      fit: FlexFit.loose,
                      child: Text(widget.clinic?.name ?? '',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          textDirection: ui.TextDirection.rtl,
                          style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: primaryColor))),
                  const Spacer(
                    flex: 1,
                  ),
                  Flexible(
                      flex: 4,
                      fit: FlexFit.loose,
                      child: Text(widget.clinicSpeciality?.arabicTitle ?? '',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          textDirection: ui.TextDirection.rtl,
                          style: TextStyle(
                              fontSize: 11.0,
                              fontWeight: FontWeight.normal,
                              color: primaryColor))),
                  const Spacer(
                    flex: 1,
                  ),
                  Visibility(
                      visible: widget.doctor?.name != null &&
                          widget.doctor!.name!.toString().isNotEmpty,
                      child: Flexible(
                          flex: 4,
                          fit: FlexFit.loose,
                          child: Text(
                              '${widget.doctor?.doctorLevel ?? ''} | ${widget.doctor?.name ?? ''}  ',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              textDirection: ui.TextDirection.rtl,
                              style: TextStyle(
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.normal,
                                  color: primaryColor)))),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }

  _buildPriceWidget() => Visibility(
      visible: widget.clinic?.price != null &&
          widget.clinic!.price.toString().isNotEmpty,
      child: ListTile(
        leading: SizedBox(
            height: double.infinity,
            child: Icon(
              FontAwesomeIcons.wallet,
              color: primaryColor,
            )),
        title: _buildRevealPriceTitleWidget(),
        subtitle: Text(
          'سعر الكشف',
          style: TextStyle(fontSize: 10, color: primaryColor),
        ),
      ));

  _buildRevealPriceTitleWidget() {
    if (!includesOnlinePaymentOffer) {
      return Text(
        '${widget.clinic?.price} ${AccountConstants.getPriceCurrencyByCountry(widget.clinic!.selectedCountry!)}',
        style: TextStyle(
            fontSize: 11, color: primaryColor, fontWeight: FontWeight.bold),
      );
    } else {
      return Row(
        children: [
          Text(
            '${widget.clinic?.price} ${AccountConstants.getPriceCurrencyByCountry(widget.clinic!.selectedCountry!)}',
            style: const TextStyle(
                fontSize: 9,
                color: AppColors.secondaryColor4,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.lineThrough),
          ),
          const SizedBox(width: 10),
          Text(
            '$offerPrice ${AccountConstants.getPriceCurrencyByCountry(widget.clinic!.selectedCountry!)}  ${'(من خلال التطبيق)'}',
            style: TextStyle(
                fontSize: 11, color: primaryColor, fontWeight: FontWeight.bold),
          ),
        ],
      );
    }
  }

  _buildAppointmentBookingStepperWidget() {
    return Stepper(
      physics: const ClampingScrollPhysics(),
      type: StepperType.vertical,
      currentStep: _activeCurrentStep,
      steps: stepList(),
      controlsBuilder: (context, _) {
        return Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Row(
            children: <Widget>[
              Visibility(
                  visible: _activeCurrentStep > 0,
                  child: TextButton(
                    style: _stepperControlButtonStyle(),
                    onPressed: onStepCancel,
                    child: const Text(
                      'السابق',
                      style: TextStyle(color: Colors.white),
                    ),
                  )),
              const Spacer(),
              Visibility(
                  visible: (_activeCurrentStep < stepList().length - 1 &&
                      !(_activeCurrentStep == 0 && _selectedDay == null) &&
                      !(_activeCurrentStep == 1 && _selectedTimeSlot == null)),
                  child: TextButton(
                    style: _stepperControlButtonStyle(),
                    onPressed: onStepContinue,
                    child: const Text(
                      'التالي',
                      style: TextStyle(color: Colors.white),
                    ),
                  )),
            ],
          ),
        );
      },
    );
  }

  void onStepContinue() {
    if (_activeCurrentStep == 2 &&
        !_symptomsStepFormKeys.currentState!.validate()) return;
    if (_activeCurrentStep < (stepList().length - 1)) {
      setState(() {
        _activeCurrentStep += 1;
      });
    }
  }

  void onStepCancel() {
    if (_activeCurrentStep == 0) {
      return;
    }

    setState(() {
      _activeCurrentStep -= 1;
    });
  }

  _stepperControlButtonStyle() => ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(primaryColor),
      );

  _buildPaymentMethodCardWidget(String title, String subtitle, IconData icon, VoidCallback callback) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: InkWell(
          onTap: callback,
          child: ListTile(
            title: Text(
              title,
              style: TextStyle(
                  fontSize: 14,
                  color: primaryColor,
                  fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              subtitle,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.secondaryColor2),
            ),
            leading: SizedBox(
              height: double.infinity,
              child: Icon(icon, color: primaryColor),
            ),
            trailing: SizedBox(
              height: double.infinity,
              child: Icon(
                Icons.arrow_forward_ios,
                color: primaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void openPaymentLinkUrl(String? paymentLink) async {
    if (paymentLink != null && paymentLink.isNotEmpty) {
      Uri uri = Uri.parse(paymentLink);
      canLaunchUrl(uri).then((value) async {
        if (value) {
          await launchUrl(uri);
        }
      });
    }
  }

  _buildRevealRadioButtonSelectionWidget() {
    return Column(
      children: [
        Row(
          children: [
            Radio<int>(
              value: 1,
              groupValue: revealSelectedWayIndex,
              onChanged: (index) {
                setState(() {
                  revealSelectedWayIndex = index!;
                });
              },
              activeColor: primaryColor,
            ),
            const Expanded(child: Text('أون لاين'))
          ],
        ),
        Row(
          children: [
            Radio<int>(
              value: 2,
              groupValue: revealSelectedWayIndex,
              onChanged: (index) {
                setState(() {
                  revealSelectedWayIndex = index!;
                });
              },
              activeColor: primaryColor,
            ),
            const Expanded(child: Text('العيادة'))
          ],
        ),
      ],
    );
  }

  _buildOneRevealWayWidget() => Text(
      'طريقة الكشف المتاحة هي ${_clinicRevealWays[widget.clinic!.revealWay]}',
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      textDirection: ui.TextDirection.rtl,
      style: TextStyle(
          fontSize: 16.0, fontWeight: FontWeight.bold, color: primaryColor));

  _buildPaymentWaysSelectionWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Visibility(
            visible:
            widget.clinic?.paymentWay == 0 && !((widget.clinic?.revealWay == 0 || widget.clinic?.revealWay == 1) && revealSelectedWayIndex == 1),
            child: _buildPaymentMethodCardWidget('نقدي', 'من خلال العيادة', FontAwesomeIcons.moneyBillWave,(){})
        ),
        HomeCubit.get(context).isLoadingState ? const CircularProgressIndicator()
        : _buildPaymentMethodCardWidget(
          'فوري',
          '+5 جنيه مصاريف فوري',
          FontAwesomeIcons.moneyBillTransfer,
          (){
            price = widget.clinic!.price - widget.clinic!.revealWay;
            if (kDebugMode) {
              print("_patient!.name!.toString() is : ${_patient!.name!.toString()}\n _patient!.name! is : ${_patient!.name!.toString()}\n_patient!.phoneNumber! is : ${_patient!.phoneNumber!.toString()}\n_patient!.email! is : ${_patient!.email!.toString()}\nwidget.clinic!.price is : ${price}\nIntegrationIDKiosk is : ${IntegrationIDKiosk.toString()}");
            }
            HomeCubit.get(context).getAuthToken(
              _patient!.name!.toString(),
              _patient!.name!.toString(),
              _patient!.phoneNumber!.toString(),
              _patient!.email!.toString(),
              priceInCents.toString(),
              IntegrationIDKiosk.toString(),
              true,
              context
            );
          }
        ),
        HomeCubit.get(context).isLoadingState ? const CircularProgressIndicator()
        : _buildPaymentMethodCardWidget(
          'بطاقة ائتمان',
          'فيزا وماستركارد',
          FontAwesomeIcons.ccVisa,
             (){
                price = widget.clinic!.price - widget.clinic!.revealWay;
                if (kDebugMode) {
                  print("_patient!.name!.toString() is : ${_patient!.name!.toString()}\n _patient!.name! is : ${_patient!.name!.toString()}\n_patient!.phoneNumber! is : ${_patient!.phoneNumber!.toString()}\n_patient!.email! is : ${_patient!.email!.toString()}\nwidget.clinic!.price is : ${widget.clinic!.price.toString()}\nIntegrationIDKiosk is : ${IntegrationIDKiosk.toString()}");
                }
                HomeCubit.get(context).getAuthToken(
                  _patient!.name!.toString(),
                  _patient!.name!.toString(),
                  _patient!.phoneNumber!.toString(),
                  _patient!.email!.toString(),
                  priceInCents.toString(),
                  IntegrationIDCard.toString(),
                  false,
                  context
                );

              }
        )
      ],
    );
  }

  _buildCashPaymentOnlyWidget() => Text('طريقة الدفع المتاحة هي نقداً فقط!',
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      textDirection: ui.TextDirection.rtl,
      style: TextStyle(
          fontSize: 16.0, fontWeight: FontWeight.bold, color: primaryColor));

  _buildAvailableTimeWidget(ClinicAvailableTimeSlot clinicAvailableTimeSlot, bool isBookedTime) {
    return Card(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        child: InkWell(
            onTap: () => isBookedTime
                ? null
                : setState(() {
                    _selectedTimeSlot = clinicAvailableTimeSlot;
                  }),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isBookedTime
                    ? AppColors.secondaryColor4
                    : ((clinicAvailableTimeSlot == _selectedTimeSlot)
                        ? primaryColor
                        : Colors.grey),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: Text(
                  timeFormat.format(clinicAvailableTimeSlot.timeSlot),
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            )));
  }

  requestBooking(context, LoadingIndicator dialog) async {
    BookingRequest bookingRequest = BookingRequest(
        widget.clinic!.doctorUserId,
        _patientUserId,
        _patientId,
        widget.clinicId,
        _patient!.name,
        _patient!.phoneNumber,
        _patient?.email,
        _symptoms,
        widget.clinic!.selectedCountry,
        _selectedTimeSlot!.timeRangeDocumentId,
        Timestamp.fromDate(_selectedTimeSlot!.timeSlot),
        0,
        genderSelectedValue,
        _age!,
        revealSelectedWayIndex,
        1,
        widget.clinic!.price,
        0,
        _selectedTimeSlot!.durationInMinutes,
        false,
        success = HomeCubit.get(context).trackTransaction!.success.toString(),
        pending = HomeCubit.get(context).trackTransaction!.pending.toString(),
    );
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          dialogContext = context;
          return dialog;
        });
    await _firebaseFirestore.collection(FirestoreCollections.ClinicBookingRequests.name).doc().set(bookingRequest.toJson()).then((value) {
      Utils.callOnFcmApiSendPushNotificationsWithId(
          userId: _patientUserId!,
          accountType: "Patients",
          notificationTitle: "clinico",
          notificationBody: " تم حجز موعد عند دكتور ${widget.clinic!.name}",
          notificationData: {});
      Utils.callOnFcmApiSendPushNotificationsWithId(
          userId: widget.clinic!.doctorUserId!,
          accountType: "Doctors",
          notificationTitle: "clinico",
          notificationBody: " لديك حجز موعد جديد من ${_patient!.name}",
          notificationData: {});
      Fluttertoast.showToast(msg: 'تم الحجز بنجاح!');
      Navigator.pop(dialogContext!);
      Navigator.pop(context);
    }).catchError((error) {
      Fluttertoast.showToast(msg: 'حدث خطأ ما!');
    });
  }
}

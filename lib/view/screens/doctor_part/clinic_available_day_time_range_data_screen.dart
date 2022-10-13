import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_indicator/loading_indicator.dart';

import '../../../constants/app_colors.dart';
import '../../../helper/time_helper.dart';
import '../../../model/clinic_available_day.dart';
import '../../../model/clinic_available_time_range.dart';
import '../../../model/user_data.dart';
import '../../../model/week_day.dart';
import '../../components/alert.dart';

class ClinicAvailableDayTimeRangeDataScreen extends StatefulWidget {
  DocumentReference clinicAvailableDaysDocumentReference;
  List<ClinicAvailableTimeRange> clinicAvailableTimeRanges;
  WeekDay weekDay;
  String dayNameInThreeDigit;

  ClinicAvailableDayTimeRangeDataScreen(
      {Key? key,
      required this.clinicAvailableDaysDocumentReference,
      required this.clinicAvailableTimeRanges,
      required this.weekDay,
      required this.dayNameInThreeDigit})
      : super(key: key);

  @override
  _ClinicAvailableDayTimeRangeDataScreenState createState() =>
      _ClinicAvailableDayTimeRangeDataScreenState();
}

class _ClinicAvailableDayTimeRangeDataScreenState
    extends State<ClinicAvailableDayTimeRangeDataScreen> {
  BuildContext? dialogContext;
  Color primaryLightColor = AppColors.primaryColor;
  Color color3 = AppColors.secondaryColor4;
  List<Color> primaryGradientColors = AppColors.primaryGradientColors;
  GlobalKey<FormState> formstate = GlobalKey<FormState>();
  int defaultYear = 2022, defaultMonth = 1, defaultDay = 1;
  TimeHelper? timeHelper;
  TimeOfDay? startAt, endAt;
  final int minimumDurationInMinutes = 10;
  int durationInMinutes = 10;

  @override
  void initState() {
    timeHelper = TimeHelper();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    LoadingIndicator dialog = loadingIndicatorWidget();
    return Directionality(
        textDirection: ui.TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
                'إضافة فترة عمل ليوم ${widget.weekDay.dayNameArabic ?? ''}',
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
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
                  await saveTimeRange(context, dialog);
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
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: Row(
                            children: [
                              Text(
                                'من',
                                style: TextStyle(
                                    fontSize: 20, color: primaryLightColor),
                              ),
                              SizedBox(width: size.width * 0.03),
                              TextButton(
                                style: ButtonStyle(
                                    foregroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.white),
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            primaryLightColor)),
                                onPressed: () =>
                                    _selectStartAtTime(context, dialog),
                                child: Text(startAt != null
                                    ? startAt!.format(context)
                                    : 'إختيار الوقت'),
                              ),
                            ],
                          ),
                        ),
                        Visibility(
                            visible: startAt != null,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 30),
                              child: Row(
                                children: [
                                  Text(
                                    'إلى',
                                    style: TextStyle(
                                        fontSize: 20, color: primaryLightColor),
                                  ),
                                  SizedBox(width: size.width * 0.03),
                                  TextButton(
                                    style: ButtonStyle(
                                        foregroundColor:
                                            MaterialStateProperty.all<Color>(
                                                Colors.white),
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                primaryLightColor)),
                                    onPressed: () =>
                                        _selectEndAtTime(context, dialog),
                                    child: Text(endAt != null
                                        ? endAt!.format(context)
                                        : 'إختيار الوقت'),
                                  ),
                                ],
                              ),
                            )),
                        TextFormField(
                            enableInteractiveSelection: false,
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            initialValue: durationInMinutes.toString(),
                            validator: (val) {
                              String text = val.toString().trim();
                              if (text.isEmpty) {
                                return 'مدة الكشف مطلوبة!';
                              }
                              if (int.parse(text) < minimumDurationInMinutes) {
                                return 'أقل مدة للكشف هي ١٠ دقائق!';
                              }
                              if (int.parse(text) > 120) {
                                return 'أكبر مدة للكشف هي ساعتان!';
                              }
                              return null;
                            },
                            maxLength: 3,
                            onSaved: (val) {
                              durationInMinutes =
                                  int.parse(val.toString().trim());
                            },
                            decoration: const InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: 'مدة كل كشف بالدقائق',
                                prefixIcon: Icon(FontAwesomeIcons.stopwatch))),
                      ]))
                ],
              )),
        ));
  }

  Future<void> _selectStartAtTime(
      BuildContext context, LoadingIndicator dialog) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      if (widget.clinicAvailableTimeRanges.isEmpty) {
        setState(() {
          startAt = pickedTime;
          endAt = null;
        });
      } else {
        Timestamp? endAtTimestampOfPreviousRange =
            widget.clinicAvailableTimeRanges.last.endAt;
        if (endAtTimestampOfPreviousRange != null) {
          DateTime endAtDateTimeOfPreviousRange =
              endAtTimestampOfPreviousRange.toDate();
          TimeOfDay endAtTimeOfDayOfPreviousRange = TimeOfDay(
              hour: endAtDateTimeOfPreviousRange.hour,
              minute: endAtDateTimeOfPreviousRange.minute);
          int diffInMinutes = timeHelper!.differenceBetweenTwoTimeOfDays(
              endAtTimeOfDayOfPreviousRange, pickedTime);
          if (diffInMinutes < minimumDurationInMinutes) {
            Fluttertoast.showToast(
                msg:
                    'يجب أن تبدأ هذه الفترة بعد ١٠ دقائق على الأقل من نهاية الفترة السابقة!',
                toastLength: Toast.LENGTH_LONG,
                backgroundColor: color3);
            return;
          } else {
            setState(() {
              startAt = pickedTime;
              endAt = null;
            });
          }
        }
      }
    }
  }

  Future<void> _selectEndAtTime(
      BuildContext context, LoadingIndicator dialog) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: endAt ?? startAt!,
    );
    if (pickedTime != null) {
      int diffInMinutes =
          timeHelper!.differenceBetweenTwoTimeOfDays(startAt!, pickedTime);
      if (diffInMinutes < minimumDurationInMinutes) {
        Fluttertoast.showToast(
            msg:
                'يجب أن يكون الفرق بين وقت البداية والنهاية ١٠ دقائق على الأقل!',
            toastLength: Toast.LENGTH_LONG,
            backgroundColor: color3);
        return;
      } else {
        setState(() {
          endAt = pickedTime;
        });
      }
    }
  }

  saveTimeRange(context, LoadingIndicator dialog) async {
    var formData = formstate.currentState;
    if (formData!.validate()) {
      if (startAt == null) {
        Fluttertoast.showToast(
            msg: "برجاء إختيار توقيت بداية الفترة!", backgroundColor: color3);
        return;
      }
      if (endAt == null) {
        Fluttertoast.showToast(
            msg: "برجاء إختيار توقيت نهاية الفترة!", backgroundColor: color3);
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

      Timestamp startAtDateTime = Timestamp.fromDate(DateTime(defaultYear,
          defaultMonth, defaultDay, startAt!.hour, startAt!.minute));
      Timestamp endAtDateTime = Timestamp.fromDate(DateTime(
          defaultYear, defaultMonth, defaultDay, endAt!.hour, endAt!.minute));
      ClinicAvailableTimeRange clinicAvailableTimeRange =
          ClinicAvailableTimeRange(
              startAtDateTime, endAtDateTime, durationInMinutes);

      if (widget.clinicAvailableTimeRanges.isEmpty) {
        ClinicAvailableDay clinicAvailableDay =
            ClinicAvailableDay(widget.dayNameInThreeDigit);
        await widget.clinicAvailableDaysDocumentReference
            .set(clinicAvailableDay.toJson())
            .then((value) async {
          saveRange(clinicAvailableTimeRange);
        }).catchError((error) {
          Fluttertoast.showToast(msg: "حدث خطأ ما!");
        });
      } else {
        saveRange(clinicAvailableTimeRange);
      }
    }
  }

  void saveRange(ClinicAvailableTimeRange clinicAvailableTimeRange) async {
    await widget.clinicAvailableDaysDocumentReference
        .collection(FirestoreCollections.ClinicAvailableTimes.name)
        .doc()
        .set(clinicAvailableTimeRange.toJson())
        .then((value) async {
      Fluttertoast.showToast(msg: "تم إضافة الفترة بنجاح!");
      Navigator.pop(dialogContext!);
      Navigator.pop(context);
    }).catchError((error) {
      Fluttertoast.showToast(msg: "حدث خطأ ما!");
    });
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart' as intl;

import '../../../constants/app_colors.dart';

class LabRaysOpeningHoursScreen extends StatefulWidget {
  bool isLab;

  LabRaysOpeningHoursScreen({Key? key, required this.isLab}) : super(key: key);

  @override
  State<LabRaysOpeningHoursScreen> createState() =>
      _LabRaysOpeningHoursScreenState();
}

class _LabRaysOpeningHoursScreenState extends State<LabRaysOpeningHoursScreen> {
  DateTime currentDate = DateTime.now();
  Map<String, dynamic> opiningDays = {};

  bool accountNotVerified = false, connectionError = false;
  final user = FirebaseAuth.instance.currentUser;
  bool getDaysIsLoading = false;

  Future<void> getDays() async {
    setState(() {
      getDaysIsLoading = true;
    });
    await FirebaseFirestore.instance
        .collection(widget.isLab ? "Labs" : "RaysCenter")
        .doc(user!.uid)
        .get()
        .then((value) {
      if (value.data()!.containsKey("openingHours"))
        opiningDays = value["openingHours"];
      if (value["accountStatus"] != 1) accountNotVerified = true;
    }).catchError((error) {
      connectionError = true;
      Fluttertoast.showToast(msg: "حدث خطأ حاول مرة اخرى");
    });
    setState(() {
      getDaysIsLoading = false;
    });
  }

  Future selectTime(BuildContext context) async {
    final TimeOfDay? picked =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) {
      return picked;
    } else {
      return 0;
    }
  }

  bool saveOpeningHoursIsLoading = false;

  saveOpeningHours() async {
    setState(() {
      saveOpeningHoursIsLoading = true;
    });
    await FirebaseFirestore.instance
        .collection(widget.isLab ? "Labs" : "RaysCenter")
        .doc(user!.uid)
        .update({
      "openingHours": opiningDays,
    }).then((value) {
      Fluttertoast.showToast(msg: "تم الحفظ بنجاح");
    }).catchError((error) {
      Fluttertoast.showToast(msg: "حدث خطأ حاول مرة اخرى");
    });
    setState(() {
      saveOpeningHoursIsLoading = false;
    });
  }

  changeTimeValue(String day, String time) {
    selectTime(context).then((value) {
      if (value != 0) {
        opiningDays[day][time]["hour"] = value.hour;
        opiningDays[day][time]["min"] = value.minute;
        setState(() {});
      } else {
        Fluttertoast.showToast(msg: "لم يتم تحديد موعد");
      }
    });
  }

  @override
  void initState() {
    getDays();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: accountNotVerified
          ? const Center(
              child: Text(
                "حسابك غير موثق",
                style: TextStyle(fontSize: 20, color: Colors.red),
              ),
            )
          : connectionError
              ? Center(
                  child: GestureDetector(
                      onTap: () => getDays(),
                      child: const Text(
                        "هناك خطأ ما حاول مجددا",
                        style: TextStyle(fontSize: 20, color: Colors.red),
                      )),
                )
              : getDaysIsLoading
                  ? const Center(
                      child: CupertinoActivityIndicator(),
                    )
                  : Container(
                      padding: const EdgeInsets.all(10),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 30,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "مواعيد العمل",
                                  style: TextStyle(fontSize: 25),
                                ),
                                if (accountNotVerified == false &&
                                    connectionError == false)
                                  saveOpeningHoursIsLoading
                                      ? const CupertinoActivityIndicator()
                                      : TextButton(
                                          onPressed: () => saveOpeningHours(),
                                          child: const Text(
                                            "حفظ المواعيد",
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        )
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            dayItem("Monday"),
                            dayItem("Tuesday"),
                            dayItem("Wednesday"),
                            dayItem("Thursday"),
                            dayItem("Friday"),
                            dayItem("Saturday"),
                            dayItem("Sunday"),
                          ],
                        ),
                      ),
                    ),
    );
  }

  Widget dayItem(String day) => Container(
        padding: const EdgeInsets.all(5),
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          gradient: const LinearGradient(
            colors: AppColors.primaryGradientColors,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  convertToArabicDay(day),
                  style: const TextStyle(fontSize: 20, color: Colors.white),
                ),
                Switch(
                    value: opiningDays.containsKey(day),
                    onChanged: (value) {
                      if (opiningDays.containsKey(day)) {
                        opiningDays.remove(day);
                      } else {
                        opiningDays[day] = {
                          "start": {"hour": 00, "min": 0},
                          "end": {"hour": 23, "min": 59},
                        };
                      }
                      setState(() {});
                    }),
              ],
            ),
            if (opiningDays.containsKey(day))
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const Text(
                    "تاريخ بدأ العمل",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  GestureDetector(
                    onTap: () => changeTimeValue(day, "start"),
                    child: Text(
                      intl.DateFormat.jm("ar_SA")
                          .format(DateTime(
                              currentDate.year,
                              currentDate.month,
                              currentDate.day,
                              opiningDays[day]["start"]["hour"],
                              opiningDays[day]["start"]["min"]))
                          .toString(),
                      style:
                          const TextStyle(fontSize: 16, color: Colors.yellow),
                    ),
                  ),
                  const Text(
                    "تاريخ انهاء العمل",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  GestureDetector(
                    onTap: () => changeTimeValue(day, "end"),
                    child: Text(
                      intl.DateFormat.jm("ar_SA")
                          .format(DateTime(
                              currentDate.year,
                              currentDate.month,
                              currentDate.day,
                              opiningDays[day]["end"]["hour"],
                              opiningDays[day]["end"]["min"]))
                          .toString(),
                      style:
                          const TextStyle(fontSize: 16, color: Colors.yellow),
                    ),
                  ),
                ],
              )
          ],
        ),
      );

  convertToArabicDay(String day) {
    String? out;
    switch (day) {
      case "Monday":
        out = "الاثنين";
        break;
      case "Tuesday":
        out = "الثلاثاء";
        break;
      case "Wednesday":
        out = "الأربعاء";
        break;
      case "Thursday":
        out = "الخميس";
        break;
      case "Friday":
        out = "الجمعة";
        break;
      case "Saturday":
        out = "السبت";
        break;
      case "Sunday":
        out = "الأحد";
        break;
    }
    return out;
  }
}

import 'package:clinico/model/rays.dart';
import 'package:clinico/view/components/components.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart' as intl;

import '../../../../constants/utils.dart';

class RayDetailsScreen extends StatefulWidget {
  Rays ray;

  RayDetailsScreen({Key? key, required this.ray}) : super(key: key);

  @override
  State<RayDetailsScreen> createState() => _RayDetailsScreenState();
}

class _RayDetailsScreenState extends State<RayDetailsScreen> {
  DateTime? dateAndTime;

  Future selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      return picked;
    } else {
      return 0;
    }
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2101));
    if (picked != null) {
      String day = intl.DateFormat("E").format(picked).toString();
      Map<String, dynamic>? dayDetails = getDayTime(day);
      if (dayDetails != null) {
        selectTime(
          context,
        ).then((value) {
          if (value != 0) {
            if (value.hour == dayDetails["start"]["hour"] &&
                value.minute < dayDetails["start"]["min"]) {
              Fluttertoast.showToast(msg: "غير متاح فى هذه الدقيقة");
              return;
            }
            if (value.hour == dayDetails["end"]["hour"] &&
                value.minute > dayDetails["end"]["min"]) {
              Fluttertoast.showToast(msg: "غير متاح فى هذه الدقيقة");
              return;
            }
            if (value.hour < dayDetails["start"]["hour"] ||
                value.hour > dayDetails["end"]["hour"]) {
              Fluttertoast.showToast(
                  msg:
                      "هذا الوقت غير متاح متاح من ${dayDetails["start"]["hour"]} الى ${dayDetails["end"]["hour"]}");
              return;
            }
            changeSelectedDataState(
                picked.add(Duration(hours: value.hour, minutes: value.minute)));
          } else {
            Fluttertoast.showToast(msg: "حدد الوقت");
          }
        });
      } else {
        Fluttertoast.showToast(msg: "لا يوجد مواعيد عمل فى اليوم المحدد");
      }
    }
  }

  TextEditingController address = TextEditingController();
  bool addDateIsLoading = false;

  changeSelectedDataState(DateTime pickedDate) async {
    setState(() {
      addDateIsLoading = true;
    });
    await FirebaseFirestore.instance
        .collection("Patients")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) async {
      DocumentReference coll =
          FirebaseFirestore.instance.collection("RayBookingRequests").doc();
      await FirebaseFirestore.instance
          .collection("RayBookingRequests")
          .doc(coll.id)
          .set({
        "date": pickedDate,
        "image": value["image"] ?? "",
        "phoneNumber": value["phoneNumber"] ?? "",
        "rayId": widget.ray.userId,
        "rayName": widget.ray.name,
        "requestId": coll.id,
        "requestStatus": 0,
        "userId": value["userId"] ?? "",
        "name": value["name"] ?? "",
      }).then((valueee) {
        if (value.data()!.containsKey("token")) {
          Utils.callOnFcmApiSendPushNotifications(
              token: value["token"],
              notificationTitle: "clinico",
              notificationBody: "تم حجز موعد من قبل " + "${value["name"]}",
              notificationData: {});
        }
      }).catchError(
              (error) => Fluttertoast.showToast(msg: "حدث خطأ حاول مجددا"));
    }).then((value) {
      Fluttertoast.showToast(msg: "تم تحديد العنوان بنجاح");
    }).catchError((error) => Fluttertoast.showToast(msg: "حدث خطأ حاول مجددا"));
    setState(() {
      addDateIsLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "بيانات المركز",
            style: TextStyle(fontSize: 20),
          ),
        ),
        body: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.ray.image != "")
                            Center(
                              child: CircleAvatar(
                                radius: 52,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: Image(
                                    height: 100,
                                    width: 100,
                                    image: NetworkImage(widget.ray.image!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          const SizedBox(
                            height: 20,
                          ),
                          const Text(
                            "اسم المركز",
                            style: TextStyle(fontSize: 20, color: Colors.black),
                          ),
                          Text(
                            widget.ray.name!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 17, color: Colors.yellow),
                          ),
                          // Spacer(),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text(
                            "العنوان",
                            style: TextStyle(fontSize: 20, color: Colors.black),
                          ),
                          Text(
                            widget.ray.address!,
                            style: const TextStyle(
                                fontSize: 17, color: Colors.yellow),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text(
                            "عن المركز",
                            style: TextStyle(fontSize: 20, color: Colors.black),
                          ),
                          Text(
                            widget.ray.description!,
                            style: const TextStyle(
                                fontSize: 17, color: Colors.yellow),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                addDateIsLoading
                    ? const Center(child: CupertinoActivityIndicator())
                    : defaultElevatedButton(
                        context: context,
                        onPressed: () {
                          selectDate(context);
                        },
                        buttonText: "حجز موعد"),
                const SizedBox(
                  height: 10,
                ),
              ],
            )),
      ),
    );
  }

  DateTime currentDate = DateTime.now();

  Widget dayItem(String day) => Container(
        padding: const EdgeInsets.all(5),
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              convertToArabicDay(day),
              style: const TextStyle(fontSize: 20),
            ),
            if (widget.ray.openingHours!.containsKey(day))
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const Text(
                    "تاريخ بدأ العمل",
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    intl.DateFormat.jm("ar_SA")
                        .format(DateTime(
                            currentDate.year,
                            currentDate.month,
                            currentDate.day,
                            widget.ray.openingHours![day]["start"]["hour"],
                            widget.ray.openingHours![day]["start"]["min"]))
                        .toString(),
                    style: const TextStyle(fontSize: 16, color: Colors.blue),
                  ),
                  const Text(
                    "تاريخ انهاء العمل",
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    intl.DateFormat.jm("ar_SA")
                        .format(DateTime(
                            currentDate.year,
                            currentDate.month,
                            currentDate.day,
                            widget.ray.openingHours![day]["end"]["hour"],
                            widget.ray.openingHours![day]["end"]["min"]))
                        .toString(),
                    style: const TextStyle(fontSize: 16, color: Colors.blue),
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

  Map<String, dynamic>? getDayTime(String day) {
    Map<String, dynamic>? dayDetails;
    switch (day) {
      case "Mon":
        dayDetails = widget.ray.openingHours!["Monday"];
        break;
      case "Tue":
        dayDetails = widget.ray.openingHours!["Tuesday"];
        break;
      case "Wed":
        dayDetails = widget.ray.openingHours!["Wednesday"];
        break;
      case "Thu":
        dayDetails = widget.ray.openingHours!["Thursday"];
        break;
      case "Fri":
        dayDetails = widget.ray.openingHours!["Friday"];
        break;
      case "Sat":
        dayDetails = widget.ray.openingHours!["Saturday"];
        break;
      case "Sun":
        dayDetails = widget.ray.openingHours!["Sunday"];
        break;
    }
    return dayDetails;
  }
}

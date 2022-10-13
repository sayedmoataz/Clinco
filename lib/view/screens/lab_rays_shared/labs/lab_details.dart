import 'package:clinico/constants/utils.dart';
import 'package:clinico/model/labs.dart';
import 'package:clinico/view/components/components.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart' as intl;

class LabDetailsScreen extends StatefulWidget {
  Labs lab;

  LabDetailsScreen({Key? key, required this.lab}) : super(key: key);

  @override
  State<LabDetailsScreen> createState() => _LabDetailsScreenState();
}

class _LabDetailsScreenState extends State<LabDetailsScreen> {
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
    List add = await showAddressDialog(context);
    if (add[0] != "غير" && address.text.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection("Patients")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get()
          .then((value) async {
        DocumentReference coll = FirebaseFirestore.instance
            // .collection("Labs").doc(widget.lab.userId)
            .collection("LabBookingRequests")
            .doc();
        await FirebaseFirestore.instance
            // .collection("Labs").doc(widget.lab.userId)
            .collection("LabBookingRequests")
            .doc(coll.id)
            .set({
          "address": address.text,
          "date": pickedDate,
          "image": value["image"] ?? "",
          "phoneNumber": value["phoneNumber"] ?? "",
          "labId": widget.lab.userId,
          "labName": widget.lab.name,
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
      }).catchError(
              (error) => Fluttertoast.showToast(msg: "حدث خطأ حاول مجددا"));
    } else {
      Fluttertoast.showToast(msg: "لم يتم تحديد عنوان");
    }
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
            "بيانات المعمل",
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
                          if (widget.lab.image != "")
                            Center(
                              child: CircleAvatar(
                                radius: 52,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: Image(
                                    height: 100,
                                    width: 100,
                                    image: NetworkImage(widget.lab.image!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          const SizedBox(
                            height: 20,
                          ),
                          const Text(
                            "اسم المعمل",
                            style: TextStyle(fontSize: 20, color: Colors.black),
                          ),
                          Text(
                            widget.lab.name!,
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
                            widget.lab.address!,
                            // maxLines: 2,
                            // overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 17, color: Colors.yellow),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text(
                            "عن المعمل",
                            style: TextStyle(fontSize: 20, color: Colors.black),
                          ),
                          Text(
                            widget.lab.description!,
                            // maxLines: 2,
                            // overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 17, color: Colors.yellow),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          // const Text("مواعيد العمل",style: TextStyle(fontSize: 20),),
                          // widget.lab.openingHours!.isNotEmpty ? const Text("مواعيد العمل",style: TextStyle(fontSize: 20),) :
                          //   ListView(
                          //     physics: const NeverScrollableScrollPhysics(),
                          //     shrinkWrap: true,
                          //     children: widget.lab.openingHours!.keys.map((e) {
                          //       return dayItem(e);
                          //     }).toList(),
                          //   )
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
            if (widget.lab.openingHours!.containsKey(day))
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
                            widget.lab.openingHours![day]["start"]["hour"],
                            widget.lab.openingHours![day]["start"]["min"]))
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
                            widget.lab.openingHours![day]["end"]["hour"],
                            widget.lab.openingHours![day]["end"]["min"]))
                        .toString(),
                    style: const TextStyle(fontSize: 16, color: Colors.blue),
                  ),
                ],
              )
          ],
        ),
      );

  Future showAddressDialog(BuildContext context) async {
    // TextEditingController address = TextEditingController();
    address.clear();
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('العنوان'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  TextFormField(
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(8),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide:
                              const BorderSide(width: 1, color: Colors.grey)),
                      labelStyle: const TextStyle(),
                    ),
                    controller: address,
                  ),
                ],
              ),
            ),
            actionsAlignment: MainAxisAlignment.start,
            actions: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20))),
                child: const Text(
                  'تاكيد',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  if (address.text.isEmpty) {
                    Fluttertoast.showToast(msg: "اكتب العنوان");
                  } else {
                    Navigator.of(context).pop([address.text]);
                  }
                },
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  onPrimary: Colors.grey[400],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20))),
                child: const Text('ليس الان',
                    style: TextStyle(color: Colors.white)),
                onPressed: () {
                  Navigator.of(context).pop(["غير"]);
                },
              ),
            ],
          ),
        );
      },
    );
  }

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
        dayDetails = widget.lab.openingHours!["Monday"];
        break;
      case "Tue":
        dayDetails = widget.lab.openingHours!["Tuesday"];
        break;
      case "Wed":
        dayDetails = widget.lab.openingHours!["Wednesday"];
        break;
      case "Thu":
        dayDetails = widget.lab.openingHours!["Thursday"];
        break;
      case "Fri":
        dayDetails = widget.lab.openingHours!["Friday"];
        break;
      case "Sat":
        dayDetails = widget.lab.openingHours!["Saturday"];
        break;
      case "Sun":
        dayDetails = widget.lab.openingHours!["Sunday"];
        break;
    }
    return dayDetails;
  }
}

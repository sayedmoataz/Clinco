import 'package:clinico/view/components/components.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart' as intl;

import '../../../constants/app_colors.dart';
import '../../../constants/utils.dart';
import '../../../model/lab_request.dart';

class LabRayRequestDetails extends StatefulWidget {
  bool isLab;
  LabRequestModel request;
  int pageIndex;

  LabRayRequestDetails(
      {required this.isLab, required this.request, required this.pageIndex});

  @override
  State<LabRayRequestDetails> createState() => _LabRayRequestDetailsState();
}

class _LabRayRequestDetailsState extends State<LabRayRequestDetails> {
  final intl.DateFormat timeFormat =
          intl.DateFormat('EEEE  yyyy/MM/dd - hh:mm a', 'ar_KSA'),
      dayFormatEnglish = intl.DateFormat('EEE');

  bool updateRequestStatusIsLoading = false;

  Future<void> updateRequestStatus(int state) async {
    setState(() {
      updateRequestStatusIsLoading = true;
    });
    await FirebaseFirestore.instance
        .collection(widget.isLab ? "LabBookingRequests" : "RayBookingRequests")
        .doc(widget.request.requestId)
        .update({"requestStatus": state}).then((value) {
      Navigator.pop(context);
    }).then((valueee) {
      Utils.callOnFcmApiSendPushNotificationsWithId(
          userId: widget.request.userId!,
          accountType: "Patients",
          notificationTitle: "clinico",
          notificationBody: state == 1
              ? "تم قبول حجزك من ${widget.request.labName!} بتاريخ ${timeFormat.format(widget.request.date!.toDate())} "
              : "تم رفض حجزك من ${widget.request.labName!} بتاريخ ${timeFormat.format(widget.request.date!.toDate())} ",
          notificationData: {});
    }).catchError((error) {
      Fluttertoast.showToast(msg: "حدث خطأ حاول مرة اخرى");
    });
    setState(() {
      updateRequestStatusIsLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "تفاصيل الحجز",
            style: TextStyle(fontSize: 20),
          ),
        ),
        body: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      widget.request.image == ""
                          ? Center(
                              child: CircleAvatar(
                                radius: 42,
                                backgroundColor: AppColors.appPrimaryColor,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(40),
                                  child: const Image(
                                    height: 80,
                                    width: 80,
                                    fit: BoxFit.fill,
                                    image: AssetImage(
                                        "assets/images/user_avatar.png"),
                                  ),
                                ),
                              ),
                            )
                          : Center(
                              child: CircleAvatar(
                                radius: 42,
                                backgroundColor: AppColors.appPrimaryColor,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(40),
                                  child: Image(
                                    height: 80,
                                    width: 80,
                                    fit: BoxFit.fill,
                                    image: NetworkImage(widget.request.image!),
                                  ),
                                ),
                              ),
                            ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        "اسم العميل",
                        style: TextStyle(fontSize: 20),
                      ),
                      Text(
                        widget.request.name!,
                        style: const TextStyle(fontSize: 18),
                      ),
                      const Divider(),
                      const Text(
                        "موعد الحجز",
                        style: TextStyle(fontSize: 20),
                      ),
                      Text(
                        timeFormat.format(widget.request.date!.toDate()),
                        style: const TextStyle(fontSize: 18),
                      ),
                      const Divider(),
                      const Text(
                        "العنوان",
                        style: TextStyle(fontSize: 20),
                      ),
                      Text(
                        widget.request.address!,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),
              widget.pageIndex == 1
                  ? Center(
                      child: defaultElevatedButton(
                          context: context,
                          onPressed: () {
                            updateRequestStatus(3);
                          },
                          buttonText: "تم العمل"))
                  : updateRequestStatusIsLoading
                      ? const Center(
                          child: CupertinoActivityIndicator(),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            defaultElevatedButton(
                                context: context,
                                onPressed: () {
                                  updateRequestStatus(1);
                                },
                                buttonText: "قبول"),
                            defaultElevatedButton(
                                context: context,
                                onPressed: () {
                                  updateRequestStatus(2);
                                },
                                buttonText: "رفض",
                                primary: Colors.red),
                          ],
                        ),
              const SizedBox(
                height: 10,
              )
            ],
          ),
        ),
      ),
    );
  }
}

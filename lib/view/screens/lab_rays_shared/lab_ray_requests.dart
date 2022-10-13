import 'package:clinico/constants/app_colors.dart';
import 'package:clinico/model/lab_request.dart';
import 'package:clinico/view/screens/lab_rays_shared/lab_ray_request_details.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

class LabRayRequests extends StatefulWidget {
  bool isLab;
  int pageIndex;

  LabRayRequests({Key? key, required this.pageIndex, required this.isLab})
      : super(key: key);

  @override
  State<LabRayRequests> createState() => _LabRayRequestsState();
}

class _LabRayRequestsState extends State<LabRayRequests> {
  final intl.DateFormat timeFormat =
          intl.DateFormat('EEEE  yyyy/MM/dd - hh:mm a', 'ar_KSA'),
      dayFormatEnglish = intl.DateFormat('EEE');

  var newRequestsStream;

  @override
  void initState() {
    newRequestsStream = FirebaseFirestore.instance
        // .collection("Labs")
        // .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection(widget.isLab ? "LabBookingRequests" : "RayBookingRequests")
        .where(widget.isLab ? "labId" : "rayId",
            isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .where("requestStatus", isEqualTo: widget.pageIndex)
        .orderBy("date", descending: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.pageIndex == 1
          ? null
          : AppBar(
              leading: Center(
                  child: Text(
                "CLINICO",
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: AppColors.appPrimaryColor,
                    fontSize: 28,
                    fontWeight: FontWeight.bold),
              )),
              leadingWidth: 100,
              backgroundColor:
                  widget.pageIndex == 1 ? Colors.white : Colors.grey[100],
              elevation: 0,
            ),
      backgroundColor: widget.pageIndex == 1 ? Colors.white : Colors.grey[100],
      body: StreamBuilder(
        stream: newRequestsStream.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            List<QueryDocumentSnapshot> docs = snapshot.data!.docs;
            if (docs.isEmpty) {
              return const Center(
                  child: Text('عفواً، لا يوجد بيانات!',
                      style: TextStyle(color: Colors.blue)));
            }
            List<LabRequestModel> newRequestsList = [];
            docs.forEach((element) {
              newRequestsList.add(LabRequestModel.fromJson(
                  element.data() as Map<String, dynamic>));
            });
            return buildCardItems(newRequestsList, widget.pageIndex);
          } else if (snapshot.hasError) {
            return const Center(
                child: Text(
              'عفواً، حدث خطأ ما!',
              style: TextStyle(color: Colors.red),
            ));
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return const Center(
              child: Text(
            'عفواً، حدث خطأ ما!',
            style: TextStyle(color: Colors.red),
          ));
        },
      ),
    );
  }

  Widget buildCardItems(List<LabRequestModel> newRequestsList, int pageIndex) =>
      ListView.builder(
        itemCount: newRequestsList.length,
        itemBuilder: (ctx, index) {
          return GestureDetector(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => LabRayRequestDetails(
                          isLab: widget.isLab,
                          request: newRequestsList[index],
                          pageIndex: widget.pageIndex,
                        ))),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: pageIndex == 1
                          ? AppColors.appPrimaryColor
                          : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      // border: Border(
                      //     right: BorderSide(color: AppColors.appPrimaryColor,),
                      //     top:  BorderSide(color: Colors.white,),
                      //     left:  BorderSide(color: Colors.white,),
                      //     bottom:  BorderSide(color: Colors.white,),
                      // )
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "موعد الحجز",
                          style: TextStyle(
                              fontSize: 18,
                              color:
                                  pageIndex == 1 ? Colors.white : Colors.black),
                        ),
                        Text(
                            timeFormat
                                .format(newRequestsList[index].date!.toDate()),
                            style: TextStyle(
                                color: pageIndex == 1
                                    ? Colors.white
                                    : Colors.black)),
                        const Divider(),
                        Row(
                          children: [
                            newRequestsList[index].image == ""
                                ? CircleAvatar(
                                    radius: 26,
                                    backgroundColor: pageIndex == 1
                                        ? Colors.white
                                        : AppColors.appPrimaryColor,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(25),
                                      child: const Image(
                                        height: 50,
                                        width: 50,
                                        fit: BoxFit.fill,
                                        image: AssetImage(
                                            "assets/images/user_avatar.png"),
                                      ),
                                    ),
                                  )
                                : CircleAvatar(
                                    radius: 26,
                                    backgroundColor: pageIndex == 1
                                        ? Colors.white
                                        : AppColors.appPrimaryColor,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(25),
                                      child: Image(
                                        height: 50,
                                        width: 50,
                                        fit: BoxFit.fill,
                                        image: NetworkImage(
                                            newRequestsList[index].image!),
                                      ),
                                    ),
                                  ),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    newRequestsList[index].name!,
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: pageIndex == 1
                                            ? Colors.white
                                            : Colors.black),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(newRequestsList[index].address!,
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: pageIndex == 1
                                              ? Colors.white
                                              : Colors.black),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis)
                                ],
                              ),
                            )
                          ],
                        ),
                      ],
                    )),
              ),
            ),
          );
        },
      );
}

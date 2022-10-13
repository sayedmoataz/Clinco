import 'package:clinico/constants/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../model/bought_devices.dart';

class DevicesCart extends StatefulWidget {
  const DevicesCart({Key? key}) : super(key: key);

  @override
  State<DevicesCart> createState() => _DevicesCartState();
}

class _DevicesCartState extends State<DevicesCart> {
  bool pageIsLoading = false;
  final DateFormat timeFormat =
          DateFormat('EEEE  yyyy/MM/dd - hh:mm a', 'ar_KSA'),
      dayFormatEnglish = DateFormat('EEE');

  List<DevicesHistory> devicesHistory = [];

  var boughtData = FirebaseFirestore.instance
      .collection("DevicesHistory")
      .where("createdBy", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .orderBy("date", descending: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder(
      stream: boughtData.snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(
              child: Text("لا يوجد عمليات شراء"),
            );
          } else {
            devicesHistory.clear();
            docs.forEach((element) {
              devicesHistory.add(DevicesHistory.fromJson(element.data()));
            });
            return ListView.builder(
              itemCount: devicesHistory.length,
              itemBuilder: (ctx, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: const LinearGradient(
                        colors: AppColors.primaryGradientColors,
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                    height: 160,
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        if (devicesHistory[index].images!.isNotEmpty)
                          SizedBox(
                            width: 140,
                            height: 140,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                devicesHistory[index].images!.first,
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        const SizedBox(
                          width: 8,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(devicesHistory[index].manufacture!,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                              Text(devicesHistory[index].name!,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.yellow,
                                      fontWeight: FontWeight.bold)),
                              Text("${devicesHistory[index].price!} جنية",
                                  style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.yellow,
                                      fontWeight: FontWeight.bold)),
                              const Spacer(),
                              Text(
                                timeFormat.format(
                                    devicesHistory[index].date!.toDate()),
                                style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
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
      },
    ));
  }
}

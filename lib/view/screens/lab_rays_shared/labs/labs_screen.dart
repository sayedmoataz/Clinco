import 'package:clinico/view/screens/lab_rays_shared/labs/lab_details.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../../constants/app_colors.dart';
import '../../../../model/labs.dart';

class LabsScreen extends StatefulWidget {
  @override
  State<LabsScreen> createState() => _LabsScreenState();
}

class _LabsScreenState extends State<LabsScreen> {
  List<Labs> labsList = [];
  bool pageIsLoading = false;

  Future<void> getLabsList() async {
    setState(() {
      pageIsLoading = true;
    });
    await FirebaseFirestore.instance.collection("Labs").get().then((value) {
      labsList.clear();
      value.docs.forEach((element) {
        labsList.add(Labs.fromJson(element.data()));
      });
    }).catchError((error) {
      Fluttertoast.showToast(msg: "حدث خطأ حاول مرة اخري");
    });
    setState(() {
      pageIsLoading = false;
    });
  }

  @override
  void initState() {
    getLabsList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "معامل التحاليل",
            style: TextStyle(fontSize: 20),
          ),
        ),
        body: pageIsLoading
            ? const Center(
                child: CupertinoActivityIndicator(),
              )
            : labsList.isEmpty
                ? const Center(
                    child: Text(
                      "لا يتوفر معامل",
                      style: TextStyle(fontSize: 20),
                    ),
                  )
                : labItems(),
      ),
    );
  }

  Widget labItems() => ListView.builder(
        // separatorBuilder: (context,index) => const Divider(),
        itemCount: labsList.length,
        itemBuilder: (context, index) {
          return Container(
            padding: const EdgeInsets.all(8),
            // color: Colors.grey[100],
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            LabDetailsScreen(lab: labsList[index])));
              },
              child: Container(
                // height: 200,
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(
                    colors: AppColors.primaryGradientColors,
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                // decoration:  BoxDecoration(shape: BoxShape.rectangle, borderRadius: BorderRadius.all(Radius.circular(10.0)), gradient: LinearGradient(colors: [AppColors.appPrimaryColor, Color(0x8000000),], begin: FractionalOffset(0.0, 1.0), end: FractionalOffset(0.0, 0.0), stops: [0.0, 1.0], tileMode: TileMode.clamp),),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "اسم المعمل",
                            style: TextStyle(fontSize: 17),
                          ),
                          Text(
                            labsList[index].name!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 15, color: Colors.white),
                          ),
                          // Spacer(),
                          const SizedBox(
                            height: 5,
                          ),
                          const Text(
                            "العنوان",
                            style: TextStyle(fontSize: 17),
                          ),
                          Text(
                            labsList[index].address!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 15, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    if (labsList[index].image != "")
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image(
                          image: NetworkImage(labsList[index].image!),
                          // image: AssetImage(labsList[index].image!),
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      );
}

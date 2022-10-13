import 'package:clinico/model/rays.dart';
import 'package:clinico/view/screens/lab_rays_shared/rays/rays_details.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../../constants/app_colors.dart';

class RaysScreen extends StatefulWidget {
  @override
  State<RaysScreen> createState() => _RaysScreenState();
}

class _RaysScreenState extends State<RaysScreen> {
  List<Rays> raysList = [];
  bool pageIsLoading = false;

  Future<void> getraysList() async {
    setState(() {
      pageIsLoading = true;
    });
    await FirebaseFirestore.instance.collection("Labs").get().then((value) {
      raysList.clear();
      value.docs.forEach((element) {
        raysList.add(Rays.fromJson(element.data()));
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
    getraysList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "مراكز الأشعة",
            style: TextStyle(fontSize: 20),
          ),
        ),
        body: pageIsLoading
            ? const Center(
                child: CupertinoActivityIndicator(),
              )
            : raysList.isEmpty
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
        itemCount: raysList.length,
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
                            RayDetailsScreen(ray: raysList[index])));
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
                            "إسم المركز",
                            style: TextStyle(
                                fontSize: 17,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            raysList[index].name!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 16,
                                color: Colors.yellow,
                                fontWeight: FontWeight.bold),
                          ),
                          // Spacer(),
                          const SizedBox(
                            height: 5,
                          ),
                          const Text(
                            "العنوان",
                            style: TextStyle(
                                fontSize: 17,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            raysList[index].address!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 16,
                                color: Colors.yellow,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    if (raysList[index].image != "")
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image(
                          image: NetworkImage(raysList[index].image!),
                          // image: AssetImage(raysList[index].image!),
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

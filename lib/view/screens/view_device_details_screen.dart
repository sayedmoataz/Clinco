import 'dart:ui' as ui;

import 'package:carousel_slider/carousel_slider.dart';
import 'package:clinico/constants/app_colors.dart';
import 'package:clinico/constants/utils.dart';
import 'package:clinico/view/components/components.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:full_screen_image_null_safe/full_screen_image_null_safe.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../../helper/shared_preferences.dart';
import '../../helper/social_media_operations.dart';
import '../../model/device.dart';
import '../../model/user_data.dart';
import '../components/device_images_slider.dart';

class ViewDeviceDetailsScreen extends StatefulWidget {
  final Device device;

  const ViewDeviceDetailsScreen({Key? key, required this.device})
      : super(key: key);

  @override
  _ViewDeviceDetailsScreenState createState() =>
      _ViewDeviceDetailsScreenState();
}

class _ViewDeviceDetailsScreenState extends State<ViewDeviceDetailsScreen> {
  Color primaryColor = AppColors.primaryColor;
  Color secondaryColor1 = AppColors.secondaryColor1;
  List<Color> primaryGradientColors = AppColors.primaryGradientColors;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  Map<String, dynamic>? advertiserJsonMap;
  DateFormat dateFormat = DateFormat('a hh:mm - yyyy/MM/dd');
  bool isAdmin = false;
  SocialMediaOperations? socialMediaOperations;
  List<Device> devices = <Device>[];
  Query<Map<String, dynamic>>? query;
  String? _userId;
  late final AppData _appData;
  bool buyDeviceIsLoading = false;

  @override
  void initState() {
    socialMediaOperations = SocialMediaOperations();
    _appData = AppData();
    _appData.getSharedPreferencesInstance().then((pref) {
      _userId = _appData.getUserId(pref!)!;
      _getAdvertiserInformation();
    });
    super.initState();
  }

  void _getAdvertiserInformation() {
    _firebaseFirestore
        .doc('${FirestoreCollections.Users.name}/${widget.device.createdBy}')
        .get()
        .then((value) {
      UserData advertiserUserAccount = UserData.fromJson(value.data()!);
      CollectionReference<Map<String, dynamic>> collectionReference =
          (advertiserUserAccount.accountType == AccountTypes.Doctor.name)
              ? _firebaseFirestore.collection(FirestoreCollections.Doctors.name)
              : _firebaseFirestore
                  .collection(FirestoreCollections.Companies.name);
      collectionReference
          .where('userId', isEqualTo: widget.device.createdBy)
          .get()
          .then((snapshos) {
        QueryDocumentSnapshot<Map<String, dynamic>> queryDocumentSnapshot =
            snapshos.docs.first;
        if (queryDocumentSnapshot.exists) {
          setState(() {
            advertiserJsonMap = queryDocumentSnapshot.data();
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: ui.TextDirection.rtl,
        child: Scaffold(
            appBar: AppBar(
              title: const Text(
                "تفاصيل الجهاز",
                style: TextStyle(fontSize: 20),
              ),
              // flexibleSpace: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: primaryGradientColors),),),
              actions: [
                Visibility(
                  visible: (advertiserJsonMap?['phoneNumber'] != null &&
                      advertiserJsonMap?['phoneNumber']!.isNotEmpty),
                  child: IconButton(
                    icon: const Icon(
                      Icons.call,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      socialMediaOperations?.launchStringUrl(
                          socialMediaOperations!.getCallUrl(
                              advertiserJsonMap!['phoneNumber']!.toString()));
                    },
                  ),
                )
              ],
            ),
            body: getDeviceDetailsContainerWidget()));
  }

  getDeviceDetailsContainerWidget() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Container(
      height: double.infinity,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Directionality(
            textDirection: ui.TextDirection.rtl,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          height: screenHeight * 0.45,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10)),
                          child: CarouselSlider(
                            //Slider Container properties
                            options: CarouselOptions(
                              height: double.infinity,
                              enlargeCenterPage: true,
                              autoPlay: true,
                              aspectRatio: 16 / 9,
                              autoPlayCurve: Curves.fastOutSlowIn,
                              enableInfiniteScroll: true,
                              autoPlayAnimationDuration: const Duration(milliseconds: 1000),
                              viewportFraction: 0.5,
                            ), 
                            items:List.generate(
                              widget.device.images!.length,
                              (index1) => FullScreenWidget(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child : PhotoViewGallery.builder(
                                    itemCount: widget.device.images!.length,
                                    backgroundDecoration: const BoxDecoration(color: Colors.white),
                                    allowImplicitScrolling: true,
                                    scrollPhysics: const NeverScrollableScrollPhysics(),
                                    builder: (context, index) => 
                                    PhotoViewGalleryPageOptions(
                                      imageProvider: NetworkImage(widget.device.images![index1].toString())
                                    ), 
                                  ),
                                ),
                              )
                            ),
                          )),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                            margin: const EdgeInsets.only(top: 0.02),
                            // alignment: Alignment.centerLeft,
                            child: Text(widget.device.name ?? '',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 3,
                                style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor),
                                textDirection: ui.TextDirection.rtl,
                                textAlign: TextAlign.right)),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                            margin: const EdgeInsets.only(top: 0.5),
                            // alignment: Alignment.topLeft,
                            child: Text(widget.device.formattedPrice,
                                style: const TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.secondaryColor4),
                                textDirection: ui.TextDirection.rtl,
                                textAlign: TextAlign.center)),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                            margin: const EdgeInsets.only(top: 0.01),
                            alignment: Alignment.centerRight,
                            child: Text(
                                '${widget.device.type ?? ''}، ${widget.device.manufacture ?? ''}',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: const TextStyle(
                                    fontSize: 17.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                                textDirection: ui.TextDirection.rtl,
                                textAlign: TextAlign.center)),
                        const SizedBox(
                          height: 10,
                        ),
                        Visibility(
                            visible: widget.device.warranty != null &&
                                widget.device.warranty! > 0,
                            child: Container(
                                margin: const EdgeInsets.only(top: 0.01),
                                alignment: Alignment.centerRight,
                                child: Text(
                                    'مدة الضمان: ${widget.device.warranty} شهر',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: const TextStyle(
                                        fontSize: 17.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                    textDirection: ui.TextDirection.rtl,
                                    textAlign: TextAlign.center))),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                            margin: const EdgeInsets.only(top: 0.01),
                            alignment: Alignment.centerRight,
                            child: Text(
                                advertiserJsonMap != null
                                    ? 'المعلن: ${(widget.device.createdBy == _userId) ? 'أنت' : advertiserJsonMap?['name']}'
                                    : '',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: const TextStyle(
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                                textDirection: ui.TextDirection.rtl,
                                textAlign: TextAlign.center)),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                            margin: const EdgeInsets.only(top: 0.5),
                            child: Text(
                              widget.device.description!,
                              style: const TextStyle(
                                  fontSize: 17.0,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black),
                              textDirection: ui.TextDirection.rtl,
                            ))
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: screenWidth * 0.8,
                  height: 50,
                  child: buyDeviceIsLoading
                      ? const CupertinoActivityIndicator()
                      : defaultElevatedButton(
                          context: context,
                          onPressed: () async {
                            setState(() {
                              buyDeviceIsLoading = true;
                            });
                            DocumentReference collId = FirebaseFirestore
                                .instance
                                .collection("DevicesHistory")
                                .doc();
                            await FirebaseFirestore.instance
                                .collection("DevicesHistory")
                                .doc()
                                .set({
                              'createdBy': widget.device.createdBy,
                              'name': widget.device.name,
                              'selectedCountry': widget.device.selectedCountry,
                              'price': widget.device.price,
                              'type': widget.device.type,
                              'warranty': widget.device.warranty,
                              'manufacture': widget.device.manufacture,
                              'description': widget.device.description,
                              'images': widget.device.images,
                              'buyer': FirebaseAuth.instance.currentUser!.uid,
                              'collId': collId.id,
                              "date": DateTime.now()
                            }).then((value) {
                              Fluttertoast.showToast(msg: 'تم الطلب بنجاح');
                              Utils.callOnFcmApiSendPushNotificationsWithId(
                                  userId: widget.device.createdBy!,
                                  accountType: "Companies",
                                  notificationTitle: "clinico",
                                  notificationBody:
                                      "تم طلب جهاز " + "${widget.device.name}",
                                  notificationData: {});
                              if (widget.device.selectedCountry! == "KSA") {
                                Utils.callOnFcmApiSendPushNotificationsWithId(
                                    userId: "DxtUFYwWwsZqMFAzoAyrYvlSTD83",
                                    accountType: "Admins",
                                    notificationTitle: "clinico",
                                    notificationBody: "تم طلب جهاز " +
                                        "${widget.device.name}",
                                    notificationData: {});
                              } else {
                                Utils.callOnFcmApiSendPushNotificationsWithId(
                                    userId: "1BPrrfXJ7zee0P1iPxl05fkojGB3",
                                    accountType: "Admins",
                                    notificationTitle: "clinico",
                                    notificationBody: "تم طلب جهاز " +
                                        "${widget.device.name}",
                                    notificationData: {});
                                Utils.callOnFcmApiSendPushNotificationsWithId(
                                    userId: "WG69og9oVBWw2nj8EHumLOLlS9u1",
                                    accountType: "Admins",
                                    notificationTitle: "clinico",
                                    notificationBody: "تم طلب جهاز " +
                                        "${widget.device.name}",
                                    notificationData: {});
                              }
                            }).catchError((error) {
                              Fluttertoast.showToast(
                                  msg: 'حدث خطأ حاول مرة اخرى');
                            });
                            setState(() {
                              buyDeviceIsLoading = false;
                            });
                          },
                          buttonText: "طلب الجهاز",
                        ),
                ),
                const SizedBox(
                  height: 10,
                )
              ],
            )),
      ),
    );
  }
}

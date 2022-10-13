import 'dart:ui' as ui;

import 'package:clinico/constants/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../model/speciality.dart';
import '../../model/user_data.dart';
import '../components/user_profile_widget.dart';

class ViewUserProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? userAccountJsonMap;

  const ViewUserProfileScreen({Key? key, required this.userAccountJsonMap})
      : super(key: key);

  @override
  _ViewUserProfileScreenState createState() => _ViewUserProfileScreenState();
}

class _ViewUserProfileScreenState extends State<ViewUserProfileScreen> {
  List<Color> primaryGradientColors = AppColors.primaryGradientColors;
  Color primaryLightColor = AppColors.primaryColor;
  late final FirebaseFirestore _firebaseFirestore;
  Speciality? _doctorSpeciality;

  @override
  void initState() {
    _firebaseFirestore = FirebaseFirestore.instance;
    if (widget.userAccountJsonMap?['specialityId'] != null &&
        widget.userAccountJsonMap!['specialityId']
            .toString()
            .trim()
            .isNotEmpty) {
      getDoctorSpeciality();
    }
    super.initState();
  }

  void getDoctorSpeciality() {
    _firebaseFirestore
        .collection(FirestoreCollections.Specialties.name)
        .doc(widget.userAccountJsonMap!['specialityId'])
        .get()
        .then((value) {
      setState(() {
        _doctorSpeciality = Speciality.fromJson(value.data());
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: ui.TextDirection.rtl,
        child: Scaffold(
            appBar: AppBar(
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: primaryGradientColors),
                ),
              ),
            ),
            body: UserProfileWidget(
              userAccountJsonMap: widget.userAccountJsonMap,
              doctorSpeciality: _doctorSpeciality,
            )));
  }
}

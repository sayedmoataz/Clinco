import 'dart:ui' as ui;

import 'package:clinico/constants/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../model/physician_impersonator.dart';
import '../../model/speciality.dart';
import '../../model/user_data.dart';
import '../components/physician_mpersonator_profile_widget.dart';

class ViewPhysicianImpersonatorProfileScreen extends StatefulWidget {
  final PhysicianImpersonator? physicianImpersonator;

  const ViewPhysicianImpersonatorProfileScreen(
      {Key? key, required this.physicianImpersonator})
      : super(key: key);

  @override
  _ViewPhysicianImpersonatorProfileScreenState createState() =>
      _ViewPhysicianImpersonatorProfileScreenState();
}

class _ViewPhysicianImpersonatorProfileScreenState
    extends State<ViewPhysicianImpersonatorProfileScreen> {
  BuildContext? dialogContext;
  List<Color> primaryGradientColors = AppColors.primaryGradientColors;
  Color primaryColor = AppColors.primaryColor;
  Color secondaryColor2 = AppColors.secondaryColor2;
  late final FirebaseFirestore _firebaseFirestore;
  Speciality? _physicianImpersonatorSpeciality;

  @override
  void initState() {
    _firebaseFirestore = FirebaseFirestore.instance;
    if (widget.physicianImpersonator?.specialityId != null &&
        widget.physicianImpersonator!.specialityId
            .toString()
            .trim()
            .isNotEmpty) {
      getPhysicianImpersonatorSpeciality();
    }
    super.initState();
  }

  void getPhysicianImpersonatorSpeciality() {
    _firebaseFirestore
        .collection(FirestoreCollections.Specialties.name)
        .doc(widget.physicianImpersonator!.specialityId)
        .get()
        .then((value) {
      setState(() {
        _physicianImpersonatorSpeciality = Speciality.fromJson(value.data());
      });
    });
  }

  @override
  Widget build(BuildContext mContext) {
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
            body: PhysicianImpersonatorProfileWidget(
              physicianImpersonator: widget.physicianImpersonator,
              physicianImpersonatorSpeciality: _physicianImpersonatorSpeciality,
            )));
  }
}

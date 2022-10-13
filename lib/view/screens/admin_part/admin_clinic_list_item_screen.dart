import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_indicator/loading_indicator.dart';

import '../../../constants/app_colors.dart';
import '../../../model/clinic.dart';
import '../../../model/user_data.dart';
import '../../components/alert.dart';
import '../view_clinic_profile_screen.dart';

class AdminClinicListItemScreen extends StatefulWidget {
  final String specialityId;
  final AccountStatus accountStatus;

  const AdminClinicListItemScreen(
      {Key? key, required this.specialityId, required this.accountStatus})
      : super(key: key);

  @override
  _AdminClinicListItemScreenState createState() =>
      _AdminClinicListItemScreenState();
}

class _AdminClinicListItemScreenState extends State<AdminClinicListItemScreen> {
  Color primaryLightColor = AppColors.primaryColor;
  List<Color> primaryGradientColors = AppColors.primaryGradientColors;
  BuildContext? dialogContext;
  List<Clinic> clinics = <Clinic>[];
  FirebaseFirestore? _firebaseFirestore;
  late CollectionReference clinicsRef;

  @override
  void initState() {
    super.initState();
    _firebaseFirestore = FirebaseFirestore.instance;
    clinicsRef =
        _firebaseFirestore!.collection(FirestoreCollections.Clinics.name);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    LoadingIndicator dialog = loadingIndicatorWidget();
    return Column(
      children: [
        Flexible(
          child: StreamBuilder(
              stream: clinicsRef
                  .where('specialityId', isEqualTo: widget.specialityId)
                  .where('accountStatus', isEqualTo: widget.accountStatus.index)
                  .orderBy('name', descending: false)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  List<QueryDocumentSnapshot> docs = snapshot.data!.docs;
                  if (docs.isEmpty) {
                    return const Center(
                        child: Text('عفواً، لا يوجد بيانات!',
                            style: TextStyle(color: Colors.blue)));
                  }
                  Map map = (docs).asMap();
                  clinics.clear();
                  map.forEach((dynamic, json) {
                    clinics.add(Clinic.fromJson(json));
                  });
                  return Directionality(
                      textDirection: TextDirection.rtl,
                      child: ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, i) {
                            return Directionality(
                                textDirection: ui.TextDirection.rtl,
                                child: GestureDetector(
                                  onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ViewClinicProfileScreen(
                                                clinic: clinics[i],
                                                clinicId: docs[i].reference.id,
                                              ))),
                                  child: Card(
                                    clipBehavior: Clip.antiAlias,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: primaryGradientColors,
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ),
                                      ),
                                      height: 80,
                                      padding: const EdgeInsets.all(4),
                                      child: Row(children: [
                                        Expanded(
                                          flex: 4,
                                          child: Container(
                                            width: 70,
                                            height: 70,
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: Colors.white,
                                                  width: 2,
                                                ),
                                                image: clinics[i].logo == ''
                                                    ? null
                                                    : DecorationImage(
                                                        image: NetworkImage(
                                                            clinics[i].logo ??
                                                                ''),
                                                        fit: BoxFit.fill)),
                                          ),
                                        ),
                                        const Spacer(
                                          flex: 1,
                                        ),
                                        Expanded(
                                          flex: 14,
                                          child: Container(
                                            padding: const EdgeInsets.only(
                                                top: 5, bottom: 5),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Flexible(
                                                    flex: 5,
                                                    fit: FlexFit.loose,
                                                    child: Text(
                                                        clinics[i].name ?? '',
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 1,
                                                        textDirection:
                                                            TextDirection.rtl,
                                                        style: const TextStyle(
                                                            fontSize: 14.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Colors.white))),
                                                const Spacer(
                                                  flex: 1,
                                                ),
                                                Flexible(
                                                    flex: 3,
                                                    fit: FlexFit.loose,
                                                    child: Text(
                                                        clinics[i].address ??
                                                            '',
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 1,
                                                        textDirection:
                                                            TextDirection.rtl,
                                                        style: const TextStyle(
                                                            fontSize: 10.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: AppColors
                                                                .secondaryColor2))),
                                                const Spacer(
                                                  flex: 1,
                                                ),
                                                Flexible(
                                                    flex: 3,
                                                    fit: FlexFit.loose,
                                                    child: Text(
                                                        clinics[i]
                                                                .selectedCountry ??
                                                            '',
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 1,
                                                        textDirection:
                                                            TextDirection.rtl,
                                                        style: const TextStyle(
                                                            fontSize: 10.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: AppColors
                                                                .secondaryColor2))),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                            flex: 2,
                                            child: _getManageIconsColumn(
                                                docs[i].reference.path,
                                                dialog)),
                                      ]),
                                    ),
                                  ),
                                ));
                          }));
                } else if (snapshot.hasError) {
                  return const Center(
                      child: Text(
                    'عفواً، حدث خطأ ما!',
                    style: TextStyle(color: Colors.red),
                  ));
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                return const Center(
                    child: Text(
                  'عفواً، حدث خطأ ما!',
                  style: TextStyle(color: Colors.red),
                ));
              }),
        ),
      ],
    );
  }

  _getManageIconsColumn(String clinicPath, LoadingIndicator dialog) {
    switch (widget.accountStatus) {
      case AccountStatus.Pending:
        return _getPendingManageIconsColumn(clinicPath, dialog);
      case AccountStatus.Approved:
        return _getApprovedManageIconsColumn(clinicPath, dialog);
      default:
        return _getRejectedManageIconsColumn(clinicPath, dialog);
    }
  }

  _getPendingManageIconsColumn(String clinicPath, LoadingIndicator dialog) =>
      Column(children: [
        _approvedButton(clinicPath, dialog),
        const Spacer(
          flex: 1,
        ),
        _rejectedButton(clinicPath, dialog)
      ]);

  _getApprovedManageIconsColumn(String clinicPath, LoadingIndicator dialog) =>
      Column(children: [
        _pendingButton(clinicPath, dialog),
        const Spacer(
          flex: 1,
        ),
        _rejectedButton(clinicPath, dialog)
      ]);

  _getRejectedManageIconsColumn(String clinicPath, LoadingIndicator dialog) =>
      Column(children: [
        _pendingButton(clinicPath, dialog),
        const Spacer(
          flex: 1,
        ),
        _approvedButton(clinicPath, dialog)
      ]);

  _pendingButton(String clinicPath, LoadingIndicator dialog) => Flexible(
      flex: 2,
      fit: FlexFit.loose,
      child: IconButton(
        onPressed: () => _updateAccountStatusConfirmationDialog(
            clinicPath, AccountStatus.Pending, dialog),
        icon: const Icon(
          FontAwesomeIcons.faceFlushed,
          color: Colors.white,
          size: 20,
        ),
      ));

  _approvedButton(String clinicPath, LoadingIndicator dialog) => Flexible(
      flex: 2,
      fit: FlexFit.loose,
      child: IconButton(
        onPressed: () => _updateAccountStatusConfirmationDialog(
            clinicPath, AccountStatus.Approved, dialog),
        icon: const Icon(
          FontAwesomeIcons.faceSmile,
          color: Colors.white,
          size: 20,
        ),
      ));

  _rejectedButton(String clinicPath, LoadingIndicator dialog) => Flexible(
      flex: 2,
      fit: FlexFit.loose,
      child: IconButton(
        onPressed: () => _updateAccountStatusConfirmationDialog(
            clinicPath, AccountStatus.Rejected, dialog),
        icon: const Icon(
          FontAwesomeIcons.faceFrown,
          color: Colors.white,
          size: 20,
        ),
      ));

  void _updateAccountStatusConfirmationDialog(
      String clinicPath, AccountStatus newStatus, LoadingIndicator dialog) {
    showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        title: const Text(
          'تحديث حالة العيادة',
          style: TextStyle(color: Colors.black),
          textDirection: TextDirection.rtl,
        ),
        content: Text(
            'هل متأكد أنك تريد تحديث حالة العيادة إلى ${newStatus.name}؟',
            style: const TextStyle(color: Colors.black),
            textDirection: TextDirection.rtl),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'Cancel'),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) {
                    dialogContext = context;
                    return dialog;
                  });
              _firebaseFirestore!
                  .doc(clinicPath)
                  .update({"accountStatus": newStatus.index}).then((value) {
                Navigator.pop(dialogContext!);
                Navigator.pop(context, 'Ok');
              });
            },
            child: const Text('نعم'),
          ),
        ],
      ),
    );
  }
}

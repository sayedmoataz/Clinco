import 'dart:ui' as ui;

import 'package:clinico/model/labs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_indicator/loading_indicator.dart';

import '../../../constants/app_colors.dart';
import '../../../model/user_data.dart';
import '../../components/alert.dart';

class AdminLabsList extends StatefulWidget {
  final AccountStatus accountStatus;

  const AdminLabsList({Key? key, required this.accountStatus})
      : super(key: key);

  @override
  _AdminLabsListState createState() => _AdminLabsListState();
}

class _AdminLabsListState extends State<AdminLabsList> {
  Color primaryLightColor = AppColors.primaryColor;
  List<Color> primaryGradientColors = AppColors.primaryGradientColors;
  BuildContext? dialogContext;
  List<Labs> labs = <Labs>[];
  FirebaseFirestore? _firebaseFirestore;
  late CollectionReference labsRef, usersRef;

  @override
  void initState() {
    super.initState();
    _firebaseFirestore = FirebaseFirestore.instance;
    labsRef = _firebaseFirestore!.collection(FirestoreCollections.Labs.name);
    usersRef = _firebaseFirestore!.collection(FirestoreCollections.Users.name);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    LoadingIndicator dialog = loadingIndicatorWidget();
    return Column(
      children: [
        Flexible(
          child: StreamBuilder(
              stream: labsRef
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
                  labs.clear();
                  map.forEach((dynamic, json) {
                    labs.add(Labs.fromJson(json.data()));
                  });
                  return Directionality(
                      textDirection: TextDirection.rtl,
                      child: ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, i) {
                            return Directionality(
                                textDirection: ui.TextDirection.rtl,
                                child: GestureDetector(
                                  onTap: () => {
                                    // Navigator.of(context).push(MaterialPageRoute(builder: (context) => ViewUserProfileScreen(userAccountJsonMap: docs[i].data() as Map<String, dynamic>)))
                                  },
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
                                                image: labs[i].image == ''
                                                    ? null
                                                    : DecorationImage(
                                                        image: NetworkImage(
                                                          labs[i].image ?? '',
                                                        ),
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
                                                        labs[i].name ?? '',
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
                                                // const Spacer(flex: 1,),
                                                // Flexible(flex: 3, fit:  FlexFit.loose, child: Text(labs[i].doctorLevel ?? '', overflow: TextOverflow.ellipsis, maxLines: 1, textDirection: TextDirection.rtl, style: const TextStyle(fontSize: 10.0, fontWeight: FontWeight.bold, color: AppColors.secondaryColor2))),
                                                const Spacer(
                                                  flex: 1,
                                                ),
                                                Flexible(
                                                    flex: 3,
                                                    fit: FlexFit.loose,
                                                    child: Text(
                                                        labs[i].selectedCountry ??
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
                                                labs[i].userId!,
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

  _getManageIconsColumn(
      String doctorPath, String doctorUserId, LoadingIndicator dialog) {
    switch (widget.accountStatus) {
      case AccountStatus.Pending:
        return _getPendingManageIconsColumn(doctorPath, doctorUserId, dialog);
      case AccountStatus.Approved:
        return _getApprovedManageIconsColumn(doctorPath, doctorUserId, dialog);
      default:
        return _getRejectedManageIconsColumn(doctorPath, doctorUserId, dialog);
    }
  }

  _getPendingManageIconsColumn(
          String doctorPath, String doctorUserId, LoadingIndicator dialog) =>
      Column(children: [
        _approvedButton(doctorPath, doctorUserId, dialog),
        const Spacer(
          flex: 1,
        ),
        _rejectedButton(doctorPath, doctorUserId, dialog)
      ]);

  _getApprovedManageIconsColumn(
          String doctorPath, String doctorUserId, LoadingIndicator dialog) =>
      Column(children: [
        _pendingButton(doctorPath, doctorUserId, dialog),
        const Spacer(
          flex: 1,
        ),
        _rejectedButton(doctorPath, doctorUserId, dialog)
      ]);

  _getRejectedManageIconsColumn(
          String doctorPath, String doctorUserId, LoadingIndicator dialog) =>
      Column(children: [
        _pendingButton(doctorPath, doctorUserId, dialog),
        const Spacer(
          flex: 1,
        ),
        _approvedButton(doctorPath, doctorUserId, dialog)
      ]);

  _pendingButton(
          String doctorPath, String doctorUserId, LoadingIndicator dialog) =>
      Flexible(
          flex: 2,
          fit: FlexFit.loose,
          child: IconButton(
            onPressed: () => _updateAccountStatusConfirmationDialog(
                doctorPath, doctorUserId, AccountStatus.Pending, dialog),
            icon: const Icon(
              FontAwesomeIcons.faceFlushed,
              color: Colors.white,
              size: 20,
            ),
          ));

  _approvedButton(
          String doctorPath, String doctorUserId, LoadingIndicator dialog) =>
      Flexible(
          flex: 2,
          fit: FlexFit.loose,
          child: IconButton(
            onPressed: () => _updateAccountStatusConfirmationDialog(
                doctorPath, doctorUserId, AccountStatus.Approved, dialog),
            icon: const Icon(
              FontAwesomeIcons.faceSmile,
              color: Colors.white,
              size: 20,
            ),
          ));

  _rejectedButton(
          String doctorPath, String doctorUserId, LoadingIndicator dialog) =>
      Flexible(
          flex: 2,
          fit: FlexFit.loose,
          child: IconButton(
            onPressed: () => _updateAccountStatusConfirmationDialog(
                doctorPath, doctorUserId, AccountStatus.Rejected, dialog),
            icon: const Icon(
              FontAwesomeIcons.faceFrown,
              color: Colors.white,
              size: 20,
            ),
          ));

  void _updateAccountStatusConfirmationDialog(String doctorPath,
      String doctorUserId, AccountStatus newStatus, LoadingIndicator dialog) {
    showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        title: const Text(
          'تحديث حالة الطبيب',
          style: TextStyle(color: Colors.black),
          textDirection: TextDirection.rtl,
        ),
        content: Text(
            'هل متأكد أنك تريد تحديث حالة الطبيب إلى ${newStatus.name}؟',
            style: const TextStyle(color: Colors.black),
            textDirection: TextDirection.rtl),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'Cancel'),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              // print(AccountStatus.Approved.index);
              // print(AccountStatus.Rejected.index);
              // print(AccountStatus.Pending.index);
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) {
                    dialogContext = context;
                    return dialog;
                  });
              _firebaseFirestore!
                  .doc(doctorPath)
                  .update({"accountStatus": newStatus.index}).then((value) {
                usersRef
                    .doc(doctorUserId)
                    .update({'accountStatus': newStatus.index}).then((value) {
                  Navigator.pop(dialogContext!);
                  Navigator.pop(context, 'Ok');
                });
              });
            },
            child: const Text('نعم'),
          ),
        ],
      ),
    );
  }
}

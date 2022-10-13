import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_indicator/loading_indicator.dart';

import '../../../constants/app_colors.dart';
import '../../../model/company.dart';
import '../../../model/user_data.dart';
import '../../components/alert.dart';
import '../view_user_profile_screen.dart';

class AdminCompanyListItemScreen extends StatefulWidget {
  final AccountStatus accountStatus;

  const AdminCompanyListItemScreen({Key? key, required this.accountStatus})
      : super(key: key);

  @override
  _AdminCompanyListItemScreenState createState() =>
      _AdminCompanyListItemScreenState();
}

class _AdminCompanyListItemScreenState
    extends State<AdminCompanyListItemScreen> {
  Color primaryLightColor = AppColors.primaryColor;
  List<Color> primaryGradientColors = AppColors.primaryGradientColors;
  BuildContext? dialogContext;
  List<Company> companies = <Company>[];
  FirebaseFirestore? _firebaseFirestore;
  late CollectionReference companiesRef, usersRef;

  @override
  void initState() {
    super.initState();
    _firebaseFirestore = FirebaseFirestore.instance;
    companiesRef =
        _firebaseFirestore!.collection(FirestoreCollections.Companies.name);
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
              stream: companiesRef
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
                  companies.clear();
                  map.forEach((dynamic, json) {
                    companies.add(Company.fromJson(json.data()));
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
                                              ViewUserProfileScreen(
                                                  userAccountJsonMap:
                                                      docs[i].data() as Map<
                                                          String, dynamic>))),
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
                                                image: companies[i].image == ''
                                                    ? null
                                                    : DecorationImage(
                                                        image: NetworkImage(
                                                            companies[i]
                                                                    .image ??
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
                                                        companies[i].name ?? '',
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
                                                        companies[i].address ??
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
                                                        companies[i]
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
                                                companies[i].userId!,
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
      String companyPath, String companyUserId, LoadingIndicator dialog) {
    switch (widget.accountStatus) {
      case AccountStatus.Pending:
        return _getPendingManageIconsColumn(companyPath, companyUserId, dialog);
      case AccountStatus.Approved:
        return _getApprovedManageIconsColumn(
            companyPath, companyUserId, dialog);
      default:
        return _getRejectedManageIconsColumn(
            companyPath, companyUserId, dialog);
    }
  }

  _getPendingManageIconsColumn(
          String companyPath, String companyUserId, LoadingIndicator dialog) =>
      Column(children: [
        _approvedButton(companyPath, companyUserId, dialog),
        const Spacer(
          flex: 1,
        ),
        _rejectedButton(companyPath, companyUserId, dialog)
      ]);

  _getApprovedManageIconsColumn(
          String companyPath, String companyUserId, LoadingIndicator dialog) =>
      Column(children: [
        _pendingButton(companyPath, companyUserId, dialog),
        const Spacer(
          flex: 1,
        ),
        _rejectedButton(companyPath, companyUserId, dialog)
      ]);

  _getRejectedManageIconsColumn(
          String companyPath, String companyUserId, LoadingIndicator dialog) =>
      Column(children: [
        _pendingButton(companyPath, companyUserId, dialog),
        const Spacer(
          flex: 1,
        ),
        _approvedButton(companyPath, companyUserId, dialog)
      ]);

  _pendingButton(
          String companyPath, String companyUserId, LoadingIndicator dialog) =>
      Flexible(
          flex: 2,
          fit: FlexFit.loose,
          child: IconButton(
            onPressed: () => _updateAccountStatusConfirmationDialog(
                companyPath, companyUserId, AccountStatus.Pending, dialog),
            icon: const Icon(
              FontAwesomeIcons.faceFlushed,
              color: Colors.white,
              size: 20,
            ),
          ));

  _approvedButton(
          String companyPath, String companyUserId, LoadingIndicator dialog) =>
      Flexible(
          flex: 2,
          fit: FlexFit.loose,
          child: IconButton(
            onPressed: () => _updateAccountStatusConfirmationDialog(
                companyPath, companyUserId, AccountStatus.Approved, dialog),
            icon: const Icon(
              FontAwesomeIcons.faceSmile,
              color: Colors.white,
              size: 20,
            ),
          ));

  _rejectedButton(
          String companyPath, String companyUserId, LoadingIndicator dialog) =>
      Flexible(
          flex: 2,
          fit: FlexFit.loose,
          child: IconButton(
            onPressed: () => _updateAccountStatusConfirmationDialog(
                companyPath, companyUserId, AccountStatus.Rejected, dialog),
            icon: const Icon(
              FontAwesomeIcons.faceFrown,
              color: Colors.white,
              size: 20,
            ),
          ));

  void _updateAccountStatusConfirmationDialog(String companyPath,
      String companyUserId, AccountStatus newStatus, LoadingIndicator dialog) {
    showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        title: const Text(
          'تحديث حالة الشركة',
          style: TextStyle(color: Colors.black),
          textDirection: TextDirection.rtl,
        ),
        content: Text(
            'هل متأكد أنك تريد تحديث حالة الشركة إلى ${newStatus.name}؟',
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
                  .doc(companyPath)
                  .update({"accountStatus": newStatus.index}).then((value) {
                usersRef
                    .doc(companyUserId)
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

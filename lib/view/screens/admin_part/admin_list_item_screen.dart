import 'package:clinico/model/admin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../model/user_data.dart';
import '../view_user_profile_screen.dart';

class AdminListItemScreen extends StatefulWidget {
  const AdminListItemScreen({Key? key}) : super(key: key);

  @override
  _AdminListItemScreenState createState() => _AdminListItemScreenState();
}

class _AdminListItemScreenState extends State<AdminListItemScreen> {
  Color primaryLightColor = AppColors.primaryColor;
  List<Color> primaryGradientColors = AppColors.primaryGradientColors;
  BuildContext? dialogContext;
  List<Admin> admins = <Admin>[];
  FirebaseFirestore? _firebaseFirestore;
  late CollectionReference adminsRef;

  @override
  void initState() {
    super.initState();
    _firebaseFirestore = FirebaseFirestore.instance;
    adminsRef =
        _firebaseFirestore!.collection(FirestoreCollections.Admins.name);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('المشرفين',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: primaryGradientColors),
              ),
            ),
          ),
          body: StreamBuilder(
              stream: adminsRef.orderBy('name', descending: false).snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  List<QueryDocumentSnapshot> docs = snapshot.data!.docs;
                  if (docs.isEmpty) {
                    return const Center(
                        child: Text('عفواً، لا يوجد بيانات!',
                            style: TextStyle(color: Colors.blue)));
                  }
                  Map map = (docs).asMap();
                  admins.clear();
                  map.forEach((dynamic, json) {
                    admins.add(Admin.fromJson(json));
                  });
                  return Directionality(
                      textDirection: TextDirection.rtl,
                      child: ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, i) {
                            return Directionality(
                                textDirection: TextDirection.rtl,
                                child: GestureDetector(
                                  onTap: () => {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ViewUserProfileScreen(
                                                    userAccountJsonMap:
                                                        docs[i].data() as Map<
                                                            String, dynamic>)))
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
                                                image: DecorationImage(
                                                    image: NetworkImage(
                                                        admins[i].image ?? ''),
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
                                                        admins[i].name ?? '',
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
                                                        admins[i].email ?? '',
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
                                                        admins[
                                                                    i]
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
                                      ]),
                                    ),
                                  ),
                                ));
                          }));
                } else if (snapshot.hasError) {
                  return const Center(
                      child: Text(
                    'حدث خطأ ما!',
                    style: TextStyle(color: Colors.red),
                  ));
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                return const Center(
                    child: Text(
                  'حدث خطأ ما!',
                  style: TextStyle(color: Colors.red),
                ));
              }),
        ));
  }
}

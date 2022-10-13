import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../model/speciality.dart';
import '../screens/document_slides_screen.dart';
import 'back_clipper.dart';

class UserProfileWidget extends StatelessWidget {
  final Map<String, dynamic>? userAccountJsonMap;
  final Speciality? doctorSpeciality;

  const UserProfileWidget(
      {Key? key,
      required this.userAccountJsonMap,
      required this.doctorSpeciality})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    List<Color> primaryGradientColors = AppColors.primaryGradientColors;
    Color primaryLightColor = AppColors.primaryColor;
    final BackClipper _backClipper = BackClipper();

    return Column(
      children: <Widget>[
        Expanded(
            flex: 4,
            child: Stack(
              children: <Widget>[
                //background
                Column(
                  children: <Widget>[
                    Expanded(
                        flex: 2,
                        child: Container(
                            color: Colors.white,
                            child: ClipPath(
                              clipper: _backClipper,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: primaryGradientColors,
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                ),
                              ),
                            ))),
                  ],
                ),
                //forground
                SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Center(
                        child: Container(
                          height: 120.0,
                          width: 120.0,
                          padding: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(100.0)),
                          child: CircleAvatar(
                              backgroundColor: Colors.white,
                              backgroundImage: NetworkImage(
                                  userAccountJsonMap?['image'] ?? '')),
                        ),
                      ),
                      const SizedBox(
                        height: 5.0,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 35.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Column(
                              children: <Widget>[
                                Text(
                                  _getOptimizedUserName(),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(
                                  height: 4.0,
                                ),
                                Visibility(
                                  visible: userAccountJsonMap?['doctorLevel'] !=
                                          null &&
                                      userAccountJsonMap!['doctorLevel']!
                                          .toString()
                                          .isNotEmpty,
                                  child: buildDecoratedText(
                                      '${userAccountJsonMap?['doctorLevel'] ?? ''} | ${doctorSpeciality?.arabicTitle ?? ''}',
                                      size),
                                ),
                                const SizedBox(
                                  height: 4.0,
                                ),
                                buildDecoratedText(
                                    userAccountJsonMap?['email'] ?? '', size),
                                const SizedBox(
                                  height: 4.0,
                                ),
                                Visibility(
                                  visible: userAccountJsonMap?['phoneNumber'] !=
                                          null &&
                                      userAccountJsonMap!['phoneNumber']!
                                          .toString()
                                          .isNotEmpty,
                                  child: buildDecoratedText(
                                      userAccountJsonMap?['phoneNumber'] ?? '',
                                      size),
                                ),
                                const SizedBox(
                                  height: 4.0,
                                ),
                                Visibility(
                                  visible:
                                      userAccountJsonMap?['address'] != null &&
                                          userAccountJsonMap!['address']!
                                              .toString()
                                              .isNotEmpty,
                                  child: buildDecoratedText(
                                      userAccountJsonMap?['address'] ?? '',
                                      size),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            )),
        Expanded(
            flex: 4,
            child: Visibility(
              visible: userAccountJsonMap?['about'] != null &&
                      userAccountJsonMap!['about']!
                          .toString()
                          .trim()
                          .isNotEmpty ||
                  userAccountJsonMap?['documents'] != null &&
                      (userAccountJsonMap!['documents'] as List<dynamic>)
                          .isNotEmpty,
              child: ListView(
                children: [
                  Visibility(
                      visible: userAccountJsonMap?['about'] != null &&
                          userAccountJsonMap!['about']!
                              .toString()
                              .trim()
                              .isNotEmpty,
                      child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userAccountJsonMap?['doctorLevel'] != null
                                    ? 'من أنا؟'
                                    : 'من نحن؟',
                                style: const TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                height: 5.0,
                              ),
                              SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: Text(
                                  userAccountJsonMap?['about'] ?? '',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 15.0,
                                  ),
                                ),
                              )
                            ],
                          ))),
                  Visibility(
                      visible: userAccountJsonMap?['documents'] != null &&
                          (userAccountJsonMap!['documents'] as List<dynamic>)
                              .isNotEmpty,
                      child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: InkWell(
                            child: Text("شاهد مستندات الإعتماد",
                                style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    color: primaryLightColor)),
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => ImagesSlidesScreen(
                                      documents:
                                          userAccountJsonMap!['documents'],
                                      title: userAccountJsonMap!['name'])));
                            },
                          )))
                ],
              ),
            ))
      ],
    );
  }

  Widget buildDecoratedText(String text, Size size) => ConstrainedBox(
      constraints: BoxConstraints(
          minWidth: size.width * 0.1, maxWidth: size.width * 0.6),
      child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 10.0),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100.0),
              color: Colors.black12),
          child: Text(
            text,
            style: const TextStyle(
                color: Colors.white,
                fontFamily: 'is_l',
                fontSize: 13.0,
                fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )));

  String _getOptimizedUserName() {
    String? userName = userAccountJsonMap?['name'];
    if (userName == null) {
      return '';
    } else {
      List<String> splittedNameList = userName.split(' ');
      return splittedNameList.length > 1
          ? '${splittedNameList.first} ${splittedNameList.last}'
          : splittedNameList.first;
    }
  }
}

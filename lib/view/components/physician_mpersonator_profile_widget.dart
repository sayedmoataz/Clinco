import 'package:clinico/view/components/back_clipper.dart';
import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../model/physician_impersonator.dart';
import '../../model/speciality.dart';

class PhysicianImpersonatorProfileWidget extends StatelessWidget {
  final PhysicianImpersonator? physicianImpersonator;
  final Speciality? physicianImpersonatorSpeciality;

  const PhysicianImpersonatorProfileWidget(
      {Key? key,
      required this.physicianImpersonator,
      required this.physicianImpersonatorSpeciality})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    List<Color> primaryGradientColors = AppColors.primaryGradientColors;
    final BackClipper backClipper = BackClipper();

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
                              clipper: backClipper,
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
                                  physicianImpersonator?.logo ?? '')),
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
                                  physicianImpersonator?.name ?? '',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(
                                  height: 4.0,
                                ),
                                buildDecoratedText(
                                    physicianImpersonatorSpeciality
                                            ?.arabicTitle ??
                                        '',
                                    size),
                                const SizedBox(
                                  height: 4.0,
                                ),
                                Visibility(
                                  visible: physicianImpersonator?.doctorName !=
                                          null &&
                                      physicianImpersonator!.doctorName!
                                          .toString()
                                          .isNotEmpty,
                                  child: buildDecoratedText(
                                      physicianImpersonator?.doctorName ?? '',
                                      size),
                                ),
                                const SizedBox(
                                  height: 4.0,
                                ),
                                Visibility(
                                  visible:
                                      physicianImpersonator?.address != null &&
                                          physicianImpersonator!.address
                                              .toString()
                                              .isNotEmpty,
                                  child: buildDecoratedText(
                                      physicianImpersonator?.address ?? '',
                                      size),
                                ),
                                const SizedBox(
                                  height: 4.0,
                                ),
                                Visibility(
                                  visible: physicianImpersonator?.phoneNumber !=
                                          null &&
                                      physicianImpersonator!.phoneNumber!
                                          .toString()
                                          .isNotEmpty,
                                  child: buildDecoratedText(
                                      physicianImpersonator?.phoneNumber ?? '',
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
}

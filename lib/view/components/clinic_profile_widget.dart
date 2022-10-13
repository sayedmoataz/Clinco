import 'package:clinico/view/components/back_clipper.dart';
import 'package:flutter/material.dart';

import '../../constants/account_constants.dart';
import '../../constants/app_colors.dart';
import '../../model/clinic.dart';
import '../../model/doctor.dart';
import '../../model/speciality.dart';
import '../../model/user_data.dart';
import '../screens/document_slides_screen.dart';

class ClinicProfileWidget extends StatelessWidget {
  final String? accountType;
  final Clinic? clinic;
  final Doctor? doctor;
  final Speciality? clinicSpeciality;

  const ClinicProfileWidget(
      {Key? key,
      required this.accountType,
      required this.clinic,
      required this.doctor,
      required this.clinicSpeciality})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    List<Color> primaryGradientColors = AppColors.primaryGradientColors;
    Color primaryLightColor = AppColors.primaryColor;
    final BackClipper backClipper = BackClipper();
    return Column(
      children: <Widget>[
        // Center(
        //   child: Container(
        //     height: 120.0,
        //     width: 120.0,
        //     padding: const EdgeInsets.all(10.0),
        //     decoration: BoxDecoration(
        //         color: Colors.white,
        //         borderRadius: BorderRadius.circular(100.0)),
        //     child: CircleAvatar(backgroundColor: Colors.white, backgroundImage: NetworkImage(clinic?.logo ?? '')),),
        // ),
        Image(
          width: double.infinity,
          height: 200,
          fit: BoxFit.cover,
          image: NetworkImage(clinic?.logo ?? ''),
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
                    clinic?.name ?? '',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(
                    height: 4.0,
                  ),
                  buildDecoratedText(clinicSpeciality?.arabicTitle ?? '', size),
                  const SizedBox(
                    height: 4.0,
                  ),
                  buildDecoratedText(
                      'الكشف المتاح: ${AccountConstants.clinicRevealWays[clinic!.revealWay] ?? ''}',
                      size),
                  const SizedBox(
                    height: 4.0,
                  ),
                  Visibility(
                    visible: doctor?.name != null &&
                        doctor!.name!.toString().isNotEmpty,
                    child: buildDecoratedText(
                        '${doctor?.doctorLevel ?? ''} | ${doctor?.name ?? ''}',
                        size),
                  ),
                  const SizedBox(
                    height: 4.0,
                  ),
                  Visibility(
                    visible: clinic?.address != null &&
                        clinic!.address.toString().isNotEmpty &&
                        accountType == AccountTypes.Admin.name,
                    child: buildDecoratedText(clinic?.address ?? '', size),
                  ),
                  const SizedBox(
                    height: 4.0,
                  ),
                  Visibility(
                    visible: clinic?.phoneNumber != null &&
                        clinic!.phoneNumber!.toString().isNotEmpty &&
                        accountType == AccountTypes.Admin.name,
                    child: buildDecoratedText(clinic?.phoneNumber ?? '', size),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(),
        Expanded(
          child: Visibility(
            visible: clinic?.about != null &&
                    clinic!.about.toString().trim().isNotEmpty ||
                clinic?.images != null &&
                    (clinic!.images as List<dynamic>).isNotEmpty ||
                clinic?.documents != null &&
                    (clinic!.documents as List<dynamic>).isNotEmpty,
            child: ListView(
              children: [
                Visibility(
                    visible: clinic?.about != null &&
                        clinic!.about.toString().trim().isNotEmpty,
                    child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'من نحن؟',
                              style: TextStyle(
                                fontSize: 24,
                              ),
                            ),
                            const SizedBox(
                              height: 5.0,
                            ),
                            SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Text(
                                clinic?.about ?? '',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 17.0,
                                ),
                              ),
                            )
                          ],
                        ))),
                Visibility(
                    visible: clinic?.images != null &&
                        (clinic!.images as List<dynamic>).isNotEmpty,
                    child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: InkWell(
                          child: Text("شاهد صور العيادة",
                              style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: primaryLightColor,
                                  fontSize: 15)),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => ImagesSlidesScreen(
                                    documents: clinic?.images ?? [],
                                    title: clinic?.name ?? '')));
                          },
                        ))),
                Visibility(
                    visible: clinic?.documents != null &&
                        (clinic!.documents as List<dynamic>).isNotEmpty,
                    child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: InkWell(
                          child: Text("شاهد مستندات الإعتماد",
                              style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: primaryLightColor,
                                  fontSize: 15)),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => ImagesSlidesScreen(
                                    documents: clinic?.documents ?? [],
                                    title: clinic?.name ?? '')));
                          },
                        ))),
                Visibility(
                    visible: (accountType == AccountTypes.Admin.name ||
                            accountType == AccountTypes.Doctor.name) &&
                        clinic!.trainingIsAvailable,
                    child: const Padding(
                        padding: EdgeInsets.all(2),
                        child: Text('* متاح تدريب لدى العيادة',
                            style: TextStyle(
                                color: AppColors.secondaryColor4,
                                fontSize: 15)))),
                Visibility(
                    visible: (accountType == AccountTypes.Admin.name ||
                            accountType == AccountTypes.Doctor.name) &&
                        clinic!.workIsAvailable,
                    child: const Padding(
                        padding: EdgeInsets.all(2),
                        child: Text('* متاح عمل لدى العيادة',
                            style: TextStyle(
                                color: AppColors.secondaryColor4,
                                fontSize: 15))))
              ],
            ),
          ),
        ),
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
              color: AppColors.appPrimaryColor),
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

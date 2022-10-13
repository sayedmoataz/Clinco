import 'package:clinico/model/more_info_image.dart';
import 'package:clinico/model/more_list_item.dart';
import 'package:clinico/view/screens/fragments/profile_fragment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:line_icons/line_icons.dart';
import 'package:share_plus/share_plus.dart';

import '../../../constants/app_colors.dart';
import '../../../helper/shared_preferences.dart';
import '../../../model/user_data.dart';
import '../../all_clinics_map.dart';
import '../../components/logout_widget.dart';
import '../about_us_screen.dart';
import '../admin_part/admin_clinics_appointments_screen.dart';
import '../admin_part/admin_list_item_screen.dart';
import '../admin_part/admin_update_doctor_level_request_list_screen.dart';
import '../admin_part/admin_update_doctor_speciality_request_list_screen.dart';
import '../admin_part/ads_manager_screen.dart';
import '../admin_part/patient_list_item_screen.dart';
import '../bmi_calculator/screens/bmi_input_page.dart';
import '../contact_us_screen.dart';
import '../guides_screen.dart';
import '../patient_part/fragments/patient_clinics_appointments_fragment.dart';
import '../physician_impersonator_list_item_screen.dart';

class MoreFragment extends StatefulWidget {
  const MoreFragment({Key? key}) : super(key: key);

  @override
  _MoreFragmentState createState() => _MoreFragmentState();
}

class _MoreFragmentState extends State<MoreFragment> {
  // Color AppColors.appPrimaryColor = AppColors.primaryColor;
  List<MoreInfoImage> moreInfoImages = <MoreInfoImage>[];
  late CollectionReference moreInfoImagesRef;
  late final AppData _appData;
  String? _selectedCountry, _accountType = AccountTypes.Patient.name;
  List<MoreListItem> items = [
    MoreListItem(false, LineIcons.users, 0, 'من نحن', null, null,
        MoreListItemOnTapFunctionKey.aboutUs),
    MoreListItem(false, LineIcons.weight, 0, 'حساب مؤشر كتلة الجسم BMI', null,
        null, MoreListItemOnTapFunctionKey.bmiCalculator),
    MoreListItem(false, LineIcons.mailBulk, 0, 'وسائل التواصل', null, null,
        MoreListItemOnTapFunctionKey.contactUs),
    MoreListItem(false, LineIcons.share, 0, 'دعوة صديق', null, null,
        MoreListItemOnTapFunctionKey.inviteFriend),
    MoreListItem(false, LineIcons.alternateSignOut, 0, 'تسجيل الخروج', null,
        null, MoreListItemOnTapFunctionKey.logout)
  ];

  @override
  void initState() {
    moreInfoImagesRef = FirebaseFirestore.instance
        .collection(FirestoreCollections.MoreInfoImages.name);
    _appData = AppData();
    _appData.getSharedPreferencesInstance().then((pref) {
      setState(() {
        _accountType = _appData.getAccountType(pref!)!;
        if (_accountType == AccountTypes.Doctor.name ||
            _accountType == AccountTypes.Admin.name) {
          items.insert(
              items.length - 1,
              MoreListItem(
                  false,
                  FontAwesomeIcons.personThroughWindow,
                  0,
                  'منتحلي صفة الأطباء',
                  null,
                  null,
                  MoreListItemOnTapFunctionKey.physicianImpersonators));
          if (_accountType == AccountTypes.Doctor.name) {
            items.insert(
                items.length - 1,
                MoreListItem(false, FontAwesomeIcons.house, 0, 'العيادات', null,
                    null, MoreListItemOnTapFunctionKey.doctorClinicsMap));
            items.insert(
                items.length - 1,
                MoreListItem(
                    false,
                    FontAwesomeIcons.calendarDay,
                    0,
                    'حجوزاتي لدى العيادات الأخرى',
                    null,
                    null,
                    MoreListItemOnTapFunctionKey
                        .doctorAppointmentsInAnotherClinics));
            items.insert(
                items.length - 1,
                MoreListItem(
                    false,
                    FontAwesomeIcons.personChalkboard,
                    0,
                    'الإرشادات',
                    null,
                    null,
                    MoreListItemOnTapFunctionKey.guides));
          } else if (_accountType == AccountTypes.Admin.name) {
            items.insert(
                items.length - 1,
                MoreListItem(false, FontAwesomeIcons.userTie, 0, 'المشرفين',
                    null, null, MoreListItemOnTapFunctionKey.admins));
            items.insert(
                items.length - 1,
                MoreListItem(false, FontAwesomeIcons.bed, 0, 'المرضى', null,
                    null, MoreListItemOnTapFunctionKey.patients));
            items.insert(
                items.length - 1,
                MoreListItem(
                    false,
                    FontAwesomeIcons.calendarDay,
                    0,
                    'حجوزات العيادات',
                    null,
                    null,
                    MoreListItemOnTapFunctionKey.adminClinicsAppointments));
            items.insert(
                items.length - 1,
                MoreListItem(
                    false,
                    FontAwesomeIcons.userDoctor,
                    0,
                    'طلبات تغيير مستوى الطبيب',
                    null,
                    null,
                    MoreListItemOnTapFunctionKey.updateDoctorLevelRequests));
            items.insert(
                items.length - 1,
                MoreListItem(
                    false,
                    FontAwesomeIcons.stethoscope,
                    0,
                    'طلبات تغيير تخصص الطبيب',
                    null,
                    null,
                    MoreListItemOnTapFunctionKey
                        .updateDoctorSpecialityRequests));
            items.insert(
                items.length - 1,
                MoreListItem(
                    false,
                    FontAwesomeIcons.desktop,
                    0,
                    'إدارة إعلانات الأجهزة الطبية',
                    null,
                    null,
                    MoreListItemOnTapFunctionKey.DevicesAdsManager));
            items.insert(
                items.length - 1,
                MoreListItem(
                    false,
                    FontAwesomeIcons.heartPulse,
                    0,
                    'إدارة إعلانات العيادات',
                    null,
                    null,
                    MoreListItemOnTapFunctionKey.ClinicsAdsManager));
          }
        }
        if (_accountType == AccountTypes.Patient.name) {
          items.removeAt(1);
          items.insert(
              1,
              MoreListItem(false, LineIcons.user, 0, 'الصفحة الشخصية', null,
                  null, MoreListItemOnTapFunctionKey.profile));
        }
        // if(_accountType == AccountTypes.Lab.name){
        //   items.insert(items.length - 1, MoreListItem(false, FontAwesomeIcons.heartPulse, 0, 'إدارة إعلانات العيادات', null, null, MoreListItemOnTapFunctionKey.ClinicsAdsManager));
        // }
      });
      _selectedCountry = _appData.getSelectedCountry(pref!)!;
      moreInfoImagesRef
          .orderBy('title', descending: false)
          .where('selectedCountry', isEqualTo: _selectedCountry)
          .get()
          .then((value) {
        List<DocumentSnapshot> documents = value.docs;
        for (var document in documents) {
          MoreInfoImage infoImage = MoreInfoImage.fromJson(document.data());
          setState(() {
            items.insert(
                0,
                MoreListItem(
                    true, null, null, null, null, infoImage.image, null));
          });
        }
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) => getMoreItemWidgets();

  getMoreItemWidgets() => Directionality(
      textDirection: TextDirection.rtl,
      child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) => items[index].isInfoImage
              ? _buildInfoImageItemWidget(items[index])
              : _buildMoreItemWidget(items[index])));

  _buildInfoImageItemWidget(MoreListItem item) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: AspectRatio(
          aspectRatio: 3 / 1,
          child: Container(
            margin:
                const EdgeInsets.only(top: 15, bottom: 15, right: 10, left: 10),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.0),
                boxShadow: const [
                  BoxShadow(
                      spreadRadius: 1.0, blurRadius: 5.0, color: Colors.grey)
                ]),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(10.0), bottom: Radius.circular(10.0)),
              child: Image(
                width: 150.0,
                fit: BoxFit.fill,
                image: NetworkImage(item.infoImage!),
              ),
            ),
          )),
    );
  }

  _buildMoreItemWidget(MoreListItem item) {
    return Column(
      children: [
        Card(
          color: Colors.white,
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: InkWell(
              onTap: () => getOnTapFunction(item),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        item.icon,
                        color: AppColors.appPrimaryColor,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        item.title!,
                        style: TextStyle(
                            fontSize: 18, color: AppColors.appPrimaryColor),
                      )
                    ],
                  ),
                  Icon(
                    FontAwesomeIcons.angleLeft,
                    color: AppColors.appPrimaryColor,
                    size: 14,
                  )
                ],
              ),
              // child: ListTile(title: Text(item.title!, style: TextStyle(fontSize: 16, color: AppColors.appPrimaryColor),),
              //   leading: RotatedBox(quarterTurns: item.iconRotateTurnsTimes!, child: Icon(item.icon, color: AppColors.appPrimaryColor,)),
              //   trailing: Icon(FontAwesomeIcons.angleLeft, color: AppColors.appPrimaryColor, size: 14,),
              //   contentPadding: EdgeInsets.all(0),
              // ),
            ),
          ),
        ),
        const Divider()
      ],
    );
  }

  void getOnTapFunction(MoreListItem item) {
    switch (item.moreListItemOnTapFunctionKey) {
      case MoreListItemOnTapFunctionKey.aboutUs:
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AboutUsScreen()));
        break;
      case MoreListItemOnTapFunctionKey.profile:
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const ProfileFragment()));
        break;
      case MoreListItemOnTapFunctionKey.doctorAppointmentsInAnotherClinics:
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const PatientClinicsAppointmentsFragment(
                  screenTitle: 'حجوزاتي لدى العيادات الأخرى',
                )));
        break;
      case MoreListItemOnTapFunctionKey.guides:
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const GuidesScreen()));
        break;
      case MoreListItemOnTapFunctionKey.bmiCalculator:
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const BmiInputPage()));
        break;
      case MoreListItemOnTapFunctionKey.contactUs:
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const ContactUsScreen()));
        break;
      case MoreListItemOnTapFunctionKey.inviteFriend:
        Share.share('https://l.linklyhq.com/l/1IEff');
        break;
      case MoreListItemOnTapFunctionKey.physicianImpersonators:
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const PhysicianImpersonatorListItemScreen()));
        break;
      case MoreListItemOnTapFunctionKey.doctorClinicsMap:
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => AllClinicsMap(
                  isPatient: true,
                )));
        break;
      case MoreListItemOnTapFunctionKey.admins:
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const AdminListItemScreen()));
        break;
      case MoreListItemOnTapFunctionKey.patients:
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const PatientListItemScreen()));
        break;
      case MoreListItemOnTapFunctionKey.adminClinicsAppointments:
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const AdminClinicsAppointmentsScreen()));
        break;
      case MoreListItemOnTapFunctionKey.updateDoctorLevelRequests:
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) =>
                const AdminUpdateDoctorLevelRequestListScreen()));
        break;
      case MoreListItemOnTapFunctionKey.updateDoctorSpecialityRequests:
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) =>
                const AdminUpdateDoctorSpecialityRequestListScreen()));
        break;
      case MoreListItemOnTapFunctionKey.DevicesAdsManager:
        Navigator.of(context).push(MaterialPageRoute(
            builder:
                (context) => // AdsManagerScreen(adsType: 'الأجهزة الطبية', firebaseCollections: FirestoreCollections.DevicesAds)));
                    AdsManagerScreen(
                      isDevicesAds: true,
                    )));
        break;
      case MoreListItemOnTapFunctionKey.ClinicsAdsManager:
        Navigator.of(context).push(MaterialPageRoute(
            builder:
                (context) => //AdsManagerScreen(adsType: 'العيادات', firebaseCollections: FirestoreCollections.ClinicsAds)));
                    AdsManagerScreen(
                      isDevicesAds: false,
                    )));
        break;
      default:
        LogoutWidget().showLogoutDialog(context);
    }
  }
}

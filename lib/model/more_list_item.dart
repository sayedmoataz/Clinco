import 'package:flutter/cupertino.dart';

class MoreListItem {
  bool isInfoImage;
  IconData? icon;
  int? iconRotateTurnsTimes;
  String? title, infoImage;
  dynamic fun;
  MoreListItemOnTapFunctionKey? moreListItemOnTapFunctionKey;

  MoreListItem(this.isInfoImage, this.icon, this.iconRotateTurnsTimes,
      this.title, this.fun, this.infoImage, this.moreListItemOnTapFunctionKey);
}

enum MoreListItemOnTapFunctionKey {
  profile,
  aboutUs,
  physicianImpersonators,
  doctorAppointmentsInAnotherClinics,
  guides,
  bmiCalculator,
  contactUs,
  inviteFriend,
  admins,
  patients,
  adminClinicsAppointments,
  updateDoctorLevelRequests,
  updateDoctorSpecialityRequests,
  doctorClinicsMap,
  DevicesAdsManager,
  ClinicsAdsManager,
  logout
}

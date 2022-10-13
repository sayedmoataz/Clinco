class UserData {
  String? email, selectedCountry, accountType;
  int accountStatus = 0;

  UserData(
      this.email, this.selectedCountry, this.accountType, this.accountStatus);

  Map<String, dynamic> toJson() => {
        'email': email,
        'selectedCountry': selectedCountry,
        'accountType': accountType,
        'accountStatus': accountStatus,
      };

  UserData.fromJson(dynamic json) {
    email = json['email'];
    selectedCountry = json['selectedCountry'];
    accountType = json['accountType'];
    accountStatus = json['accountStatus'];
  }
}

enum Countries { Egypt, KSA }

enum AccountTypes { Patient, Admin, Doctor, Company, RaysCenter, Lab }

enum AccountStatus { Pending, Approved, Rejected }

enum FirestoreCollections {
  PhysicianImpersonators,
  Users,
  Patients,
  Admins,
  Doctors,
  Companies,
  Clinics,
  ClinicBookingRequests,
  ClinicAvailableDays,
  ClinicAvailableTimes,
  ClinicsAds,
  ContactUs,
  DevicesCategories,
  Devices,
  DevicesAds,
  Guides,
  Steps,
  MoreInfoImages,
  Specialties,
  UpdateDoctorLevelRequests,
  UpdateDoctorSpecialityRequests,
  Labs,
  RaysCenter
}

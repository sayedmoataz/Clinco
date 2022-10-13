import 'package:clinico/constants/account_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PhysicianImpersonator {
  String? createdBy,
      logo,
      name,
      doctorName,
      specialityId,
      address,
      phoneNumber,
      selectedCountry;
  GeoPoint? geoLocation;

  PhysicianImpersonator(
      this.createdBy,
      this.logo,
      this.name,
      this.doctorName,
      this.specialityId,
      this.address,
      this.phoneNumber,
      this.selectedCountry,
      this.geoLocation);

  PhysicianImpersonator.fromJson(dynamic json) {
    createdBy = json['createdBy'];
    logo = json['logo'];
    name = json['name'];
    doctorName = json['doctorName'];
    specialityId = json['specialityId'];
    address = json['address'];
    phoneNumber = json['phoneNumber'];
    selectedCountry = json['selectedCountry'];
    geoLocation = json['geoLocation'];
  }

  Map<String, dynamic> toJson() => {
        'createdBy': createdBy,
        'logo': logo,
        'name': name,
        'doctorName': doctorName,
        'specialityId': specialityId,
        'address': address,
        'phoneNumber': phoneNumber,
        'selectedCountry': selectedCountry,
        'geoLocation': geoLocation,
      };

  LatLng get latLngLocation => (geoLocation != null)
      ? LatLng(geoLocation!.latitude, geoLocation!.longitude)
      : AccountConstants.defaultInitialMapLocation;
}

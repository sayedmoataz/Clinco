import 'package:clinico/constants/account_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Clinic {
  String? doctorUserId,
      logo,
      name,
      about,
      specialityId,
      address,
      phoneNumber,
      selectedCountry;
  GeoPoint? geoLocation;
  int accountStatus = 0, price = 0, revealWay = 0, paymentWay = 0;
  List<dynamic>? images, documents;
  bool isBookingFromClinicOnly = false,
      trainingIsAvailable = false,
      workIsAvailable = false;

  Clinic(
      this.doctorUserId,
      this.logo,
      this.name,
      this.about,
      this.specialityId,
      this.address,
      this.phoneNumber,
      this.selectedCountry,
      this.geoLocation,
      this.accountStatus,
      this.price,
      this.revealWay,
      this.paymentWay,
      this.images,
      this.documents,
      this.isBookingFromClinicOnly,
      this.trainingIsAvailable,
      this.workIsAvailable);

  Clinic.fromJson(dynamic json) {
    doctorUserId = json['doctorUserId'];
    logo = json['logo'];
    name = json['name'];
    about = json['about'];
    specialityId = json['specialityId'];
    address = json['address'];
    phoneNumber = json['phoneNumber'];
    selectedCountry = json['selectedCountry'];
    geoLocation = json['geoLocation'];
    accountStatus = json['accountStatus'];
    price = json['price'];
    revealWay = json['revealWay'];
    paymentWay = json['paymentWay'];
    images = json['images'];
    documents = json['documents'];
    isBookingFromClinicOnly = json['isBookingFromClinicOnly'];
    trainingIsAvailable = json['trainingIsAvailable'];
    workIsAvailable = json['workIsAvailable'];
  }

  Map<String, dynamic> toJson() => {
        'doctorUserId': doctorUserId,
        'logo': logo,
        'name': name,
        'about': about,
        'specialityId': specialityId,
        'address': address,
        'phoneNumber': phoneNumber,
        'selectedCountry': selectedCountry,
        'geoLocation': geoLocation,
        'accountStatus': accountStatus,
        'price': price,
        'revealWay': revealWay,
        'paymentWay': paymentWay,
        'images': images,
        'documents': documents,
        'isBookingFromClinicOnly': isBookingFromClinicOnly,
        'trainingIsAvailable': trainingIsAvailable,
        'workIsAvailable': workIsAvailable,
      };

  LatLng get latLngLocation => (geoLocation != null)
      ? LatLng(geoLocation!.latitude, geoLocation!.longitude)
      : AccountConstants.defaultInitialMapLocation;
}

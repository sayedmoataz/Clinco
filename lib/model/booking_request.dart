import 'package:cloud_firestore/cloud_firestore.dart';

class BookingRequest {
  String? doctorUserId,
      patientUserId,
      patientId,
      clinicId,
      patientName,
      patientPhoneNumber,
      patientEmail,
      symptoms,
      country,
      timeRangeDocumentId;
  Timestamp? date;
  int appointmentStatus = 0,
      patientGender = 0,
      patientAge = 0,
      revealWay = 0,
      paymentWay = 0,
      price = 0,
      accountType = 0,
      durationInMinutes = 0;
  bool isPaid = false;
  String? success;
  String? pending;


  BookingRequest(
      this.doctorUserId,
      this.patientUserId,
      this.patientId,
      this.clinicId,
      this.patientName,
      this.patientPhoneNumber,
      this.patientEmail,
      this.symptoms,
      this.country,
      this.timeRangeDocumentId,
      this.date,
      this.appointmentStatus,
      this.patientGender,
      this.patientAge,
      this.revealWay,
      this.paymentWay,
      this.price,
      this.accountType,
      this.durationInMinutes,
      this.isPaid,
      this.success,
      this.pending);

  Map<String, dynamic> toJson() => {
        'doctorUserId': doctorUserId,
        'patientUserId': patientUserId,
        'patientId': patientId,
        'clinicId': clinicId,
        'patientName': patientName,
        'patientPhoneNumber': patientPhoneNumber,
        'patientEmail': patientEmail,
        'symptoms': symptoms,
        'country': country,
        'timeRangeDocumentId': timeRangeDocumentId,
        'date': date,
        'appointmentStatus': appointmentStatus,
        'patientGender': patientGender,
        'patientAge': patientAge,
        'revealWay': revealWay,
        'paymentWay': paymentWay,
        'price': price,
        'accountType': accountType,
        'durationInMinutes': durationInMinutes,
        'isPaid': isPaid,
        'paymenyOrderID' : success,
        'paymentAuthToken' : pending
      };

  BookingRequest.fromJson(dynamic json) {
    doctorUserId = json['doctorUserId'] ?? "";
    patientUserId = json['patientUserId'] ?? "";
    patientId = json['patientId'] ?? "";
    clinicId = json['clinicId'] ?? "";
    patientName = json['patientName'] ?? "";
    patientPhoneNumber = json['patientPhoneNumber'] ?? "";
    patientEmail = json['patientEmail'] ?? "";
    symptoms = json['symptoms'];
    country = json['country'];
    timeRangeDocumentId = json['timeRangeDocumentId'];
    date = json['date'];
    appointmentStatus = json['appointmentStatus'];
    patientGender = json['patientGender'];
    patientAge = json['patientAge'];
    revealWay = json['revealWay'];
    paymentWay = json['paymentWay'];
    price = json['price'];
    accountType = json['accountType'];
    durationInMinutes = json['durationInMinutes'];
    isPaid = json['isPaid'];
    success = json['paymenyOrderID'];
    pending = json['paymentAuthToken'];
  }

  String get minuteText => (durationInMinutes < 11) ? 'دقائق' : 'دقيقة';

  bool get isBookingExpired =>
      (appointmentStatus == 0) &&
      ((date!.toDate().add(Duration(minutes: durationInMinutes)))
          .isBefore(DateTime.now()));

  bool isCallJoinEnable(bool isAdmin) =>
      !isAdmin &&
      (appointmentStatus == 0) &&
      (revealWay == 1) &&
      (DateTime.now()
              .isAfter(date!.toDate().subtract(const Duration(minutes: 2))) &&
          DateTime.now().isBefore(
              date!.toDate().add(Duration(minutes: durationInMinutes))));
}

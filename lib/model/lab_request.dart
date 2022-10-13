import 'package:cloud_firestore/cloud_firestore.dart';

class LabRequestModel {
  Timestamp? date;
  String? address;
  String? image;
  String? name;
  String? userId;
  String? phoneNumber;
  String? requestId;
  String? labId;
  String? labName;
  int? requestStatus;

  LabRequestModel.fromJson(Map<String, dynamic> json) {
    date = json["date"] ?? DateTime.now();
    address = json["address"] ?? "";
    image = json["image"] ?? "";
    name = json["name"] ?? "";
    userId = json["userId"] ?? "";
    phoneNumber = json["phoneNumber"] ?? "";
    requestId = json["requestId"] ?? "";
    labId = json["labId"] ?? "";
    labName = json["labName"] ?? "";
    requestStatus = json["requestStatus"] ?? 8;
  }
}

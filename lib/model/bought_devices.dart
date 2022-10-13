import 'package:cloud_firestore/cloud_firestore.dart';

class DevicesHistory {
  String? createdBy,
      name,
      selectedCountry,
      type,
      manufacture,
      description,
      id,
      buyer;
  Timestamp? date;
  int? price, warranty;
  List<dynamic>? images;
  bool isAvailableForPatient = false;

  DevicesHistory.fromJson(dynamic json) {
    createdBy = json['createdBy'] ?? "";
    name = json['name'] ?? "";
    selectedCountry = json['selectedCountry'] ?? "";
    price = json['price'] ?? 0;
    warranty = json['warranty'] ?? 0;
    type = json['type'] ?? "";
    manufacture = json['manufacture'] ?? "";
    description = json['description'] ?? "";
    images = json['images'] ?? [];
    id = json["collId"] ?? "";
    buyer = json["buyer"] ?? "";
    date = json["date"] ?? DateTime.now();
  }
}

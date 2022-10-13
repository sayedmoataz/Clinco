import 'package:cloud_firestore/cloud_firestore.dart';

class Ad {
  String? createdBy, title, image, selectedCountry, redirectLink;
  int? priority;
  bool isActive = false;
  Timestamp? expiryDate;

  Ad(this.createdBy, this.title, this.image, this.selectedCountry,
      this.redirectLink, this.priority, this.isActive, this.expiryDate);

  Ad.fromJson(dynamic json) {
    createdBy = json['createdBy'];
    title = json['title'];
    image = json['image'];
    selectedCountry = json['selectedCountry'];
    redirectLink = json['redirectLink'];
    priority = json['priority'];
    isActive = json['isActive'];
    expiryDate = json['expiryDate'];
  }

  Map<String, dynamic> toJson() => {
        'createdBy': createdBy,
        'title': title,
        'image': image,
        'selectedCountry': selectedCountry,
        'redirectLink': redirectLink,
        'priority': priority,
        'isActive': isActive,
        'expiryDate': expiryDate,
      };
}

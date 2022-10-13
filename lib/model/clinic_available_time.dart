import 'package:cloud_firestore/cloud_firestore.dart';

class ClinicAvailableTime {
  Timestamp? time;
  bool isAvailable = false;

  ClinicAvailableTime(this.time, this.isAvailable);

  Map<String, dynamic> toJson() => {'time': time, 'isAvailable': isAvailable};

  ClinicAvailableTime.fromJson(dynamic json) {
    time = json['time'];
    isAvailable = json['isAvailable'];
  }
}

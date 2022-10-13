import 'package:cloud_firestore/cloud_firestore.dart';

class ClinicAvailableTimeRange {
  Timestamp? startAt, endAt;
  int? duration;

  ClinicAvailableTimeRange(this.startAt, this.endAt, this.duration);

  Map<String, dynamic> toJson() => {
        'startAt': startAt,
        'endAt': endAt,
        'duration': duration,
      };

  ClinicAvailableTimeRange.fromJson(dynamic json) {
    startAt = json['startAt'];
    endAt = json['endAt'];
    duration = json['duration'];
  }
}

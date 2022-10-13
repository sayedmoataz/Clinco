class ClinicAvailableDay {
  String? dayName;

  ClinicAvailableDay(this.dayName);

  Map<String, dynamic> toJson() => {
        'dayName': dayName,
      };

  ClinicAvailableDay.fromJson(dynamic json) {
    dayName = json['dayName'];
  }
}



class LabOpeningHoursModel {
  String? day;
  TimeODModel? start;
  TimeODModel? end;

  LabOpeningHoursModel({
    required this.day,
    required this.start,
    required this.end,
  });

  LabOpeningHoursModel.fromJson(Map<String, dynamic> json) {
    day = json.keys.first;
    start = TimeODModel.fromJson(json["start"]);
    end = TimeODModel.fromJson(json["end"]);
  }
}

class TimeODModel {
  int? hour;
  int? min;

  TimeODModel({required this.hour, required this.min});

  TimeODModel.fromJson(Map<String, dynamic> json) {
    hour = json["hour"];
    min = json["min"];
  }
}

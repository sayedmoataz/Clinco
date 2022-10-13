class UpdateDoctorLevelRequest {
  String? doctorDocumentReferencePath, newLevel;

  UpdateDoctorLevelRequest(this.doctorDocumentReferencePath, this.newLevel);

  Map<String, dynamic> toJson() => {
        'doctorDocumentReferencePath': doctorDocumentReferencePath,
        'newLevel': newLevel
      };

  UpdateDoctorLevelRequest.fromJson(dynamic json) {
    doctorDocumentReferencePath = json['doctorDocumentReferencePath'];
    newLevel = json['newLevel'];
  }
}

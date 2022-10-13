class UpdateDoctorSpecialityRequest {
  String? doctorDocumentReferencePath, newSpecialityId;

  UpdateDoctorSpecialityRequest(
      this.doctorDocumentReferencePath, this.newSpecialityId);

  Map<String, dynamic> toJson() => {
        'doctorDocumentReferencePath': doctorDocumentReferencePath,
        'newSpecialityId': newSpecialityId
      };

  UpdateDoctorSpecialityRequest.fromJson(dynamic json) {
    doctorDocumentReferencePath = json['doctorDocumentReferencePath'];
    newSpecialityId = json['newSpecialityId'];
  }
}

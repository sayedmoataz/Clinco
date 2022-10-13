class Speciality {
  String? createdBy, arabicTitle, englishTitle, image, selectedCountry;

  Speciality(this.createdBy, this.arabicTitle, this.englishTitle, this.image,
      this.selectedCountry);

  Speciality.fromJson(dynamic json) {
    createdBy = json['createdBy'];
    arabicTitle = json['arabicTitle'];
    englishTitle = json['englishTitle'];
    image = json['image'];
    selectedCountry = json['selectedCountry'];
  }

  Map<String, dynamic> toJson() => {
        'createdBy': createdBy,
        'arabicTitle': arabicTitle,
        'englishTitle': englishTitle,
        'image': image,
        'selectedCountry': selectedCountry,
      };
}

class DevicesCategory {
  String? createdBy, arabicTitle, englishTitle, image, selectedCountry;
  bool? isNew;
  bool isAvailableForPatient = false;

  DevicesCategory(this.createdBy, this.arabicTitle, this.englishTitle,
      this.image, this.selectedCountry, this.isNew, this.isAvailableForPatient);

  DevicesCategory.fromJson(dynamic json) {
    createdBy = json['createdBy'];
    arabicTitle = json['arabicTitle'];
    englishTitle = json['englishTitle'];
    image = json['image'];
    selectedCountry = json['selectedCountry'];
    isNew = json['isNew'];
    isAvailableForPatient = json['isAvailableForPatient'];
  }

  Map<String, dynamic> toJson() => {
        'createdBy': createdBy,
        'arabicTitle': arabicTitle,
        'englishTitle': englishTitle,
        'image': image,
        'selectedCountry': selectedCountry,
        'isNew': isNew,
        'isAvailableForPatient': isAvailableForPatient,
      };
}

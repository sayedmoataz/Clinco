class Doctor {
  String? userId,
      email,
      selectedCountry,
      image,
      name,
      specialityId,
      phoneNumber,
      about,
      doctorLevel,
      token;
  List<dynamic>? documents;
  int accountStatus = 0;

  Doctor(
    this.userId,
    this.email,
    this.selectedCountry,
    this.image,
    this.name,
    this.specialityId,
    this.phoneNumber,
    this.about,
    this.doctorLevel,
    this.documents,
    this.accountStatus,
    this.token,
  );

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'email': email,
        'selectedCountry': selectedCountry,
        'image': image,
        'name': name,
        'specialityId': specialityId,
        'phoneNumber': phoneNumber,
        'about': about,
        'doctorLevel': doctorLevel,
        'documents': documents,
        'accountStatus': accountStatus,
        'token': token,
      };

  Doctor.fromJson(dynamic json) {
    userId = json['userId'] ?? "";
    email = json['email'] ?? "";
    selectedCountry = json['selectedCountry'] ?? "";
    image = json['image'] ?? "";
    name = json['name'] ?? "";
    specialityId = json['specialityId'] ?? "";
    phoneNumber = json['phoneNumber'] ?? "";
    about = json['about'] ?? "";
    doctorLevel = json['doctorLevel'] ?? "";
    documents = json['documents'] ?? [];
    accountStatus = json['accountStatus'] ?? 0;
    token = json['token'] ?? "";
  }
}

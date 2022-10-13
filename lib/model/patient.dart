class Patient {
  String? userId, email, selectedCountry, image, name, phoneNumber, token;
  int accountStatus = 0;

  Patient(this.userId, this.email, this.selectedCountry, this.image, this.name,
      this.phoneNumber, this.accountStatus, this.token);

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'email': email,
        'selectedCountry': selectedCountry,
        'image': image,
        'name': name,
        'phoneNumber': phoneNumber,
        'accountStatus': accountStatus,
        'token': token,
      };

  Patient.fromJson(dynamic json) {
    userId = json['userId'];
    email = json['email'];
    selectedCountry = json['selectedCountry'];
    image = json['image'];
    name = json['name'];
    phoneNumber = json['phoneNumber'];
    accountStatus = json['accountStatus'];
    token = json['token'];
  }
}

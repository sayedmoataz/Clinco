class Admin {
  String? userId, email, selectedCountry, image, name, phoneNumber;
  int accountStatus = 0;

  Admin(this.userId, this.email, this.selectedCountry, this.image, this.name,
      this.phoneNumber, this.accountStatus);

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'email': email,
        'selectedCountry': selectedCountry,
        'image': image,
        'name': name,
        'phoneNumber': phoneNumber,
        'accountStatus': accountStatus,
      };

  Admin.fromJson(dynamic json) {
    userId = json['userId'];
    email = json['email'];
    selectedCountry = json['selectedCountry'];
    image = json['image'];
    name = json['name'];
    phoneNumber = json['phoneNumber'];
    accountStatus = json['accountStatus'];
  }
}

class Company {
  String? userId,
      email,
      selectedCountry,
      image,
      name,
      address,
      phoneNumber,
      about,
      token;
  List<dynamic>? documents;
  int accountStatus = 0;

  Company(
      this.userId,
      this.email,
      this.selectedCountry,
      this.image,
      this.name,
      this.address,
      this.phoneNumber,
      this.about,
      this.documents,
      this.accountStatus,
      this.token);

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'email': email,
        'selectedCountry': selectedCountry,
        'image': image,
        'name': name,
        'address': address,
        'phoneNumber': phoneNumber,
        'about': about,
        'documents': documents,
        'accountStatus': accountStatus,
        'token': token,
      };

  Company.fromJson(dynamic json) {
    userId = json['userId'];
    email = json['email'];
    selectedCountry = json['selectedCountry'];
    image = json['image'];
    name = json['name'];
    address = json['address'];
    phoneNumber = json['phoneNumber'];
    about = json['about'];
    documents = json['documents'];
    accountStatus = json['accountStatus'];
    token = json['token'];
  }
}

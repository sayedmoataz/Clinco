class Rays {
  int? accountStatus;
  String? name;
  String? email;
  String? image;
  String? address;
  String? userId;
  String? phoneNumber;
  String? selectedCountry;
  String? description;
  String? token;
  Map<String, dynamic>? openingHours;

  Rays({
    required this.accountStatus,
    required this.name,
    required this.email,
    required this.image,
    required this.address,
    required this.userId,
    required this.phoneNumber,
    required this.selectedCountry,
    required this.description,
    required this.token,
  });

  Rays.fromJson(Map<String, dynamic> json) {
    accountStatus = json["accountStatus"] ?? 0;
    name = json["name"] ?? "";
    email = json["email"] ?? "";
    image = json["image"] ?? "";
    address = json["address"] ?? "";
    userId = json["userId"] ?? "";
    phoneNumber = json["phoneNumber"] ?? "";
    selectedCountry = json["selectedCountry"] ?? "";
    description = json["description"] ?? "";
    token = json["token"] ?? "";
    openingHours = json["openingHours"] ?? {};
  }

  Map<String, dynamic> toJson() => {
        'accountStatus': 0,
        'name': name,
        'email': email,
        'image': image,
        'address': address,
        'userId': userId,
        'phoneNumber': phoneNumber,
        'selectedCountry': selectedCountry,
        'description': description,
        'token': token,
      };
}

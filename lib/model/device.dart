import 'package:intl/intl.dart';

import '../constants/account_constants.dart';

class Device {
  final numberFormat = NumberFormat("#,##0", "en_US");

  String? createdBy, name, selectedCountry, type, manufacture, description;
  int? price, warranty;
  List<dynamic>? images;
  bool isAvailableForPatient = false;

  Device(
      this.createdBy,
      this.name,
      this.selectedCountry,
      this.price,
      this.warranty,
      this.type,
      this.manufacture,
      this.description,
      this.images,
      this.isAvailableForPatient);

  Device.fromJson(dynamic json) {
    createdBy = json['createdBy'];
    name = json['name'];
    selectedCountry = json['selectedCountry'];
    price = json['price'];
    warranty = json['warranty'];
    type = json['type'];
    manufacture = json['manufacture'];
    description = json['description'];
    images = json['images'];
    isAvailableForPatient = json['isAvailableForPatient'];
  }

  Map<String, dynamic> toJson() => {
        'createdBy': createdBy,
        'name': name,
        'selectedCountry': selectedCountry,
        'price': price,
        'type': type,
        'warranty': warranty,
        'manufacture': manufacture,
        'description': description,
        'images': images,
        'isAvailableForPatient': isAvailableForPatient,
      };

  String get formattedPrice =>
      '${numberFormat.format(price)} ${AccountConstants.getPriceCurrencyByCountry(selectedCountry!)}';
}

class DoctorGuide {
  String? order, title, selectedCountry;

  DoctorGuide(this.order, this.title, this.selectedCountry);

  DoctorGuide.fromJson(dynamic json) {
    order = json['order'];
    title = json['title'];
    selectedCountry = json['selectedCountry'];
  }

  Map<String, dynamic> toJson() => {
        'order': order,
        'title': title,
        'selectedCountry': selectedCountry,
      };
}

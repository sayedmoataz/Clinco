class MoreInfoImage {
  String? title, image, selectedCountry;

  MoreInfoImage(this.title, this.image, this.selectedCountry);

  MoreInfoImage.fromJson(dynamic json) {
    title = json['title'];
    image = json['image'];
    selectedCountry = json['selectedCountry'];
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'image': image,
        'selectedCountry': selectedCountry,
      };
}

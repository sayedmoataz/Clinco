class HomeCard {
  String? pageName;
  String? pageImage;

  HomeCard({required this.pageName, required this.pageImage});

  HomeCard.fromJson(Map<String, dynamic> json) {
    pageName = json["pageName"];
    pageImage = json["pageImage"];
  }
}

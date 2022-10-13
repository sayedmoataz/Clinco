class AppData {
  static final AppData _singleton = AppData._internal();

  factory AppData() {
    return _singleton;
  }

  AppData._internal();

  String? devLinkedInUrl,
      devWhatsAppUrlAr,
      devWhatsAppUrlEn,
      facebookUrl,
      googlePlayUrl,
      appStoreUrl;
}

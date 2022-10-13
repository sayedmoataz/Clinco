import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

import '../model/app_data.dart';

class SocialMediaOperations {
  AppData appData = AppData();
  static final SocialMediaOperations _singleton =
      SocialMediaOperations._internal();

  factory SocialMediaOperations() {
    return _singleton;
  }

  SocialMediaOperations._internal();

  String getCallUrl(String phoneNumber) => "tel:$phoneNumber";

  launchStringUrl(String url) async {
    await launch(url);
  }

  launchGoogleMap(GeoPoint geoPoint) {
    if (geoPoint.latitude != 0.0 && geoPoint.longitude != 0.0) {
      MapsLauncher.launchCoordinates(geoPoint.latitude, geoPoint.longitude);
    }
  }

  share(String? str) {
    Share.share(
        '$str  \n حمل التطبيق الآن ! \n Google Play: ${appData.googlePlayUrl} \n App Store: ${appData.appStoreUrl}  \n  فريق تطبيق وديني - Wadeni App team ',
        subject: 'تطبيق وديني - Wadeni App ');
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/app_colors.dart';
import '../../helper/shared_preferences.dart';
import '../../model/contact_us_list_item.dart';
import '../../model/user_data.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({Key? key}) : super(key: key);

  @override
  _ContactUsScreenState createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  Color primaryLightColor = AppColors.primaryColor;
  List<Color> primaryGradientColors = AppColors.primaryGradientColors;
  late DocumentReference moreInfoImagesRef;
  late final AppData _appData;
  String? _selectedCountry;
  late final Map<String, dynamic> _contactUsUrlsData;

  List<ContactUsListItem> items = [
    ContactUsListItem(FontAwesomeIcons.whatsapp, const Color(0xFF17B459),
        'واتساب', ContactUsType.whatsapp),
    ContactUsListItem(FontAwesomeIcons.instagram, Colors.deepOrangeAccent,
        'انستجرام', ContactUsType.instagram),
    ContactUsListItem(FontAwesomeIcons.facebookF, const Color(0xFF2962FF),
        'فيس بوك', ContactUsType.facebook),
    ContactUsListItem(FontAwesomeIcons.twitter, Colors.blueAccent, 'تويتر',
        ContactUsType.twitter),
    ContactUsListItem(FontAwesomeIcons.linkedinIn, const Color(0xFF2962FF),
        'لينكد إن', ContactUsType.linkedin),
    ContactUsListItem(FontAwesomeIcons.youtube, Colors.redAccent, 'يوتيوب',
        ContactUsType.youtube),
  ];

  @override
  void initState() {
    moreInfoImagesRef = FirebaseFirestore.instance
        .collection(FirestoreCollections.ContactUs.name)
        .doc('Urls');
    _appData = AppData();
    _appData.getSharedPreferencesInstance().then((pref) {
      _selectedCountry = _appData.getSelectedCountry(pref!)!;
      moreInfoImagesRef.get().then((value) {
        setState(() {
          _contactUsUrlsData = value.data() as Map<String, dynamic>;
        });
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('وسائل التواصل',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: primaryGradientColors),
              ),
            ),
          ),
          body: getContactUsItemWidgets(),
        ));
  }

  getContactUsItemWidgets() => ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) => _buildContactUsItemWidget(items[index]));

  _buildContactUsItemWidget(ContactUsListItem item) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: InkWell(
          onTap: () => openUrl(item),
          child: ListTile(
            title: Text(
              item.title,
              style: TextStyle(fontSize: 16, color: primaryLightColor),
            ),
            leading: Icon(
              item.icon,
              color: item.iconColor,
            ),
          ),
        ),
      ),
    );
  }

  void openUrl(ContactUsListItem item) async {
    String url = getConnectionUrl(item.contactUsType);
    Uri uri = Uri.parse(url);
    canLaunchUrl(uri).then((value) async {
      if (value) {
        if (item.contactUsType == ContactUsType.whatsapp) {
          await launch(url);
        } else {
          await launchUrl(uri);
        }
      }
    });
  }

  String getConnectionUrl(ContactUsType contactUsType) {
    String url;
    if (contactUsType == ContactUsType.whatsapp) {
      url = (_selectedCountry == Countries.Egypt.name)
          ? _contactUsUrlsData['whatsappEgypt']
          : _contactUsUrlsData['whatsappKSA'];
    } else {
      url = _contactUsUrlsData[contactUsType.name];
    }
    return url;
  }
}

import 'package:flutter/cupertino.dart';

class ContactUsListItem {
  IconData icon;
  Color iconColor;
  String title;
  ContactUsType contactUsType;

  ContactUsListItem(this.icon, this.iconColor, this.title, this.contactUsType);
}

enum ContactUsType { whatsapp, instagram, facebook, twitter, linkedin, youtube }

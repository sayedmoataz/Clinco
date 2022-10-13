import 'package:clinico/constants/app_colors.dart';
import 'package:clinico/view/screens/lab_rays_shared/lab_rays_profile.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:share/share.dart';

import '../../components/logout_widget.dart';
import '../about_us_screen.dart';
import '../bmi_calculator/screens/bmi_input_page.dart';
import '../contact_us_screen.dart';

class LabRaysSettings extends StatefulWidget {
  bool isLab;

  LabRaysSettings({Key? key, required this.isLab}) : super(key: key);

  @override
  State<LabRaysSettings> createState() => _LabRaysSettingsState();
}

class _LabRaysSettingsState extends State<LabRaysSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Container(
        width: double.infinity,
        child: Column(
          children: [
            Container(
              height: 100,
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    "أهلا بك فى كلينكو",
                    style: TextStyle(fontSize: 30),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  item("الحساب الشخصى", LineIcons.user, () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => LabRaysProfile(
                              isLab: widget.isLab,
                            )));
                  }),
                  const Divider(),
                  item("من نحن", LineIcons.users, () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const AboutUsScreen()));
                  }),
                  const Divider(),
                  item("حساب مؤشر كتلة الجسم BMI", LineIcons.running, () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const BmiInputPage()));
                  }),
                  const Divider(),
                  item("وسائل التواصل", LineIcons.inbox, () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const ContactUsScreen()));
                  }),
                ],
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  item("دعوة صديق", LineIcons.share, () {
                    Share.share('https://l.linklyhq.com/l/1IEff');
                  }),
                  const Divider(),
                  item("تسجيل الخروج", LineIcons.alternateSignOut, () {
                    LogoutWidget().showLogoutDialog(context);
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget item(String text, var icon, var function) => GestureDetector(
        onTap: function,
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    color: AppColors.appPrimaryColor,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Text(
                    text,
                    style: const TextStyle(fontSize: 18),
                  )
                ],
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 15,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      );
}

import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({Key? key}) : super(key: key);

  @override
  _AboutUsScreenState createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  Color primaryColor = AppColors.primaryColor;
  Color secondaryColor2 = AppColors.secondaryColor2;
  List<Color> primaryGradientColors = AppColors.primaryGradientColors;

  List<String> features = [
    'المتابعة لجميع التخصصات الطبية.',
    'حجز موعد الطبيب في عيادته الخاصة.',
    'التواصل مع الطبيب عن طريق الفيديو.',
    'توفير منصة تجارية للأجهزة الطبية اللازمة بأسعار تنافسية.'
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('من نحن',
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
          body: _buildAboutUsBodyWidget(),
        ));
  }

  _buildAboutUsBodyWidget() {
    return Padding(
        padding: const EdgeInsets.all(3),
        child: ListView(
          children: [
            const Text(
              'نحن منصة طبية خدمية تقوم على خدمة المرضى عن طريق توفير الخدمات الطبية بشكل أسهل... ونقدم:',
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(
              height: 7,
            ),
            for (var feature in features)
              _buildFeatureWidget(feature, features.indexOf(feature) + 1)
          ],
        ));
  }

  _buildFeatureWidget(String featureTitle, int leadingNumber) {
    return Card(
        color: Colors.white,
        child: Padding(
            padding: const EdgeInsets.all(2),
            child: ListTile(
                title: Text(
                  featureTitle,
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
                leading: SizedBox(
                  height: double.infinity,
                  child: CircleAvatar(
                    backgroundColor: secondaryColor2,
                    child: Text(
                      leadingNumber.toString(),
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ))));
  }
}

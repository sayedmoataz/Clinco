import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../model/ad.dart';

class AdsContainerWidget extends StatelessWidget {
  final List<Ad> ads;

  const AdsContainerWidget({
    Key? key,
    required this.ads,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return /*CarouselSlider(
        items: ads
            .map((e) => Builder(
                  builder: (BuildContext context) => getAdsWidget(e),
                ))
            .toList(),
        options: CarouselOptions(
            height: 180,
            initialPage: 0,
            viewportFraction: 1.0,
            enableInfiniteScroll: true,
            reverse: false,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 3),
            autoPlayAnimationDuration: const Duration(seconds: 1),
            autoPlayCurve: Curves.fastOutSlowIn,
            scrollDirection: Axis.horizontal));
    */
       Container(
       color: Colors.black12,
       padding: const EdgeInsets.only(top: 5, bottom: 3),
       child: CarouselSlider(
         options: CarouselOptions(
           height: 180,
           aspectRatio: 16/9,
           viewportFraction: 0.8,
           initialPage: 0,
           enableInfiniteScroll: true,
           reverse: false,
           autoPlay: ads.length > 1,
           scrollPhysics: scrollingState(ads),
           autoPlayInterval: const Duration(seconds: 5),
           autoPlayAnimationDuration: const Duration(milliseconds: 800),
           autoPlayCurve: Curves.fastOutSlowIn,
           enlargeCenterPage: true,
           // onPageChanged: callbackFunction,
           scrollDirection: Axis.horizontal,
         ),
         items: ads.map((i) {
           return Builder(
             builder: (BuildContext context) {
               return getAdsWidget(i);
             },
           );
         }).toList(),
       ),
     );
  }

  ScrollPhysics scrollingState(List<Ad> ads) {
    if (ads.length > 1) {
      return const AlwaysScrollableScrollPhysics();
    } else {
      return const NeverScrollableScrollPhysics();
    }
  }

  Widget getAdsWidget(Ad ad) {
    return GestureDetector(
      onTap: () => openUrl(ad.redirectLink),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Container(
            width: double.infinity,
            // height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: const BorderRadius.all(Radius.circular(10.0)),
              image: DecorationImage(
                image: NetworkImage(ad.image!),
                fit: BoxFit.cover,
              ),
            ),
            child: null),
      ),
    );
  }

  void openUrl(String? adRedirectLink) async {
    if (adRedirectLink != null && adRedirectLink.isNotEmpty) {
      Uri uri = Uri.parse(adRedirectLink);
      canLaunchUrl(uri).then((value) async {
        if (value) {
          await launchUrl(uri);
        }
      });
    }
  }
}

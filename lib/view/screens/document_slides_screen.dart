import 'package:flutter/material.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';

import '../../constants/app_colors.dart';

class ImagesSlidesScreen extends StatefulWidget {
  final List<dynamic> documents;
  final String title;

  const ImagesSlidesScreen(
      {Key? key, required this.documents, required this.title})
      : super(key: key);

  @override
  _ImagesSlidesScreenState createState() => _ImagesSlidesScreenState();
}

class _ImagesSlidesScreenState extends State<ImagesSlidesScreen> {
  Color primaryColor = AppColors.primaryColor;
  List<Color> primaryGradientColors = AppColors.primaryGradientColors;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              widget.title,
              //   style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              // flexibleSpace: Container(decoration:
              // BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: primaryGradientColors),),
            ),
          ),
          body: ImageSlideshow(
            width: double.infinity,
            height: double.infinity,
            initialPage: 0,
            indicatorColor: primaryColor,
            indicatorBackgroundColor: Colors.grey,
            onPageChanged: (value) {},
            isLoop: false,
            children: [
              for (var i = 0; i < widget.documents.length; i++)
                getImageWidget(widget.documents[i])
            ],
          ),
        ));
  }

  Widget getImageWidget(String image) {
    return Center(
      child: InteractiveViewer(
        minScale: 0.1,
        maxScale: 2.0,
        child: Container(
          margin: const EdgeInsets.only(left: 1.0, right: 1.0),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            image: DecorationImage(
              image: NetworkImage(image),
              fit: BoxFit.fill,
            ),
          ),
        ),
      ),
    );
  }
}

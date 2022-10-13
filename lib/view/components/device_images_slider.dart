import 'package:flutter/material.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';

import '../../constants/app_colors.dart';

class DeviceImagesSlider extends StatelessWidget {
  final List<dynamic> deviceImages;

  const DeviceImagesSlider({
    Key? key,
    required this.deviceImages,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color primaryColor = AppColors.primaryColor;
    Size size = MediaQuery.of(context).size;
    return SizedBox(
      width: double.infinity,
      height: size.height,
      child: ImageSlideshow(
        width: double.infinity,
        height: double.infinity,
        initialPage: 0,
        indicatorColor: primaryColor,
        indicatorBackgroundColor: Colors.grey,
        onPageChanged: (value) {},
        isLoop: false,
        children: [
          for (var i = 0; i < deviceImages.length; i++)
            getImageWidget(deviceImages[i])
        ],
      ),
    );
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

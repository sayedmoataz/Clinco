import 'package:flutter/material.dart';

class CustomCircularWidget extends StatelessWidget {
  final ImageProvider imageProvider;
  final Color borderColor;
  final bool isEditable;
  final bool isEdit;
  final VoidCallback onClicked;

  const CustomCircularWidget({
    Key? key,
    required this.imageProvider,
    this.borderColor = Colors.white,
    this.isEditable = false,
    this.isEdit = false,
    required this.onClicked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Directionality(
      textDirection: TextDirection.rtl,
      child: Center(
        child: Stack(
          children: [
            buildImage(),
            Positioned(
              bottom: 0,
              left: 0,
              child: buildEditIcon(borderColor),
            ),
          ],
        ),
      ));

  Widget buildImage() => Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: borderColor),
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.cover,
          ),
        ),
      );

  Widget buildEditIcon(Color color) => Visibility(
        visible: isEditable,
        child: buildCircle(
          color: Colors.white,
          all: 2,
          child: buildCircle(
              color: color,
              all: 6,
              child: InkWell(
                  onTap: onClicked,
                  child: const Icon(Icons.add_a_photo,
                      color: Colors.white, size: 20))),
        ),
      );

  Widget buildCircle({
    required Widget child,
    required double all,
    required Color color,
  }) =>
      ClipOval(
        child: Container(
          padding: EdgeInsets.all(all),
          color: color,
          child: child,
        ),
      );
}

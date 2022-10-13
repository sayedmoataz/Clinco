import 'package:flutter/material.dart';

class Background extends StatelessWidget {
  final Widget child;

  double getSmallDiameter(BuildContext context) =>
      MediaQuery.of(context).size.width * 2 / 3;

  double getBiglDiameter(BuildContext context) =>
      MediaQuery.of(context).size.width * 6 / 12;

  const Background({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SizedBox(
      width: double.infinity,
      height: size.height,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
            right: -getBiglDiameter(context) / 5,
            top: -getBiglDiameter(context) / 9,
            child: Container(
              width: getBiglDiameter(context),
              height: getBiglDiameter(context),
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Color(0xFFF2F2F2)),
              child: Center(
                child: Image.asset("assets/icon/clinico_logo.png",
                    width: size.width * 0.36),
              ),
            ),
          ),
          Positioned(
            left: -getBiglDiameter(context) / 2,
            bottom: -getBiglDiameter(context) / 2,
            child: Container(
              width: getBiglDiameter(context),
              height: getBiglDiameter(context),
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Color(0xFFF2F2F2)),
            ),
          ),
          child
        ],
      ),
    );
  }
}

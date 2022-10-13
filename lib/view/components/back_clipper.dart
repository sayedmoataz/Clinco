import 'package:flutter/material.dart';

class BackClipper extends CustomClipper<Path> {
  static final BackClipper _backClipper = BackClipper._internal();

  factory BackClipper() => _backClipper;

  BackClipper._internal();

  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0.0, size.height - size.height / 5);
    var firstControlPoint = Offset(size.width / 2, size.height + 25);
    var firstEndPoint = Offset(size.width, size.height - size.height / 5);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);
    path.lineTo(size.width, 0.0);
    var secondControlPoint = Offset(size.width / 2, size.height / 5 + 25);
    var secondEndPoint = const Offset(0.0, 0.0);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

import 'package:flutter/material.dart';

class TopCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.lineTo(0, size.height * 0.5); // Lower vertical point
    path.quadraticBezierTo(
      size.width / 2,
      size.height * 1.2, // Deeper curve
      size.width,
      size.height * 0.5,
    );
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

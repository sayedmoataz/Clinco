import 'package:flutter/material.dart';

class BmiReusableCard extends StatelessWidget {
  const BmiReusableCard(
      {Key? key, required this.colour, required this.cardChild, this.onPress})
      : super(key: key);

  final Color colour;
  final Widget cardChild;
  final Function()? onPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        margin: const EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          color: colour,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: EdgeInsets.all(2.0),
          child: cardChild,
        ),
      ),
    );
  }
}

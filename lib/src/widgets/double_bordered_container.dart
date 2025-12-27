import 'package:flutter/material.dart';

class DoubleBorderedContainer extends StatelessWidget {
  final double width;
  final double height;
  final Color innerBorderColor;
  final Color outerBorderColor;
  final double innerBorderWidth;
  final double outerBorderWidth;
  final Widget child;
  const DoubleBorderedContainer({
    this.width = 100,
    this.height = 100,
    this.innerBorderColor = Colors.red,
    this.outerBorderColor = Colors.green,
    this.innerBorderWidth = 8.0,
    this.outerBorderWidth = 4.0,
    required this.child,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        border: Border.all(color: outerBorderColor, width: outerBorderWidth),
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: innerBorderColor, width: innerBorderWidth),
        ),
        child: child,
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';

class ToggleButton extends StatelessWidget {
  final VoidCallback callback;
  final String label;
  final double width;
  final double height;
  final Color? borderColor;
  const ToggleButton(
    this.callback, {
    this.label = "press",
    this.width = 160,
    this.height = 70,
    this.borderColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: callback,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          border: Border.all(width: 4, color: borderColor ?? Colors.white),
        ),
        child: Center(child: Text(label, style: const TextStyle(fontSize: 25))),
      ),
    );
  }
}

class GoButton extends StatefulWidget {
  final VoidCallback callback;
  final double width;
  final double height;
  final double fontSize;
  final String label;
  final Color borderColor;
  final Color tapColor;
  const GoButton(
    this.callback, {
    this.width = 200,
    this.height = 100,
    this.fontSize = 50,
    this.label = "GO",
    this.borderColor = Colors.white,
    this.tapColor = Colors.red,
    super.key,
  });

  @override
  State<GoButton> createState() => GoButtonState();
}

class GoButtonState extends State<GoButton> {
  late Color _borderColor;
  Timer? timer;

  @override
  initState() {
    super.initState();
    // Initial border color
    _borderColor = widget.borderColor;
  }

  void _tapTimeout() {
    setState(() {
      _borderColor = widget.borderColor; // Change back color on release
    });
  }

  void _onTapDown(_) {
    setState(() {
      _borderColor = widget.tapColor; // Change color on press down
      timer = Timer(const Duration(milliseconds: 200), _tapTimeout);
    });
  }

  /*
  void _onTapUp(_) {
    setState(() {
      _borderColor = widget.borderColor; // Change back color on release
    });
  }
  */

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTap: widget.callback,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          border: Border.all(color: _borderColor, width: 4),
        ),
        child: Center(
          child: Text(
            widget.label,
            style: TextStyle(fontSize: widget.fontSize),
          ),
        ),
      ),
    );
  }
}

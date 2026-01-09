import 'dart:async';
import 'package:flutter/material.dart';

class TBar extends StatefulWidget {
  final double initialValue;
  final void Function(double value)? onChanged;
  const TBar({required this.initialValue, this.onChanged, super.key});

  @override
  State<TBar> createState() => TBarState();
}

class TBarState extends State<TBar> {
  double _value = 0.0;
  @override
  initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return RotatedBox(
      quarterTurns: 3,
      child: Slider(
        value: _value,
        min: 0.0,
        max: 1.0,
        onChanged: (value) {
          widget.onChanged?.call(value);
          _value = value;
        },
      ),
    );
  }
}

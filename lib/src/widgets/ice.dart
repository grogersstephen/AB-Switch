import 'package:flutter/material.dart';

class ICE extends StatefulWidget {
  final void Function()? onLoad;
  const ICE({this.onLoad, super.key});

  @override
  ICEState createState() => ICEState();
}

class ICEState extends State<ICE> {
  @override
  void initState() {
    super.initState();
    widget.onLoad?.call();
  }

  @override
  Widget build(BuildContext context) {
    return const CircularProgressIndicator();
  }
}

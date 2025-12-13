import 'package:flutter/material.dart';

class BorderListTile extends StatefulWidget {
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final void Function()? onTap;

  const BorderListTile({
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    super.key,
  });

  @override
  BorderListTileState createState() => BorderListTileState();
}

class BorderListTileState extends State<BorderListTile> {
  bool _isTapped = false;

  void _toggleTapped() {
    setState(() {
      _isTapped = !_isTapped;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onTap?.call();
        _toggleTapped();
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: _isTapped ? Colors.green : Colors.transparent,
            width: 2.0,
          ),
        ),
        child: ListTile(
          title: widget.title,
          subtitle: widget.subtitle,
          trailing: widget.trailing,
        ),
      ),
    );
  }
}

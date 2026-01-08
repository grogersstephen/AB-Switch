import 'package:flutter/material.dart';
import 'package:obs_production_switcher/src/modules/client/connection.dart';

class LostConnectionDialog extends StatelessWidget {
  const LostConnectionDialog({super.key});
  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: dialogInsetPadding(
        context,
        dialogWidth: 300,
        edgePaddingV: 200,
      ),
      child: const Padding(
        padding: EdgeInsets.all(35),
        child: Text("lost connection"),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class ConnectingPage extends StatelessWidget {
  final String? host;
  final VoidCallback? onCancel;
  const ConnectingPage({this.host, this.onCancel, super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(35),
      child: Column(
        children: [
          const Text("Connecting to Host"),
          if (host != null) Text(host!),
          const CircularProgressIndicator(),
          ElevatedButton(onPressed: onCancel, child: const Text("CANCEL")),
        ],
      ),
    );
  }
}

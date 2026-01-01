import 'package:flutter/material.dart';

class ReconnectingPage extends StatelessWidget {
  final String? host;
  const ReconnectingPage({this.host, super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(35),
      child: Column(
        children: [
          const Text("Connection Lost"),
          const Text("Attempting Reconnection"),
          if (host != null) Text(host!),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }
}

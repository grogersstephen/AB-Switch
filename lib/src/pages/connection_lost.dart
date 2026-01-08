import 'package:flutter/material.dart';

class ConnectionLostPage extends StatelessWidget {
  final String? host;
  const ConnectionLostPage({this.host, super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(35),
      child: Column(
        children: [
          const Text("Connection Lost to Host"),
          if (host != null) Text(host!),
        ],
      ),
    );
  }
}

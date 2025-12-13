import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:obs_websocket/obs_websocket.dart';
import 'package:obs_production_switcher/src/modules/preferences/preferences.dart';

class ConnectionDialog extends HookWidget {
  const ConnectionDialog({super.key});
  @override
  Widget build(BuildContext context) {
    final prefs = usePreferences();
    final hostCtl = useTextEditingController();
    final portCtl = useTextEditingController();
    final passwordCtl = useTextEditingController();

    // Fill in with credentials from storage
    final credentials = useCredentials();
    if (credentials.hasData && credentials.requireData.isNotEmpty) {
      final c = credentials.requireData;
      hostCtl.text = c.first.host;
      portCtl.text = c.first.port.toString();
      passwordCtl.text = c.first.password;
    }

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextInput(controller: hostCtl, labelText: "host"),
            TextInput(controller: portCtl, labelText: "port"),
            TextInput(
                controller: passwordCtl,
                labelText: "password",
                obscureText: true),
            ElevatedButton(
              child: const Text("CONNECT"),
              onPressed: () {
                final host = hostCtl.text;
                final port = portCtl.text;
                String? password = passwordCtl.text;
                password = password.isEmpty ? null : password;
                // save it
                final credential = WSCredential(
                    host: host,
                    port: int.tryParse(port) ?? 0,
                    password: password ?? "");
                // Return the credential
                Navigator.pop(context, credential);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class TextInput extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final bool obscureText;
  const TextInput(
      {this.controller, this.labelText, this.obscureText = false, super.key});
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
      ),
      obscureText: obscureText,
    );
  }
}

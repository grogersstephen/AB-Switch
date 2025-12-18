import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:obs_production_switcher/src/modules/preferences/preferences.dart';
import 'package:obs_production_switcher/src/modules/snackbar/snackbar.dart';
import 'package:obs_production_switcher/src/theme.dart';
import 'package:obs_websocket/obs_websocket.dart';
import 'package:obs_websocket/event.dart';
import 'package:obs_production_switcher/src/modules/connection/connection.dart';
import 'package:obs_production_switcher/src/pages/landing.dart';
import 'package:obs_production_switcher/src/modules/client/client.dart';

class OBSSwitchApp extends StatelessWidget {
  const OBSSwitchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: OBSSwitchTheme.dark(),
      home: Builder(builder: (context) => const AppScaffold()),
    );
  }
}

class AppScaffold extends HookWidget {
  const AppScaffold({super.key});
  @override
  Widget build(BuildContext context) {
    final snackbarStreamCtl = StreamController<SnackbarMessage>();
    final snack = snackbarStreamCtl.add;
    final client = useState<OBSClient>(NoOpClient());

    return SafeArea(
      child: Scaffold(
        floatingActionButton: null,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: const Text("A/B Switch"),
          actions: [
            IconButton(
              icon: const Icon(Icons.link),
              onPressed: () async {
                final res = await showDialog<Future<OBSClient>?>(
                  context: context,
                  builder: (context) => const SelectEndpointDialog(),
                );
                client.value = await res ?? const NoOpClient();
                // final client = await clientFuture;
                // obsWebSocketNotifier.value = socket;
              },
            ),
          ],
        ),
        drawer: null,
        body: SnackbarListener(
          stream: snackbarStreamCtl.stream,
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: LandingPage(client.value),
            // : const CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}

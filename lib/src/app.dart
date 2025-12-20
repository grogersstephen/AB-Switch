import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

class AppScaffold extends ConsumerWidget {
  const AppScaffold({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snackbarStreamCtl = StreamController<SnackbarMessage>();
    final snack = snackbarStreamCtl.add;

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
                final client = await await showDialog<Future<OBSClient>?>(
                  context: context,
                  builder: (context) => const SelectEndpointDialog(),
                );
                if (client is! NoOpClient && client != null) {
                  ref.read(clientPProvider.notifier).update(client);
                }
              },
            ),
          ],
        ),
        drawer: null,
        body: SnackbarListener(
          stream: snackbarStreamCtl.stream,
          child: const Padding(
            padding: EdgeInsets.all(30),
            child: LandingPage(),
            // : const CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}

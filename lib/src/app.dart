import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:obs_production_switcher/src/modules/snackbar/snackbar.dart';
import 'package:obs_production_switcher/src/modules/dialoger/dialoger.dart';
import 'package:obs_production_switcher/src/theme.dart';
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
    snack(String msg, {Color? backgroundColor}) => ref
        .read(snackbarMsgProvider.notifier)
        .send(SnackbarMessage(msg, backgroundColor: backgroundColor));
    spawnDialog(Widget widget, {bool barrierDismissable = true}) =>
        ref.read(dialogSpawnerProvider.notifier).spawn(widget);

    return SafeArea(
      child: Scaffold(
        floatingActionButton: null,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: const Text("A/B Switch"),
          actions: [
            IconButton(
              icon: const Icon(Icons.link),
              onPressed: () => spawnDialog(const SelectEndpointDialog()),
            ),
          ],
        ),
        drawer: null,
        body: const Padding(
          padding: EdgeInsets.all(30),
          child: DialogListener(child: SnackbarListener(child: LandingPage())),
        ),
      ),
    );
  }
}

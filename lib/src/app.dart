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
    final obsWebSocketNotifier = useState<ObsWebSocket?>(null);
    final isConnected = useState<bool>(false);
    final prefs = usePreferences();

    useEffect(() {
      final obs = obsWebSocketNotifier.value;
      if (obs == null) {
        isConnected.value = false;
        return () {};
      }
      isConnected.value = true;
      // Listeners
      obs.subscribe(EventSubscription.all).then((_) {
        obs.addHandler<SceneNameChanged>((sceneNameChanged) async {
          final msg = 'scene name changed: \n$sceneNameChanged';
          snack(SnackbarMessage(msg));
          print(msg);
        });
        obs.addHandler<SceneItemSelected>((sceneItemSelected) async {
          final msg = ('scene item selected: \n$sceneItemSelected');
          snack(SnackbarMessage(msg));
          print(msg);
        });
      });

      return () {};
    }, [obsWebSocketNotifier.value]);

    return SafeArea(
      child: Scaffold(
        floatingActionButton: null,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: const Text("OBS Switch"),
          actions: [
            IconButton(
              //Icons. link sync devices public wifi
              icon: const Icon(Icons.link),
              onPressed: () async {
                try {
                  final cred = await showDialog<WSCredential>(
                    context: context,
                    builder: (context) => const ConnectionDialog(),
                  );
                  if (cred == null) {
                    return;
                  }

                  // Construct the url
                  final url = "ws://${cred.host}:${cred.port}";

                  // Update the web socket notifier
                  obsWebSocketNotifier.value = await ObsWebSocket.connect(
                    url,
                    password: cred.password,
                  );

                  // Get the version
                  final version =
                      (await obsWebSocketNotifier.value?.general.version);

                  // SUCCESSFUL CONNECTION
                  prefs.data?.addCredential(cred);
                  final msg =
                      "Successfully connected to OBS ${version?.obsVersion}";
                  // snack(SnackbarMessage(msg));
                } catch (e) {
                  final msg = "obs web socket connection failed: $e";
                  // snack(SnackbarMessage(msg, backgroundColor: Colors.red));
                  print(msg);
                  obsWebSocketNotifier.value = null;
                }
              },
            ),
          ],
        ),
        drawer: null,
        body: SnackbarListener(
          stream: snackbarStreamCtl.stream,
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: isConnected.value
                ? LandingPage(obsWebSocketNotifier.value)
                : LandingPage(obsWebSocketNotifier.value),
            // : const CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}

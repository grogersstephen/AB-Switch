import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:obs_production_switcher/src/app.dart';
import 'package:obs_production_switcher/src/modules/dialoger/dialoger.dart';
import 'package:obs_production_switcher/src/modules/gonavigator/gonavigator.dart';
import 'package:obs_websocket/obs_websocket.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:obs_production_switcher/src/modules/preferences/preferences.dart';
import 'package:obs_production_switcher/src/widgets/input.dart';
import 'package:obs_production_switcher/src/widgets/list_tile.dart';
import 'package:obs_production_switcher/src/widgets/ice.dart';
import 'package:obs_production_switcher/src/modules/client/client.dart';

EdgeInsets dialogInsetPadding(
  BuildContext context, {
  double dialogWidth = 400.0,
  double edgePaddingV = 50.0,
}) {
  final screenSize = MediaQuery.of(context).size;
  final edgePaddingH = (screenSize.width - dialogWidth) / 2;
  return EdgeInsets.fromLTRB(
    edgePaddingH,
    edgePaddingV,
    edgePaddingH,
    edgePaddingV,
  );
}

class SelectEndpointDialog extends HookConsumerWidget {
  const SelectEndpointDialog({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = usePreferences().data;

    return Dialog(
      insetPadding: dialogInsetPadding(context),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: StreamBuilder<List<WSCredential>>(
          stream: prefs?.getWSCredentials(),
          builder: (context, snapshot) {
            final List<WSCredential> credentials = snapshot.data ?? [];
            return ListView.builder(
              itemCount: credentials.length + 1,
              itemBuilder: (context, i) {
                if (i == credentials.length) {
                  return IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => const AddConnectionDialog(),
                      );
                    },
                  );
                }
                final credential = credentials[i];
                return BorderListTile(
                  onTap: () async {
                    // Connect
                    await _connect(
                      credential,
                      ref: ref,
                      context: context,
                      onSuccess: () => prefs?.addCredential(credential),
                    );
                  },
                  title: Text(credential.name ?? credential.host),
                  subtitle: Column(
                    children: [
                      Text(credential.host),
                      Text(credential.port.toString()),
                    ],
                  ),
                  trailing: OverflowBar(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => prefs?.removeCredential(credential),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  _connect(
    WSCredential credential, {
    required WidgetRef ref,
    required BuildContext context,
    VoidCallback? onSuccess,
  }) async {
    final Completer<ConnectionStatus> statusCompleter =
        Completer<ConnectionStatus>();
    ref
        .read(clientPProvider.notifier)
        .update(
          statusCompleter.future.then(
            (connectionStatus) => connectionStatus.client,
          ),
        );

    // Pop the dialog
    Navigator.pop(context);

    // This will be completed if the user taps 'cancel' on the EstablishingConnectionDialog
    final connectionCanceler = Completer<Null>();

    ref.read(goNavigatorProvider.notifier).navigate(Routes.connecting.path);
    // Spawn the Establishing Connection Dialog
    // ref
    // .read(dialogSpawnerProvider.notifier)
    // .spawn(
    // EstablishingConnectionDialog(
    // statusFuture: statusCompleter.future,
    // onCancel: connectionCanceler.complete,
    // ),
    // barrierDismissable: false,
    // );

    // Try to Connect
    final url = "ws://${credential.host}:${credential.port}";

    // Wait for the canceler to be completed
    connectionCanceler.future.then((v) {
      if (statusCompleter.isCompleted) {
        return;
      }
      statusCompleter.complete(
        ConnectionStatus(false, message: "Cancelled Connection"),
      );
    });

    final ObsWebSocket conn;
    try {
      conn = await ObsWebSocket.connect(url, password: credential.password);
    } catch (e) {
      // If the connection failed, complete the statusCompleter with a false value
      if (!statusCompleter.isCompleted) {
        statusCompleter.complete(
          ConnectionStatus(false, message: "Could not connect to $url"),
        );
      }
      return;
    }

    // If the 'cancel' button was tapped, the statusCompleter should already be completed
    if (statusCompleter.isCompleted) {
      return;
    }

    // Get the version and complete the statusCompleter
    //   which will pass the OBSClient to the provider
    final version = (await conn.general.version);
    statusCompleter.complete(
      ConnectionStatus(
        true,
        message: "Successfully connected to OBS ${version.obsVersion}",
        client: Client(conn),
      ),
    );
    onSuccess?.call();
  }
}

class AddConnectionDialog extends HookWidget {
  const AddConnectionDialog({super.key});
  @override
  Widget build(BuildContext context) {
    final prefs = usePreferences();
    final hostCtl = useTextEditingController();
    final portCtl = useTextEditingController();
    final passwordCtl = useTextEditingController();

    return Dialog(
      insetPadding: dialogInsetPadding(context),
      child: Padding(
        padding: const EdgeInsets.all(35),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 15,
          children: [
            TextInput(controller: hostCtl, labelText: "host"),
            PortField(controller: portCtl, labelText: "port"),
            PasswordField(controller: passwordCtl),
            // TextInput(
            // controller: passwordCtl,
            // labelText: "password",
            // obscureText: true,
            // ),
            ElevatedButton(
              child: const Text("+ ADD"),
              onPressed: () {
                final host = hostCtl.text;
                final port = portCtl.text;
                String password = passwordCtl.text;
                // save it
                final credential = WSCredential(
                  host: host,
                  port: int.tryParse(port) ?? 0,
                  password: password,
                );
                prefs.requireData.addCredential(credential);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ConnectionStatus {
  final bool success;
  final String? message;
  final OBSClient client;
  ConnectionStatus(
    this.success, {
    this.message,
    this.client = const NoOpClient(),
  });
}

class EstablishingConnectionDialog extends StatelessWidget {
  final Future<ConnectionStatus> statusFuture;
  final VoidCallback onCancel;
  const EstablishingConnectionDialog({
    required this.statusFuture,
    required this.onCancel,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: statusFuture,
      builder: (context, snapshot) {
        const maa = MainAxisAlignment.spaceEvenly;
        return Dialog(
          insetPadding: dialogInsetPadding(
            context,
            dialogWidth: 300,
            edgePaddingV: 200,
          ),
          child: Padding(
            padding: const EdgeInsets.all(35),
            child: snapshot.hasData
                ? snapshot.requireData.success
                      ? ICE(onLoad: () => Navigator.pop(context))
                      : ICE(onLoad: () => Navigator.pop(context))
                /*
                      ? Column(
                          mainAxisAlignment: maa,
                          children: [
                            const Text("Successfully connected"),
                            ElevatedButton(
                              child: const Text(
                                "OK",
                                style: TextStyle(fontSize: 32),
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: maa,
                          children: [
                            const Text("Error connecting"),
                            Text(snapshot.data?.message ?? ""),
                            ElevatedButton(
                              child: const Text("CLOSE"),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        )
						*/
                : Column(
                    mainAxisAlignment: maa,
                    children: [
                      const Text("Establishing Connection"),
                      const CircularProgressIndicator(),
                      ElevatedButton(
                        onPressed: onCancel,
                        child: const Text("CANCEL"),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

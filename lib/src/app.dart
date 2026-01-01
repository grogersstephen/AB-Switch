import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:obs_production_switcher/src/modules/snackbar/snackbar.dart';
import 'package:obs_production_switcher/src/modules/dialoger/dialoger.dart';
import 'package:obs_production_switcher/src/modules/gonavigator/gonavigator.dart';
import 'package:obs_production_switcher/src/theme.dart';
import 'package:obs_production_switcher/src/pages/landing.dart';
import 'package:obs_production_switcher/src/pages/not_found.dart';
import 'package:obs_production_switcher/src/pages/connecting.dart';
import 'package:obs_production_switcher/src/pages/reconnecting.dart';
import 'package:obs_production_switcher/src/pages/connection_lost.dart';
import 'package:obs_production_switcher/src/pages/connection_select_endpoint.dart';

enum Routes {
  landing('/'),
  selectEndpoint('/connection/selectEndpoint'),
  connecting('/connection/connecting'),
  reconnecting('/connection/reconnecting'),
  connectionLost('/connection/lost');

  const Routes(this.path); // Constructor to associate the path string
  final String path;

  static Routes? fromPath(String path) {
    for (var route in Routes.values) {
      if (route.path == path) {
        return route;
      }
    }
    return null; // Return null if no matching route is found
  }
}

class OBSSwitchApp extends StatelessWidget {
  const OBSSwitchApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: Routes.landing.path,
      errorBuilder: (context, state) =>
          const AppScaffold(pageTitle: "404 - Not Found", body: NotFoundPage()),
      routes: [
        ShellRoute(
          builder: (context, state, child) {
            return AppScaffold(
              body: Padding(padding: const EdgeInsets.all(4), child: child),
              pageTitle: state.name ?? "",
            );
          },
          routes: [
            GoRoute(
              name: 'Landing',
              path: Routes.landing.path,
              builder: (context, state) => const LandingPage(),
            ),
            GoRoute(
              name: 'Connecting',
              path: Routes.connecting.path,
              builder: (context, state) => const ConnectingPage(),
            ),
            GoRoute(
              name: 'Reconnecting',
              path: Routes.reconnecting.path,
              builder: (context, state) => const ReconnectingPage(),
            ),
            GoRoute(
              name: 'Connection Lost',
              path: Routes.connectionLost.path,
              builder: (context, state) => const ConnectionLostPage(),
            ),
            GoRoute(
              name: 'Select Endpoint',
              path: Routes.selectEndpoint.path,
              builder: (context, state) => const SelectEndpointPage(),
            ),
          ],
        ),
      ],
    );

    return MaterialApp.router(
      routerConfig: router,
      theme: OBSSwitchTheme.dark(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AppScaffold extends ConsumerWidget {
  final Widget body;
  final String pageTitle;
  const AppScaffold({required this.body, required this.pageTitle, super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: null,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text(pageTitle),
          actions: [
            IconButton(
              icon: const Icon(Icons.link),
              onPressed: () => context.go(Routes.selectEndpoint.path),
              // onPressed: () => ref
              // .read(dialogSpawnerProvider.notifier)
              // .spawn(const SelectEndpointDialog()),
            ),
          ],
        ),
        drawer: null,
        body: Padding(
          padding: const EdgeInsets.all(30),
          child: GoNavigatorListener(
            child: DialogListener(child: SnackbarListener(child: body)),
          ),
        ),
      ),
    );
  }
}

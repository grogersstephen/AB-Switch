import 'dart:async';
import 'package:obs_production_switcher/src/app.dart';
import 'package:obs_production_switcher/src/modules/client/client.dart';

extension KeepAlive on ClientP {
  Future<bool> testConnection() async {
    try {
      final response = await getVersion();
      if (response.obsVersion.isEmpty) {
        return false;
      }
    } catch (e) {
      return false;
    }
    return true;
  }

  keepAlive({final Duration period = const Duration(seconds: 5)}) {
    Timer.periodic(period, (timer) {
      testConnection().then((ok) {
        if (!ok) {
          timer.cancel();
          snackbar("lost connection to host", backgroundColor: Colors.red);
          goNavigate(Routes.selectEndpoint.path);
        }
      });
    });
  }
}

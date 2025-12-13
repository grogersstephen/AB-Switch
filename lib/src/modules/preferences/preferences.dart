import 'dart:convert';
import 'package:flutter/widgets.dart';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shared_preferences/shared_preferences.dart';

AsyncSnapshot<List<WSCredential>> useCredentials() {
  final prefs = usePreferences();
  if (!prefs.hasData) {
    return const AsyncSnapshot.waiting();
  }
  final result = prefs.requireData.wsCredentials ?? [];
  return AsyncSnapshot.withData(ConnectionState.active, result);
}

AsyncSnapshot<Preferences> usePreferences() {
  final value = useMemoized<Future<Preferences>>(() async {
    return await Preferences.instance;
  });
  return useFuture(value);
}

class WSCredential {
  String? name;
  String host;
  int port;
  String password;
  WSCredential({
    this.name,
    required this.host,
    required this.port,
    required this.password,
  });

  String get url => "ws://$host:$port";
  Map<String, dynamic> toJson() => {
    "name": name,
    "host": host,
    "port": port,
    "password": password,
  };

  @override
  String toString() => jsonEncode(toJson());

  static List<Map<String, dynamic>> listToJson(
    List<WSCredential> credentials,
  ) => credentials.map<Map<String, dynamic>>((e) => e.toJson()).toList();

  static String listToString(List<WSCredential> credentials) =>
      jsonEncode(listToJson(credentials));

  static List<WSCredential> listFromJson(List<dynamic> data) {
    final List<WSCredential> result = [];
    for (final e in data) {
      final cred = WSCredential.fromJson(e as Map<String, dynamic>);
      result.add(cred);
    }
    return result;
  }

  static List<WSCredential> listDeepCopy(List<WSCredential> creds) =>
      List.generate(creds.length, (i) => creds[i].deepCopy());

  static bool listDeepEquals(
    List<WSCredential> first,
    List<WSCredential> second,
  ) => (listToString(first) == listToString(second));

  static WSCredential fromJson(Map<String, dynamic> json) {
    return WSCredential(
      name: json["name"],
      host: json["host"],
      port: json["port"],
      password: json["password"],
    );
  }

  bool deepEquals(WSCredential other) {
    return toString() == other.toString();
  }

  bool isInList(List<WSCredential> list) {
    for (final e in list) {
      if (deepEquals(e)) {
        return true;
      }
    }
    return false;
  }

  WSCredential copyWith({
    String? name,
    String? host,
    int? port,
    String? password,
  }) {
    return WSCredential(
      name: name ?? this.name,
      host: host ?? this.host,
      port: port ?? this.port,
      password: password ?? this.password,
    );
  }

  WSCredential deepCopy() =>
      WSCredential(name: name, host: host, port: port, password: password);
}

enum PreferenceKeys { wsCredentials }

class Preferences {
  final SharedPreferences _prefs;

  static Future<Preferences> get instance async {
    return Preferences.withPrefs(await SharedPreferences.getInstance());
  }

  Preferences.withPrefs(SharedPreferences prefs) : _prefs = prefs;

  addCredential(WSCredential value) {
    final credentials = WSCredential.listDeepCopy(wsCredentials ?? []);
    if (value.isInList(credentials)) {
      return;
    }
    credentials.add(value);
    wsCredentials = credentials;
  }

  clearCredentials() {
    wsCredentials = [];
  }

  List<WSCredential>? get wsCredentials {
    final data = _prefs.getString(PreferenceKeys.wsCredentials.name);
    if (data == null) {
      return null;
    }
    final List<dynamic> json = jsonDecode(data) as List<dynamic>;
    final List<WSCredential> result = [];
    for (final e in json) {
      result.add(WSCredential.fromJson(e as Map<String, dynamic>));
    }
    return result;
  }

  set wsCredentials(List<WSCredential>? credentials) {
    if (credentials == null) {
      _prefs.remove(PreferenceKeys.wsCredentials.name);
      return;
    }
    final List<Map<String, dynamic>> data = WSCredential.listToJson(
      credentials,
    );
    _prefs.setString(PreferenceKeys.wsCredentials.name, jsonEncode(data));
  }
}

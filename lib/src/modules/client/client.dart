import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:obs_production_switcher/src/modules/preferences/preferences.dart';
import 'package:obs_websocket/event.dart';
import 'package:obs_websocket/obs_websocket.dart';

typedef Callback = Function(String);

abstract interface class OBSClient {
// ObsWebSocket _socket;
// OBSClient.withSocket(ObsWebSocket socket) : _socket = socket;
  OBSClient.withSocket(ObsWebSocket socket);

  Future<VersionResponse> getVersion();

  Future<List<String>> getSupportedImageFormats();

  onSceneNameChanged(Function(dynamic) listener);
  onSceneItemSelected(Function(dynamic) listener);
  onProgramSceneChanged(


  triggerTransition();

  Future<SceneListResponse> getSceneList();

  Future<List<SceneItemDetail>> getSceneItemList(String sceneName);
}

class OBSClientImpl implements OBSClient {
  final ObsWebSocket _socket;
  OBSClientImpl.withSocket(ObsWebSocket socket) : _socket = socket;

  @override
  Future<VersionResponse> getVersion() => _socket.general.version;

  @override
  Future<List<String>> getSupportedImageFormats() async {
    return (await getVersion()).supportedImageFormats;
  }

  @override
  onSceneNameChanged(Function(dynamic) listener) =>
      _socket.addHandler<SceneNameChanged>(listener);

  @override
  onSceneItemSelected(Function(dynamic) listener) =>
      _socket.addHandler<SceneItemSelected>(listener);

  @override
  triggerTransition() => _socket.transitions.triggerStudioModeTransition();

  @override
  getSceneList() => _socket.scenes.getSceneList();

  @override
  Future<List<SceneItemDetail>> getSceneItemList(String sceneName) =>
      _socket.sceneItems.getSceneItemList(sceneName);
}

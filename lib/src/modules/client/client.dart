import 'dart:ui';
import 'dart:async';
import 'dart:typed_data';
import 'package:obs_websocket/event.dart';
import 'package:obs_websocket/obs_websocket.dart';
import 'package:obs_production_switcher/src/modules/gonavigator/gonavigator.dart';
import 'package:obs_production_switcher/src/modules/client/keep_alive.dart';
import 'package:obs_production_switcher/src/modules/snackbar/snackbar.dart';
export 'package:flutter/material.dart' show Colors;

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'client.g.dart';

@Riverpod(keepAlive: true)
class ClientP extends _$ClientP {
  @override
  OBSClient build() {
    return const NoOpClient();
  }

  goNavigate(String path) =>
      ref.read(goNavigatorProvider.notifier).navigate(path);

  snackbar(String message, {Color? backgroundColor}) => ref
      .read(snackbarMsgProvider.notifier)
      .send(SnackbarMessage(message, backgroundColor: backgroundColor));

  getVersion() => state.getVersion();

  resetToNoOp() {
    state = const NoOpClient();
  }

  update(FutureOr<OBSClient> value) async {
    final result = await value;
    if (result is Client) {
      keepAlive();
    }
    state = result;
  }
}

abstract interface class OBSClient {
  Future<VersionResponse> getVersion();
  Future<bool> isImageFormatSupported(String imageFormat);
  startRecord();
  stopRecord();
  toggleRecord();
  startStream();
  stopStream();
  toggleStream();

  Future<SceneListResponse> getSceneList();
  Future<List<SceneItemDetail>> getSceneItemList(String sceneName);
  Future<String> getCurrentProgramScene();
  Future<String> getCurrentPreviewScene();
  Future<Uint8List> getSceneImage(String sceneName);
  Future<bool> getStudioModeEnabled();

  // Streams
  Stream<bool> yieldRecordingStatus();
  Stream<bool> yieldStreamingStatus();
  Stream<List<Scene>> yieldSceneList();
  Stream<Map<String, Uint8List>> yieldSceneImages();
  Stream<String> yieldProgramSceneName();
  Stream<String> yieldPreviewSceneName();
  Stream<bool> yieldStudioModeEnabled();

  getSourceScreenshot(String sourceName);

  // Setters
  setCurrentPreviewScene(String sceneName);
  setCurrentProgramScene(String sceneName);
  setStudioModeEnabled(bool value);
  setTBarPosition(double value);

  triggerStudioModeTransition();
}

class Client implements OBSClient {
  final ObsWebSocket socket;
  Client(this.socket) {
    socket.subscribe(EventSubscription.all);
  }
  @override
  Future<VersionResponse> getVersion() => socket.general.version;
  @override
  Future<bool> isImageFormatSupported(String imageFormat) async {
    final supported = (await getVersion()).supportedImageFormats;
    return supported.contains(imageFormat);
  }

  @override
  startRecord() => socket.record.start();
  @override
  stopRecord() => socket.record.stop();
  @override
  toggleRecord() => socket.record.toggle();
  @override
  startStream() => socket.stream.start();
  @override
  stopStream() => socket.stream.stop();
  @override
  toggleStream() => socket.stream.toggle();

  @override
  Future<SceneListResponse> getSceneList() => socket.scenes.getSceneList();

  @override
  Stream<bool> yieldRecordingStatus() {
    final ctl = StreamController<bool>();
    // Get the initial status
    socket.record
        .getRecordStatus()
        .then((RecordStatusResponse status) {
          ctl.add(status.outputActive);
        })
        .catchError((_) {
          // TODO log error
        });
    // Listen to changes
    socket.addHandler<RecordStateChanged>((RecordStateChanged change) {
      ctl.add(change.outputActive);
    });
    // Return the stream
    return ctl.stream;
  }

  @override
  Stream<bool> yieldStreamingStatus() {
    final ctl = StreamController<bool>();
    // Get the initial status
    socket.stream
        .getStreamStatus()
        .then((status) {
          ctl.add(status.outputActive);
        })
        .catchError((_) {
          // TODO log error
        });
    // Listen to changes
    socket.addHandler<StreamStateChanged>((StreamStateChanged change) {
      ctl.add(change.outputActive);
    });
    // Return the stream
    return ctl.stream;
  }

  @override
  Stream<String> yieldProgramSceneName() {
    final ctl = StreamController<String>();
    // Get the initial program scene
    getCurrentProgramScene()
        .then((sceneName) {
          ctl.add(sceneName);
        })
        .catchError((_) {
          // TODO log error
        });
    // Listen to changes
    socket.addHandler<CurrentProgramSceneChanged>((
      CurrentProgramSceneChanged change,
    ) {
      ctl.add(change.sceneName);
    });
    // Return the stream
    return ctl.stream;
  }

  @override
  Stream<String> yieldPreviewSceneName() {
    final ctl = StreamController<String>();
    // Get the initial preview scene
    getCurrentPreviewScene()
        .then((sceneName) {
          ctl.add(sceneName);
        })
        .catchError((_) {
          // an error is thrown when the ui is not in studio mode
          null;
        });

    // Listen to changes
    socket.addHandler<CurrentPreviewSceneChanged>((
      CurrentPreviewSceneChanged change,
    ) {
      ctl.add(change.sceneName);
    });
    // Return the stream
    return ctl.stream;
  }

  @override
  Stream<List<Scene>> yieldSceneList({
    Duration period = const Duration(milliseconds: 1000),
  }) {
    final ctl = StreamController<List<Scene>>();
    // Get the initial scene list
    getSceneList()
        .then((response) {
          ctl.add(response.scenes);
        })
        .catchError((_) {
          // TODO: log error
        });
    // Listen to changes
    socket.addHandler<SceneListChanged>((SceneListChanged change) {
      ctl.add(change.scenes);
    });
    // Return the stream
    return ctl.stream;
  }

  Stream<Map<String, List<SceneItemDetail>>> yieldSceneItemList({
    Duration period = const Duration(milliseconds: 1000),
  }) async* {
    while (true) {
      // Get the scene names
      final List<String> names = await getSceneNames();
      // Get each scene details
      final List<List<SceneItemDetail>> details = await Future.wait(
        List.generate((names.length), (i) => getSceneItemList(names[i])),
      );
      // Yield the map
      yield Map.fromIterables(names, details);

      // Wait the period
      await Future.delayed(period);
    }
  }

  Future<List<String>> getSceneNames() async {
    return (await getSceneList()).scenes.map((s) => s.sceneName).toList();
  }

  @override
  Future<List<SceneItemDetail>> getSceneItemList(String sceneName) =>
      socket.sceneItems.getSceneItemList(sceneName);

  @override
  Future<String> getCurrentProgramScene() =>
      socket.scenes.getCurrentProgramScene();

  @override
  Future<String> getCurrentPreviewScene() async {
    if (await getStudioModeEnabled()) {
      return socket.scenes.getCurrentPreviewScene();
    }
    throw Exception("studio mode is not enabled");
  }

  @override
  Future<Uint8List> getSceneImage(String sceneName) async {
    final sceneItems = await getSceneItemList(sceneName);
    final firstItem = sceneItems.firstOrNull;
    if (firstItem == null) {
      return Uint8List(0);
    }
    return (await getSourceScreenshot(firstItem.sourceName)).bytes;
  }

  @override
  Future<bool> getStudioModeEnabled() => socket.ui.getStudioModeEnabled();

  @override
  setStudioModeEnabled(bool value) => socket.ui.setStudioModeEnabled(value);

  @override
  setTBarPosition(double value, {bool release = true}) {
    print("setting the tbar position: $value");
    // socket.send("SetTBarPosition", {"position": value, "release": release});
	// TODO: fix release maybe? this seems to be doing something, but not working right
    socket.sendRequest(
      Request(
        "SetTBarPosition",
        requestData: {"position": value, "release": release},
      ),
    );
  }

  @override
  Stream<Map<String, Uint8List>> yieldSceneImages({
    Duration period = const Duration(milliseconds: 1000),
    int maxFailures = 10,
  }) async* {
    // Set a failure counter
    int failureCounter = 0;
    while (true) {
      // Get the scene names
      final List<String> names = await getSceneNames();
      // Get the scene images
      final List<Uint8List> images = await Future.wait(
        List.generate(names.length, (i) {
          try {
            return getSceneImage(names[i]);
          } catch (e) {
            failureCounter++;
          }
          return Future.value(Uint8List(0));
        }),
      );
      // Handler failure counter
      if (failureCounter > maxFailures) {
        break;
      }
      // Yield the map
      yield Map.fromIterables(names, images);
      // Wait the period
      await Future.delayed(period);
    }
  }

  @override
  yieldStudioModeEnabled() {
    final ctl = StreamController<bool>();
    // Get the initial scene list
    getStudioModeEnabled()
        .then((bool value) {
          ctl.add(value);
        })
        .catchError((_) {
          // TODO log error
        });
    // Listen to changes
    socket.addHandler<StudioModeStateChanged>((StudioModeStateChanged change) {
      ctl.add(change.studioModeEnabled);
    });
    // Return the stream
    return ctl.stream;
  }

  @override
  Future<SourceScreenshotResponse> getSourceScreenshot(
    String sourceName, {
    String imageFormat = "jpeg",
  }) async {
    final isSupported = await isImageFormatSupported(imageFormat);
    if (!isSupported) {
      throw Exception(
        "cannot get screenshot: $imageFormat is not a supported image format",
      );
    }
    return await socket.sources.getSourceScreenshot(
      SourceScreenshot(sourceName: sourceName, imageFormat: "jpeg"),
    );
  }

  @override
  setCurrentPreviewScene(String sceneName) =>
      socket.scenes.setCurrentPreviewScene(sceneName);

  @override
  setCurrentProgramScene(String sceneName) =>
      socket.scenes.setCurrentProgramScene(sceneName);

  @override
  triggerStudioModeTransition() =>
      socket.transitions.triggerStudioModeTransition();
}

class NoOpClient implements OBSClient {
  const NoOpClient();
  @override
  Future<VersionResponse> getVersion() {
    throw UnimplementedError();
  }

  @override
  Future<bool> isImageFormatSupported(String imageFormat) {
    throw UnimplementedError();
  }

  @override
  startRecord() {
    throw UnimplementedError();
  }

  @override
  stopRecord() {
    throw UnimplementedError();
  }

  @override
  toggleRecord() {
    throw UnimplementedError();
  }

  @override
  startStream() {
    throw UnimplementedError();
  }

  @override
  stopStream() {
    throw UnimplementedError();
  }

  @override
  toggleStream() {
    throw UnimplementedError();
  }

  @override
  Future<SceneListResponse> getSceneList() {
    throw UnimplementedError();
  }

  @override
  Future<List<SceneItemDetail>> getSceneItemList(String sceneName) {
    throw UnimplementedError();
  }

  @override
  Future<String> getCurrentProgramScene() {
    throw UnimplementedError();
  }

  @override
  Future<String> getCurrentPreviewScene() {
    throw UnimplementedError();
  }

  @override
  Future<Uint8List> getSceneImage(String sceneName) {
    throw UnimplementedError();
  }

  @override
  getSourceScreenshot(String sourceName) {
    throw UnimplementedError();
  }

  @override
  getStudioModeEnabled() {
    throw UnimplementedError();
  }

  // Setters
  @override
  setCurrentPreviewScene(String sceneName) {
    throw UnimplementedError();
  }

  @override
  setCurrentProgramScene(String sceneName) {
    throw UnimplementedError();
  }

  @override
  setStudioModeEnabled(bool value) {
    throw UnimplementedError();
  }

  @override
  setTBarPosition(double value) {
    throw UnimplementedError();
  }

  @override
  triggerStudioModeTransition() {
    throw UnimplementedError();
  }

  @override
  Stream<bool> yieldRecordingStatus() {
    throw UnimplementedError();
  }

  @override
  Stream<bool> yieldStreamingStatus() {
    throw UnimplementedError();
  }

  @override
  Stream<List<Scene>> yieldSceneList({
    Duration period = const Duration(milliseconds: 1000),
  }) async* {
    throw UnimplementedError();
  }

  @override
  Stream<Map<String, Uint8List>> yieldSceneImages() {
    throw UnimplementedError();
  }

  @override
  Stream<String> yieldProgramSceneName() {
    throw UnimplementedError();
  }

  @override
  Stream<String> yieldPreviewSceneName() {
    throw UnimplementedError();
  }

  @override
  Stream<bool> yieldStudioModeEnabled() {
    throw UnimplementedError();
  }
}

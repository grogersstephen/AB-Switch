import 'dart:async';
import 'dart:typed_data';
import 'package:obs_websocket/event.dart';
import 'package:obs_websocket/obs_websocket.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'client.g.dart';

@Riverpod(keepAlive: true)
class ClientP extends _$ClientP {
  @override
  OBSClient build() => const NoOpClient();

  update(OBSClient value) {
    state = value;
  }

  updateWithFuture(Future<OBSClient> value) async {
    state = await value;
  }
}

@Riverpod(keepAlive: true)
Stream<VersionResponse> clientKeepAlive(Ref ref) async* {
  bool active = true;
  ref.onDispose(() => active = false);
  while (active) {
    final client = ref.read(clientPProvider);
    await Future.delayed(const Duration(seconds: 5));
    yield await client.getVersion();
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

  // Streams
  Stream<bool> yieldRecordingStatus();
  Stream<bool> yieldStreamingStatus();
  Stream<List<Scene>> yieldSceneList();
  Stream<Map<String, Uint8List>> yieldSceneImages();
  Stream<String> yieldProgramSceneName();
  Stream<String> yieldPreviewSceneName();

  getSourceScreenshot(String sourceName);

  // Setters
  setCurrentPreviewScene(String sceneName);

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
    socket.record.getRecordStatus().then((RecordStatusResponse status) {
      ctl.add(status.outputActive);
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
    socket.stream.getStreamStatus().then((status) {
      ctl.add(status.outputActive);
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
    getCurrentProgramScene().then((sceneName) {
      ctl.add(sceneName);
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
    getCurrentPreviewScene().then((sceneName) {
      ctl.add(sceneName);
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
    getSceneList().then((response) {
      ctl.add(response.scenes);
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
  Future<String> getCurrentPreviewScene() =>
      socket.scenes.getCurrentPreviewScene();

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

  // Setters
  @override
  setCurrentPreviewScene(String sceneName) {
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
}

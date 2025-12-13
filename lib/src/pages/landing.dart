import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:obs_websocket/event.dart';
import 'package:obs_websocket/obs_websocket.dart';

class LandingPage extends StatelessWidget {
  final ObsWebSocket? obs;
  const LandingPage(this.obs, {super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        obs != null
            ? Expanded(child: InputsGrid(obs!))
            : const Expanded(child: Text("Connect to OBS")),
        const SizedBox(height: 40),
        _goButton(),
        Row(children: [_startRecordButton(), _stopRecordButton()]),
        // const Spacer(),
      ],
    );
  }

  _goButton() {
    return GestureDetector(
      onTap: obs?.transitions.triggerStudioModeTransition,
      child: Container(
        width: 200,
        height: 100,
        decoration: BoxDecoration(border: Border.all(width: 4)),
        child: const Center(child: Text("GO", style: TextStyle(fontSize: 50))),
      ),
    );
  }

  _startRecordButton() {
    return GestureDetector(
      onTap: obs?.record.startRecord,
      child: Container(
        width: 160,
        height: 70,
        decoration: BoxDecoration(border: Border.all(width: 4)),
        child: const Center(
          child: Text("Start Record", style: TextStyle(fontSize: 25)),
        ),
      ),
    );
  }

  _stopRecordButton() {
    return GestureDetector(
      onTap: obs?.record.stopRecord,
      child: Container(
        width: 160,
        height: 70,
        decoration: BoxDecoration(border: Border.all(width: 4)),
        child: const Center(
          child: Text("Stop Record", style: TextStyle(fontSize: 25)),
        ),
      ),
    );
  }
}

class InputsGrid extends HookWidget {
  final ObsWebSocket obs;

  const InputsGrid(this.obs, {super.key});
  @override
  Widget build(BuildContext context) {
    final scenesNot = useState<List<Scene>>([]);
    final sceneItems = useState<Map<String, List<SceneItemDetail>>>({});
    final sceneImages = useState<Map<String, Uint8List>>({});
    final programSceneName = useState<String>("");
    final previewSceneName = useState<String>("");
    useEffect(() {
      obs.scenes.getSceneList().then(
        (response) async {
          scenesNot.value = response.scenes;
          for (final scene in scenesNot.value) {
            final newMap = Map.from(sceneItems.value);
            final items = await obs.sceneItems.getSceneItemList(
              scene.sceneName,
            );
            newMap[scene.sceneName] = items;
            sceneItems.value = Map.from(newMap);
          }

          final version = await obs.general.version;
          final formats = version.supportedImageFormats;
          print("image formats");
          print(formats.map((e) => e));
          String imageFormat = formats.contains("jpeg") ? "jpeg" : "";

          print("sceneItems: ");
          for (final sc in sceneItems.value.entries) {
            print("${sc.key}:${sc.value.map((e) => e.sourceName)}");
          }
          final simap = Map.from(sceneImages.value);
          for (final item in sceneItems.value.entries) {
            if (item.value.isEmpty) {
              continue;
            }
            final SceneItemDetail firstSource = item.value.first;
            final result = await obs.sources.getSourceScreenshot(
              SourceScreenshot(
                sourceName: firstSource.sourceName,
                imageFormat: imageFormat,
              ),
            );
            print("got results");
            print("length of bytes: ${result.bytes.length}");
            simap[item.key] = result.bytes;
            sceneImages.value = Map.from(simap);
          }
        },
        onError: (e) {
          scenesNot.value = [];
          sceneItems.value = {};
        },
      );
      obs.addHandler<CurrentProgramSceneChanged>((change) async {
        programSceneName.value = change.sceneName;
      });
      obs.addHandler<CurrentPreviewSceneChanged>((change) async {
        previewSceneName.value = change.sceneName;
      });
      obs.scenes.getCurrentProgramScene().then(
        (sceneName) {
          programSceneName.value = sceneName;
        },
        onError: (e) {
          programSceneName.value = "";
        },
      );
      obs.scenes.getCurrentPreviewScene().then(
        (sceneName) {
          previewSceneName.value = sceneName;
        },
        onError: (e) {
          previewSceneName.value = "";
        },
      );
      return () {};
    }, []);
    final screenSize = MediaQuery.of(context).size;
    return GridView.count(
      crossAxisCount: screenSize.width ~/ 200,
      mainAxisSpacing: 25,
      crossAxisSpacing: 25,
      children: List<Widget>.generate(scenesNot.value.length, (i) {
        final scene = scenesNot.value[i];
        final isProgramScene = scene.sceneName == programSceneName.value;
        final isPreviewScene = scene.sceneName == previewSceneName.value;
        final Uint8List? imageBytes = sceneImages.value[scene.sceneName];
        return GestureDetector(
          onTap: () {
            obs.scenes.setCurrentPreviewScene(scene.sceneName);
          },
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              border: Border.all(
                color: isProgramScene
                    ? Colors.red
                    : isPreviewScene
                    ? Colors.green
                    : Colors.white,
                width: isProgramScene || isPreviewScene ? 8.0 : 2.0,
              ),
            ),
            child: Stack(
              children: [
                imageBytes != null
                    ? Center(
                        child: Image.memory(imageBytes, fit: BoxFit.contain),
                      )
                    : const SizedBox.shrink(),
                Center(
                  child: Text(
                    scene.sceneName,
                    style: const TextStyle(fontSize: 30, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

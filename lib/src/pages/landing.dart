import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:obs_production_switcher/src/widgets/buttons.dart';
import 'package:obs_production_switcher/src/modules/client/client.dart';

class LandingPage extends HookConsumerWidget {
  // final ObsWebSocket? socket;
  const LandingPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final client = ref.watch(clientPProvider);
    final recording = useStream(client.yieldRecordingStatus());
    final streaming = useStream(client.yieldStreamingStatus());
    if (client is NoOpClient) {
      return const Center(child: Text("Connect to OBS"));
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(child: InputsGrid(client)),
        const SizedBox(height: 40),
        GoButton(client.triggerStudioModeTransition),
        Row(
          children: [
            ToggleButton(
              client.toggleRecord,
              label: recording.data == true ? "Stop Record" : "Start Record",
              borderColor: recording.data == true ? Colors.red : Colors.white,
            ),
            ToggleButton(
              client.toggleStream,
              label: streaming.data == true ? "Stop Stream" : "Start Stream",
              borderColor: streaming.data == true ? Colors.red : Colors.white,
            ),
          ],
        ),
        // const Spacer(),
      ],
    );
  }
}

class InputsGrid extends HookWidget {
  final OBSClient client;

  const InputsGrid(this.client, {super.key});
  @override
  Widget build(BuildContext context) {
    final scenes = useStream(client.yieldSceneList());
    // final sceneImages = useStream(client.yieldSceneImages());
    final sceneImages = useStream(const Stream.empty());
    final programSceneName = useStream(client.yieldProgramSceneName());
    final previewSceneName = useStream(client.yieldPreviewSceneName());

    final screenSize = MediaQuery.of(context).size;
    return GridView.count(
      crossAxisCount: screenSize.width ~/ 200,
      mainAxisSpacing: 25,
      crossAxisSpacing: 25,
      children: List<Widget>.generate(scenes.data?.length ?? 0, (i) {
        final scene = scenes.data?[i];
        final sceneName = scene?.sceneName;
        final isProgramScene = sceneName == programSceneName.data;
        final isPreviewScene = sceneName == previewSceneName.data;
        final Uint8List? imageBytes = sceneImages.data?[sceneName];
        return GestureDetector(
          onTap: sceneName == null
              ? null
              : () {
                  client.setCurrentPreviewScene(sceneName);
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
                  child: sceneName == null
                      ? null
                      : Text(
                          sceneName,
                          style: const TextStyle(
                            fontSize: 30,
                            color: Colors.white,
                          ),
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

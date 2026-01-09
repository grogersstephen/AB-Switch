import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:obs_production_switcher/src/widgets/buttons.dart';
import 'package:obs_production_switcher/src/widgets/t-bar.dart';
import 'package:obs_production_switcher/src/modules/client/client.dart';
import 'package:obs_production_switcher/src/widgets/double_bordered_container.dart';

class LandingPage extends HookConsumerWidget {
  const LandingPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final client = ref.watch(clientPProvider);
    if (client is NoOpClient) {
      return const Center(child: Text("Connect to OBS"));
    }
    final recording = useStream(client.yieldRecordingStatus());
    final streaming = useStream(client.yieldStreamingStatus());
    final studioModeEnabled = useStream(client.yieldStudioModeEnabled());
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(child: InputsGrid(client)),
        const SizedBox(height: 40),
        studioModeEnabled.data == true
            ? Row(
                children: [
                  GoButton(client.triggerStudioModeTransition),
                  TBar(
                    initialValue: 0,
                    onChanged: (value) {
                      client.setTBarPosition(value);
                    },
                  ),
                ],
              )
            : const SizedBox.shrink(),
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
    final sceneImages = useStream(const Stream.empty());
    final programSceneName = useStream(client.yieldProgramSceneName());
    final previewSceneName = useStream(client.yieldPreviewSceneName());
    final studioModeEnabled = useStream(client.yieldStudioModeEnabled());

    final screenSize = MediaQuery.of(context).size;
    final length = scenes.data?.length ?? 0;
    return GridView.count(
      crossAxisCount: screenSize.width ~/ 200,
      mainAxisSpacing: 25,
      crossAxisSpacing: 25,
      children: List<Widget>.generate(length, (i) {
        final scene = scenes.data?[length - i - 1];
        final sceneName = scene?.sceneName;
        final isProgramScene = sceneName == programSceneName.data;
        final isPreviewScene = sceneName == previewSceneName.data;
        final isInStudioMode = studioModeEnabled.data == true;
        final Uint8List? imageBytes = sceneImages.data?[sceneName];
        Color innerBorderColor = Colors.white;
        Color outerBorderColor = Colors.white;
        double innerBorderWidth = 0.0;
        double outerBorderWidth = 2.0;
        if (isProgramScene) {
          innerBorderColor = Colors.red;
          outerBorderColor = Colors.red;
          innerBorderWidth = 0.0;
          outerBorderWidth = 8.0;
        }
        if (isInStudioMode && isPreviewScene) {
          if (isProgramScene) {
            innerBorderColor = Colors.red;
            outerBorderColor = Colors.green;
            innerBorderWidth = 6.0;
            outerBorderWidth = 3.0;
          } else {
            innerBorderColor = Colors.green;
            outerBorderColor = Colors.green;
            innerBorderWidth = 0.0;
            outerBorderWidth = 8.0;
          }
        }
        return GestureDetector(
          onTap: sceneName == null
              ? null
              : () {
                  studioModeEnabled.data == true
                      ? client.setCurrentPreviewScene(sceneName)
                      : client.setCurrentProgramScene(sceneName);
                },
          child: DoubleBorderedContainer(
            innerBorderColor: innerBorderColor,
            outerBorderColor: outerBorderColor,
            innerBorderWidth: innerBorderWidth,
            outerBorderWidth: outerBorderWidth,
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

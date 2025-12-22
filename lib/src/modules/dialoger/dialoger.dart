import 'package:flutter/material.dart';
import 'dart:async';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

export 'package:flutter/material.dart' show Colors;

part 'dialoger.g.dart';

class CustomDialog {
  final Widget widget;
  final bool barrierDismissable;
  CustomDialog({required this.widget, this.barrierDismissable = true});
}

@Riverpod(keepAlive: true)
class DialogSpawner extends _$DialogSpawner {
  final ctl = StreamController<CustomDialog>();

  @override
  Stream<CustomDialog> build() => ctl.stream;

  spawn(Widget widget, {bool barrierDismissable = true}) {
    final data = CustomDialog(
      widget: widget,
      barrierDismissable: barrierDismissable,
    );
    ctl.add(data);
  }
}

class DialogListener extends ConsumerWidget {
  final Widget child;
  const DialogListener({required this.child, super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen for Dialog updates
    ref.listen(dialogSpawnerProvider, (prev, next) {
      final dialog = next.value;
      if (dialog == null) {
        return;
      }
      showDialog(
        context: context,
        barrierDismissible: dialog.barrierDismissable,
        builder: (context) => dialog.widget,
      );
    });

    return child;
  }
}

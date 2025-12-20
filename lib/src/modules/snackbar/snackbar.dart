import 'package:flutter/material.dart';
import 'dart:async';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

export 'package:flutter/material.dart' show Colors;

part 'snackbar.g.dart';

@Riverpod(keepAlive: true)
class SnackbarMsg extends _$SnackbarMsg {
  final ctl = StreamController<SnackbarMessage>();

  @override
  Stream<SnackbarMessage> build() => ctl.stream;

  send(SnackbarMessage message) {
    ctl.add(message);
  }
}

class SnackbarMessage {
  final String message;
  final Color _backgroundColor;
  const SnackbarMessage(this.message, {Color? backgroundColor})
    : _backgroundColor = backgroundColor ?? Colors.green;
}

class SnackbarListener extends ConsumerWidget {
  final Widget child;
  const SnackbarListener({required this.child, super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen for snackbar updates
    ref.listen(snackbarMsgProvider, (prev, next) {
      final message = next.value;
      if (message == null) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message.message, textAlign: TextAlign.center),
          duration: const Duration(seconds: 4),
          backgroundColor: message._backgroundColor,
        ),
      );
    });

    return child;
  }
}

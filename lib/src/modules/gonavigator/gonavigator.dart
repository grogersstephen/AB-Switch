import 'package:flutter/material.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'gonavigator.g.dart';

@Riverpod(keepAlive: true)
class GoNavigator extends _$GoNavigator {
  final ctl = StreamController<String>();

  @override
  Stream<String> build() => ctl.stream;

  navigate(String path) => ctl.add(path);
}

class GoNavigatorListener extends ConsumerWidget {
  final Widget child;
  const GoNavigatorListener({required this.child, super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen for Navigator updates
    ref.listen(goNavigatorProvider, (prev, next) {
      final path = next.value;
      if (path == null) {
        return;
      }
      context.go(path);
    });

    return child;
  }
}

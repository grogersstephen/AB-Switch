// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'snackbar.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SnackbarMsg)
const snackbarMsgProvider = SnackbarMsgProvider._();

final class SnackbarMsgProvider
    extends $StreamNotifierProvider<SnackbarMsg, SnackbarMessage> {
  const SnackbarMsgProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'snackbarMsgProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$snackbarMsgHash();

  @$internal
  @override
  SnackbarMsg create() => SnackbarMsg();
}

String _$snackbarMsgHash() => r'dec86089a48e6b0b9af25f3b1365378605d8b426';

abstract class _$SnackbarMsg extends $StreamNotifier<SnackbarMessage> {
  Stream<SnackbarMessage> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<SnackbarMessage>, SnackbarMessage>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<SnackbarMessage>, SnackbarMessage>,
        AsyncValue<SnackbarMessage>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}

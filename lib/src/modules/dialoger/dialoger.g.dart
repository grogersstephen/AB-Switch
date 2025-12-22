// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dialoger.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DialogSpawner)
const dialogSpawnerProvider = DialogSpawnerProvider._();

final class DialogSpawnerProvider
    extends $StreamNotifierProvider<DialogSpawner, CustomDialog> {
  const DialogSpawnerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'dialogSpawnerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$dialogSpawnerHash();

  @$internal
  @override
  DialogSpawner create() => DialogSpawner();
}

String _$dialogSpawnerHash() => r'e8d5eca73e7a2e5b0f4393f013464b91dae3e514';

abstract class _$DialogSpawner extends $StreamNotifier<CustomDialog> {
  Stream<CustomDialog> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<CustomDialog>, CustomDialog>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<CustomDialog>, CustomDialog>,
        AsyncValue<CustomDialog>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}

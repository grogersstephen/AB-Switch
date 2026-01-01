// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gonavigator.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(GoNavigator)
const goNavigatorProvider = GoNavigatorProvider._();

final class GoNavigatorProvider
    extends $StreamNotifierProvider<GoNavigator, String> {
  const GoNavigatorProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'goNavigatorProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$goNavigatorHash();

  @$internal
  @override
  GoNavigator create() => GoNavigator();
}

String _$goNavigatorHash() => r'788956234b1cf275ffd59c3e8bff5bb71d04e1ca';

abstract class _$GoNavigator extends $StreamNotifier<String> {
  Stream<String> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<String>, String>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<String>, String>,
        AsyncValue<String>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}

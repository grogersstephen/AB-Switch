// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ClientP)
const clientPProvider = ClientPProvider._();

final class ClientPProvider extends $NotifierProvider<ClientP, OBSClient> {
  const ClientPProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'clientPProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$clientPHash();

  @$internal
  @override
  ClientP create() => ClientP();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OBSClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OBSClient>(value),
    );
  }
}

String _$clientPHash() => r'f6d2e52907f86fe2c20c2164e2d4cb4c17b20eda';

abstract class _$ClientP extends $Notifier<OBSClient> {
  OBSClient build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<OBSClient, OBSClient>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<OBSClient, OBSClient>, OBSClient, Object?, Object?>;
    element.handleValue(ref, created);
  }
}

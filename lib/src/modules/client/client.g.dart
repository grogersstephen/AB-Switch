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

String _$clientPHash() => r'6cc352bb72c7633dfb268730779f6adc24f40387';

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

@ProviderFor(clientKeepAlive)
const clientKeepAliveProvider = ClientKeepAliveProvider._();

final class ClientKeepAliveProvider extends $FunctionalProvider<
        AsyncValue<VersionResponse>, VersionResponse, Stream<VersionResponse>>
    with $FutureModifier<VersionResponse>, $StreamProvider<VersionResponse> {
  const ClientKeepAliveProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'clientKeepAliveProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$clientKeepAliveHash();

  @$internal
  @override
  $StreamProviderElement<VersionResponse> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<VersionResponse> create(Ref ref) {
    return clientKeepAlive(ref);
  }
}

String _$clientKeepAliveHash() => r'63a1a0c5f9665e0e0ca87940b33b455640682419';

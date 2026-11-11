import 'package:code_builder/code_builder.dart' as cb;

/// The catalyst_builder runtime package.
const runtimePackage =
    'package:catalyst_builder_runtime/catalyst_builder_runtime.dart';

/// [Service]
final serviceT = cb.refer('Service', runtimePackage);

/// [ServiceDescriptor]
final serviceDescriptorT = cb.refer('ServiceDescriptor', runtimePackage);

/// [ServiceContainer]
final serviceContainerT = cb.refer('ServiceContainer', runtimePackage);

/// [AbstractServiceContainer]
final abstractServiceContainerT =
    cb.refer('AbstractServiceContainer', runtimePackage);

/// [ServiceContainer.resolveByTag]
final resolveByTag$ = cb.refer('resolveByTag');

/// tryResolveOrGetParameter method
final tryResolveOrGetParameter$ = cb.refer('tryResolveOrGetParameter');

/// resolveOrGetParameter method
final resolveOrGetParameter$ = cb.refer('resolveOrGetParameter');

/// void type
final voidT = cb.refer('void');

/// Type type
final typeT = cb.refer('Type');

/// Symbol type
final symbolT = cb.refer('Symbol');

cb.Reference listOfT(cb.Reference T) => (cb.TypeReferenceBuilder()
      ..symbol = 'List'
      ..types.add(T))
    .build();

cb.Reference mapOfT(cb.Reference tKey, cb.Reference tValue) =>
    (cb.TypeReferenceBuilder()
          ..symbol = 'Map'
          ..types.addAll([tKey, tValue]))
        .build();

/// [ServiceContainer.applyPlugin] method
final applyPlugin$ = cb.refer('applyPlugin');

/// [ServiceContainerPlugin]
final serviceContainerPluginT =
    cb.refer('ServiceContainerPlugin', runtimePackage);

/// provideKnownServices method
final provideKnownServices$ = cb.refer('provideKnownServices');

/// provideExposes method
final provideExposes$ = cb.refer('provideExposes');

/// providePreloadedTypes method
final providePreloadedTypes$ = cb.refer('providePreloadedTypes');

/// provideServiceTags method
final provideServiceTags$ = cb.refer('provideServiceTags');

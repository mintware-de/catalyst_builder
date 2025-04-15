import 'package:code_builder/code_builder.dart' as cb;

/// The catalyst_builder root package.
const contractsPackage =
    'package:catalyst_builder_contracts/catalyst_builder_contracts.dart';

const builderPackage = 'package:catalyst_builder/catalyst_builder.dart';

/// [Service]
final serviceT = cb.refer('Service', contractsPackage);

/// [ServiceDescriptor]
final serviceDescriptorT = cb.refer('ServiceDescriptor', contractsPackage);

/// [ServiceContainer]
final serviceContainerT = cb.refer('ServiceContainer', builderPackage);

/// [AbstractServiceContainer]
final abstractServiceContainerT =
    cb.refer('AbstractServiceContainer', contractsPackage);

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
    cb.refer('ServiceContainerPlugin', contractsPackage);

/// provideKnownServices method
final provideKnownServices$ = cb.refer('provideKnownServices');

/// provideExposes method
final provideExposes$ = cb.refer('provideExposes');

/// providePreloadedTypes method
final providePreloadedTypes$ = cb.refer('providePreloadedTypes');

/// provideServiceTags method
final provideServiceTags$ = cb.refer('provideServiceTags');

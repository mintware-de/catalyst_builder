import 'package:code_builder/code_builder.dart' as cb;

/// The catalyst_builder root package.
const rootPackage =
    'package:catalyst_builder_contracts/catalyst_builder_contracts.dart';

/// [Service]
final serviceT = cb.refer('Service', rootPackage);

/// [ServiceDescriptor]
final serviceDescriptorT = cb.refer('ServiceDescriptor', rootPackage);

/// [ServiceProvider]
final serviceProviderT = cb.refer('ServiceProvider', rootPackage);

/// [ServiceProvider.resolveByTag]
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

/// [ServiceProvider.applyPlugin] method
final applyPlugin$ = cb.refer('applyPlugin');

/// [ServiceProviderPlugin]
final serviceProviderPluginT = cb.refer('ServiceProviderPlugin', rootPackage);

/// provideKnownServices method
final provideKnownServices$ = cb.refer('provideKnownServices');

/// provideExposes method
final provideExposes$ = cb.refer('provideExposes');

/// providePreloadedTypes method
final providePreloadedTypes$ = cb.refer('providePreloadedTypes');

/// provideServiceTags method
final provideServiceTags$ = cb.refer('provideServiceTags');

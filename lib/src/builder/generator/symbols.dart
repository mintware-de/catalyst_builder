import 'package:code_builder/code_builder.dart' as cb;

import '../../../catalyst_builder.dart';

/// The catalyst_builder root package.
const rootPackage = 'package:catalyst_builder/catalyst_builder.dart';

/// [Service]
final serviceT = cb.refer('Service', rootPackage);

/// [ServiceDescriptor]
final serviceDescriptorT = cb.refer('ServiceDescriptor', rootPackage);

/// [ServiceProvider]
final serviceProviderT = cb.refer('ServiceProvider', rootPackage);

/// [ServiceRegistry]
final serviceRegistryT = cb.refer('ServiceRegistry', rootPackage);

/// [EnhanceableProvider]
final enhanceableProviderT = cb.refer('EnhanceableProvider', rootPackage);

/// [LazyServiceDescriptor]
final lazyServiceDescriptorT = cb.refer('LazyServiceDescriptor', rootPackage);

/// [ServiceNotFoundException]
final serviceNotFoundExceptionT =
    cb.refer('ServiceNotFoundException', rootPackage);

/// [DependencyNotFoundException]
final dependencyNotFoundExceptionT =
    cb.refer('DependencyNotFoundException', rootPackage);

/// [ServiceProvider.tryResolve]
final tryResolve$ = cb.refer('tryResolve');

final tryResolveInternal$ = cb.refer('_tryResolveInternal');

/// [ServiceProvider.resolve]
final resolve$ = cb.refer('resolve');

/// [ServiceProvider.resolveByTag]
final resolveByTag$ = cb.refer('resolveByTag');

/// [ServiceProvider.has]
final has$ = cb.refer('has');

/// [ServiceRegistry.register]
final register$ = cb.refer('register');

/// [EnhanceableProvider.enhance]
final enhance$ = cb.refer('enhance');

/// this
final this$ = cb.refer('this');

/// _knownServices field in the service provider
final knownServices$ = cb.refer('_knownServices');

/// _exposeMap field in the service provider
final exposeMap$ = cb.refer('_exposeMap');

/// _serviceInstances field in the service provider
final serviceInstances$ = cb.refer('_serviceInstances');

/// _servicesByTag field in the service provider
final servicesByTag$ = cb.refer('_servicesByTag');

/// parameters field in the service provider
final parameters$ = cb.refer('parameters');

/// _tryResolveOrGetParameter method
final tryResolveOrGetParameter$ = cb.refer('_tryResolveOrGetParameter');

/// _resolveOrGetParameter method
final resolveOrGetParameter$ = cb.refer('_resolveOrGetParameter');

/// [ProviderNotBootedException]
final providerNotBootedExceptionT =
    cb.refer('ProviderNotBootedException', rootPackage);

/// [ProviderAlreadyBootedException]
final providerAlreadyBootedExceptionT =
    cb.refer('ProviderAlreadyBootedException', rootPackage);

/// _booted field in the service provider
final booted$ = cb.refer('_booted');

/// [ServiceProvider.boot] method
final boot$ = cb.refer('boot');

/// ensureBoot method
final ensureBoot$ = cb.refer('_ensureBoot');

/// void type
final voidT = cb.refer('void');

/// Type type
final typeT = cb.refer('Type');

/// Boolean type
final boolT = cb.refer('bool');

/// String type
final stringT = cb.refer('String');

/// dynamic type
final dynamicT = cb.refer('dynamic');

/// Symbol type
final symbolT = cb.refer('Symbol');

cb.Reference listOfT(cb.Reference T) => (cb.TypeReferenceBuilder()
      ..symbol = 'List'
      ..types.add(T))
    .build();

/// Make the reference nullable
cb.Reference nullable(cb.Reference ref) => cb.refer("${ref.symbol}?", ref.url);

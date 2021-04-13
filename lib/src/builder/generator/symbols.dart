import 'package:code_builder/code_builder.dart' as cb;

import '../../../catalyst_builder.dart';

/// The catalyst_builder root package.
final rootPackage = 'package:catalyst_builder/catalyst_builder.dart';

/// [ServiceDescriptor]
final serviceDescriptorT = cb.refer('ServiceDescriptor', rootPackage);

/// [ServiceProvider]
final serviceProviderT = cb.refer('ServiceProvider', rootPackage);

/// [ServiceNotFoundException]
final serviceNotFoundExceptionT =
    cb.refer('ServiceNotFoundException', rootPackage);

/// [DependencyNotFoundException]
final dependencyNotFoundExceptionT =
    cb.refer('DependencyNotFoundException', rootPackage);

/// [ServiceProvider.tryResolve]
final tryResolve$ = cb.refer('tryResolve');

/// [ServiceProvider.resolve]
final resolve$ = cb.refer('resolve');

/// _knownServices field in the service provider
final knownServices$ = cb.refer('_knownServices');

/// _exposeMap field in the service provider
final exposeMap$ = cb.refer('_exposeMap');

/// _serviceInstances field in the service provider
final serviceInstances$ = cb.refer('_serviceInstances');

/// parameters field in the service provider
final parameters$ = cb.refer('parameters');

/// _tryResolveOrGetParameter method
final tryResolveOrGetParameter$ = cb.refer('_tryResolveOrGetParameter');

/// _resolveOrGetParameter method
final resolveOrGetParameter$ = cb.refer('_resolveOrGetParameter');

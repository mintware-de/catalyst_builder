import 'package:catalyst_builder_container/catalyst_builder_container.dart';
import 'package:catalyst_builder_contracts/catalyst_builder_contracts.dart';
import 'package:test/test.dart';

void main() {
  late ServiceProvider serviceProvider;

  resetServiceProvider() {
    serviceProvider = ServiceContainer();
    serviceProvider.applyPlugin(_TestPlugin());
    serviceProvider.parameters['paramOverride'] = 'XYZ';
  }

  setUp(() {
    resetServiceProvider();
    serviceProvider.boot();
  });

  test('try/Resolve should throw when the provider is not booted', () {
    resetServiceProvider();
    expect(
      () => serviceProvider.resolve<String>(),
      throwsA(const TypeMatcher<ContainerNotBootedException>()),
    );
  });

  test('double boot should throw an exception', () {
    expect(
      () => serviceProvider.boot(),
      throwsA(const TypeMatcher<ProviderAlreadyBootedException>()),
    );
  });

  test('tryResolve should not throw if a service was not found', () {
    var result = serviceProvider.tryResolve<String>();
    expect(result, isNull);
  });

  test('resolve should throw if a service was not found', () {
    expect(
      () => serviceProvider.resolve<String>(),
      throwsA(const TypeMatcher<ServiceNotFoundException>()),
    );
  });

  test('try/Resolve should inject parameters for non existing services', () {
    expect(serviceProvider.resolve<_ServiceThatRequiresParameter>().parameter,
        'XYZ');
    expect(
        serviceProvider.tryResolve<_ServiceThatRequiresParameter>()?.parameter,
        'XYZ');
  });

  test('Services can be exposed as a specific type', () {
    var provider = serviceProvider.resolve<_MarkerInterface>();
    expect(provider, const TypeMatcher<_ServiceThatRequiresParameter>());
  });

  test('PreLoaded services should be loaded on boot', () {
    expect(_PreloadService.shouldPreload, isFalse);
    expect(_PreloadService.wasPreloaded, isFalse);
    resetServiceProvider();
    _PreloadService.shouldPreload = true;
    expect(_PreloadService.wasPreloaded, isFalse);
    serviceProvider.boot();
    expect(_PreloadService.wasPreloaded, isTrue);
  });

  test('Singleton Service Lifetime', () {
    var instance1 = serviceProvider.resolve<_MySingleton>();
    var instance2 = serviceProvider.resolve<_MySingleton>();

    expect(instance1, same(instance2));
  });

  test('Transient Service Lifetime', () {
    var instance1 = serviceProvider.resolve<_MyTransient>();
    var instance2 = serviceProvider.resolve<_MyTransient>();

    expect(instance1, isNot(same(instance2)));
  });

  test('hasService', () {
    expect(serviceProvider.has<_MySingleton>(), isTrue);
    expect(serviceProvider.has<String>(), isFalse);
  });

  test('service registration', () {
    if (serviceProvider is! ServiceRegistry) {
      fail('Service provider is not a ServiceRegistry');
    }
    expect(serviceProvider.has<_SelfRegisteredService>(), isFalse);
    (serviceProvider as ServiceRegistry).register(
      (provider) => _MySelfRegisteredService(provider.resolve()),
      const Service(exposeAs: _SelfRegisteredService),
    );
    expect(serviceProvider.has<_SelfRegisteredService>(), isTrue);
  });

  test('enhance', () {
    expect(serviceProvider.has<_SelfRegisteredService>(), isFalse);

    var newProvider = serviceProvider.enhance(services: [
      LazyServiceDescriptor(
        (p) => _MySelfRegisteredService(),
        const Service(exposeAs: _SelfRegisteredService),
      )
    ]);

    expect(newProvider.has<_SelfRegisteredService>(), isTrue);
    expect(serviceProvider.has<_SelfRegisteredService>(), isFalse);

    var mySvc = newProvider.resolve<_SelfRegisteredService>();
    expect(mySvc.foo, equals('bar'));
  });
  test('enhance with parameter', () {
    serviceProvider.parameters['foo'] = 'bar';
    serviceProvider.parameters['bar'] = 'baz';
    expect(serviceProvider.has<_SelfRegisteredService>(), isFalse);

    var newProvider = serviceProvider.enhance(
      parameters: {
        'foo': 'overwritten',
      },
      services: [
        LazyServiceDescriptor(
          (p) => _MySelfRegisteredService(p.parameters['foo'] as String),
          const Service(exposeAs: _SelfRegisteredService),
        ),
      ],
    );

    var mySvc = newProvider.resolve<_SelfRegisteredService>();
    expect(mySvc.foo, equals('overwritten'));
    expect(newProvider.parameters.containsKey('bar'), isTrue);
  });
  test('enhance with multiple descriptors', () {
    expect(serviceProvider.has<_SelfRegisteredService>(), isFalse);
    expect(serviceProvider.has<String>(), isFalse);

    var newProvider = serviceProvider.enhance(
      services: [
        LazyServiceDescriptor<_MySelfRegisteredService>(
          (p) => _MySelfRegisteredService(p.resolve()),
          const Service(exposeAs: _SelfRegisteredService),
        ),
        LazyServiceDescriptor<String>(
          (p) => 'This should also work',
          const Service(exposeAs: String),
        ),
      ],
    );

    expect(newProvider.has<dynamic>(), isFalse);
    expect(newProvider.has<_SelfRegisteredService>(), isTrue);
    expect(newProvider.has<String>(), isTrue);
    expect(newProvider.resolve<_SelfRegisteredService>(), isNotNull);
    expect(newProvider.resolve<String>(), 'This should also work');
  });

  test('enhance should contain previous manual registered services', () {
    expect(serviceProvider.has<_SelfRegisteredService>(), isFalse);
    expect(serviceProvider.has<String>(), isFalse);

    var newProvider = serviceProvider.enhance(
      services: [
        LazyServiceDescriptor<_MySelfRegisteredService>(
          (p) => _MySelfRegisteredService(p.resolve()),
          const Service(exposeAs: _SelfRegisteredService),
        ),
      ],
    );

    expect(newProvider.has<_SelfRegisteredService>(), isTrue);
    expect(newProvider.has<String>(), isFalse);

    var newProvider2 = newProvider.enhance(
      services: [
        LazyServiceDescriptor<String>(
          (p) => 'This should also work',
          const Service(exposeAs: String),
        ),
      ],
    );

    expect(newProvider2.has<_SelfRegisteredService>(), isTrue);
    expect(newProvider2.has<String>(), isTrue);
  });

  test('resolveByTag', () {
    var services = serviceProvider.resolveByTag(#tagToInject);
    expect(services, isNotEmpty);
  });

  test('inject tagged services', () {
    var service = serviceProvider.resolve<_ServiceWithTaggedDependencies>();
    expect(service.dependencies.length, equals(2));
  });

  test('enhance should not override default descriptors', () {
    expect(serviceProvider.has<_ServiceThatDependOnEnhancedService>(), isTrue);
    expect(
      () => serviceProvider.resolve<_ServiceThatDependOnEnhancedService>(),
      throwsA(const TypeMatcher<DependencyNotFoundException>()),
    );

    var enhanced = serviceProvider.enhance(
      services: [
        LazyServiceDescriptor<_ServiceOnlyProvidedInEnhanced>(
          (p) => _ServiceOnlyProvidedInEnhanced(),
          const Service(exposeAs: _ServiceOnlyProvidedInEnhanced),
        )
      ],
    );

    expect(enhanced.has<_ServiceThatDependOnEnhancedService>(), isTrue);
    expect(
        enhanced.resolve<_ServiceThatDependOnEnhancedService>().dependency.foo,
        equals('bar'));
  });

  test('enhance should register singletons in the root provider', () {
    var enhanced1 = serviceProvider.enhance();
    expect(enhanced1.resolve<_SingletonThatShouldBeRegisteredInRoot>().count,
        equals(1));

    var enhanced2 = serviceProvider.enhance();
    expect(enhanced2.resolve<_SingletonThatShouldBeRegisteredInRoot>().count,
        equals(1));
  });
}

// Testing services

abstract interface class _MarkerInterface {
  String get parameter;
}

class _ServiceThatRequiresParameter implements _MarkerInterface {
  @override
  final String parameter;

  _ServiceThatRequiresParameter(
      @Inject(parameter: 'paramOverride') this.parameter);
}

class _MySingleton {}

class _MyTransient {}

class _SingletonThatShouldBeRegisteredInRoot {
  static var _count = 0;

  int get count => _count;

  _SingletonThatShouldBeRegisteredInRoot() {
    _count++;
  }
}

class _ServiceOnlyProvidedInEnhanced {
  String get foo => 'bar';
}

class _ServiceThatDependOnEnhancedService {
  final _ServiceOnlyProvidedInEnhanced dependency;

  _ServiceThatDependOnEnhancedService(this.dependency);
}

abstract class _SelfRegisteredService {
  String get foo;

  void sayHello();
}

class _MySelfRegisteredService implements _SelfRegisteredService {
  @override
  final String foo;

  _MySelfRegisteredService([this.foo = 'bar']);

  @override
  void sayHello() {}
}

class _ServiceWithTaggedDependencies {
  final List<Object> dependencies;

  _ServiceWithTaggedDependencies(
      @Inject(tag: #tagToInject) List<Object> this.dependencies);
}

class _PreloadService {
  static bool shouldPreload = false;
  static bool wasPreloaded = false;

  _PreloadService() {
    if (shouldPreload) {
      wasPreloaded = true;
    }
  }
}

class _TestPlugin implements ServiceProviderPlugin {
  @override
  Map<Type, Type> provideExposes() {
    return {};
  }

  @override
  Map<Type, ServiceDescriptor> provideKnownServices(ServiceProvider p) {
    return {
      _ServiceThatRequiresParameter:
          ServiceDescriptor<_ServiceThatRequiresParameter>(
        Service(),
        () => _ServiceThatRequiresParameter(p.resolveOrGetParameter(
            _ServiceThatRequiresParameter, 'parameter', 'paramOverride')),
      ),
      _MarkerInterface: ServiceDescriptor<_ServiceThatRequiresParameter>(
        Service(exposeAs: _MarkerInterface),
        () => _ServiceThatRequiresParameter(p.resolveOrGetParameter(
            _ServiceThatRequiresParameter, 'parameter', 'paramOverride')),
      ),
      _MySingleton: ServiceDescriptor<_MySingleton>(
        Service(lifetime: ServiceLifetime.singleton),
        () => _MySingleton(),
      ),
      _MyTransient: ServiceDescriptor<_MyTransient>(
        Service(lifetime: ServiceLifetime.transient),
        () => _MyTransient(),
      ),
      _ServiceWithTaggedDependencies:
          ServiceDescriptor<_ServiceWithTaggedDependencies>(
              Service(lifetime: ServiceLifetime.singleton),
              () => _ServiceWithTaggedDependencies(
                  p.resolveByTag(#tagToInject).cast())),
      _SingletonThatShouldBeRegisteredInRoot:
          ServiceDescriptor<_SingletonThatShouldBeRegisteredInRoot>(
        Service(lifetime: ServiceLifetime.singleton),
        () => _SingletonThatShouldBeRegisteredInRoot(),
      ),
      _ServiceThatDependOnEnhancedService:
          ServiceDescriptor<_ServiceThatDependOnEnhancedService>(
        Service(lifetime: ServiceLifetime.singleton),
        () => _ServiceThatDependOnEnhancedService(p.resolveOrGetParameter(
            _ServiceThatDependOnEnhancedService, 'dependency')),
      ),
      _PreloadService: ServiceDescriptor<_PreloadService>(
        Service(),
        () => _PreloadService(),
      )
    };
  }

  @override
  List<Type> providePreloadedTypes() {
    return [_PreloadService];
  }

  @override
  Map<Symbol, List<Type>> provideServiceTags() {
    return {
      #tagToInject: [_MySingleton, _MyTransient],
    };
  }
}

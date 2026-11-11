import 'package:catalyst_builder/catalyst_builder.dart';
import 'package:catalyst_builder_contracts/catalyst_builder_contracts.dart';
import 'package:test/test.dart';

void main() {
  late AbstractServiceContainer container;

  resetContainer() {
    container = ServiceContainer();
    container.applyPlugin(_TestPlugin());
    container.parameters['paramOverride'] = 'XYZ';
  }

  setUp(() {
    resetContainer();
    container.boot();
  });

  test('try/Resolve should throw when the container is not booted', () {
    resetContainer();
    expect(
      () => container.resolve<String>(),
      throwsA(const TypeMatcher<ContainerNotBootedException>()),
    );
  });

  test('double boot should throw an exception', () {
    expect(
      () => container.boot(),
      throwsA(const TypeMatcher<ContainerAlreadyBootedException>()),
    );
  });

  test('tryResolve should not throw if a service was not found', () {
    var result = container.tryResolve<String>();
    expect(result, isNull);
  });

  test('resolve should throw if a service was not found', () {
    expect(
      () => container.resolve<String>(),
      throwsA(const TypeMatcher<ServiceNotFoundException>()),
    );
  });

  test('try/Resolve should inject parameters for non existing services', () {
    expect(container.resolve<_ServiceThatRequiresParameter>().parameter, 'XYZ');
    expect(container.tryResolve<_ServiceThatRequiresParameter>()?.parameter,
        'XYZ');
  });

  test('Services can be exposed as a specific type', () {
    var resolved = container.resolve<_MarkerInterface>();
    expect(resolved, const TypeMatcher<_ServiceThatRequiresParameter>());
  });

  test('PreLoaded services should be loaded on boot', () {
    expect(_PreloadService.shouldPreload, isFalse);
    expect(_PreloadService.wasPreloaded, isFalse);
    resetContainer();
    _PreloadService.shouldPreload = true;
    expect(_PreloadService.wasPreloaded, isFalse);
    container.boot();
    expect(_PreloadService.wasPreloaded, isTrue);
  });

  test('Singleton Service Lifetime', () {
    var instance1 = container.resolve<_MySingleton>();
    var instance2 = container.resolve<_MySingleton>();

    expect(instance1, same(instance2));
  });

  test('Transient Service Lifetime', () {
    var instance1 = container.resolve<_MyTransient>();
    var instance2 = container.resolve<_MyTransient>();

    expect(instance1, isNot(same(instance2)));
  });

  test('hasService', () {
    expect(container.has<_MySingleton>(), isTrue);
    expect(container.has<String>(), isFalse);
  });

  test('service registration', () {
    if (container is! ServiceRegistry) {
      fail('Container is not a ServiceRegistry');
    }
    expect(container.has<_SelfRegisteredService>(), isFalse);
    (container as ServiceRegistry).register(
      (c) => _MySelfRegisteredService(c.resolve()),
      const Service(exposeAs: _SelfRegisteredService),
    );
    expect(container.has<_SelfRegisteredService>(), isTrue);
  });

  test('enhance', () {
    expect(container.has<_SelfRegisteredService>(), isFalse);

    var newContainer = container.enhance(services: [
      LazyServiceDescriptor(
        (p) => _MySelfRegisteredService(),
        const Service(exposeAs: _SelfRegisteredService),
      )
    ]);

    expect(newContainer.has<_SelfRegisteredService>(), isTrue);
    expect(container.has<_SelfRegisteredService>(), isFalse);

    var mySvc = newContainer.resolve<_SelfRegisteredService>();
    expect(mySvc.foo, equals('bar'));
  });
  test('enhance with parameter', () {
    container.parameters['foo'] = 'bar';
    container.parameters['bar'] = 'baz';
    expect(container.has<_SelfRegisteredService>(), isFalse);

    var newContainer = container.enhance(
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

    var mySvc = newContainer.resolve<_SelfRegisteredService>();
    expect(mySvc.foo, equals('overwritten'));
    expect(newContainer.parameters.containsKey('bar'), isTrue);
  });
  test('enhance with multiple descriptors', () {
    expect(container.has<_SelfRegisteredService>(), isFalse);
    expect(container.has<String>(), isFalse);

    var newContainer = container.enhance(
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

    expect(newContainer.has<dynamic>(), isFalse);
    expect(newContainer.has<_SelfRegisteredService>(), isTrue);
    expect(newContainer.has<String>(), isTrue);
    expect(newContainer.resolve<_SelfRegisteredService>(), isNotNull);
    expect(newContainer.resolve<String>(), 'This should also work');
  });

  test('enhance should contain previous manual registered services', () {
    expect(container.has<_SelfRegisteredService>(), isFalse);
    expect(container.has<String>(), isFalse);

    var newContainer = container.enhance(
      services: [
        LazyServiceDescriptor<_MySelfRegisteredService>(
          (p) => _MySelfRegisteredService(p.resolve()),
          const Service(exposeAs: _SelfRegisteredService),
        ),
      ],
    );

    expect(newContainer.has<_SelfRegisteredService>(), isTrue);
    expect(newContainer.has<String>(), isFalse);

    var newContainer2 = newContainer.enhance(
      services: [
        LazyServiceDescriptor<String>(
          (p) => 'This should also work',
          const Service(exposeAs: String),
        ),
      ],
    );

    expect(newContainer2.has<_SelfRegisteredService>(), isTrue);
    expect(newContainer2.has<String>(), isTrue);
  });

  test('resolveByTag', () {
    var services = container.resolveByTag(#tagToInject);
    expect(services, isNotEmpty);
  });

  test('inject tagged services', () {
    var service = container.resolve<_ServiceWithTaggedDependencies>();
    expect(service.dependencies.length, equals(2));
  });

  test('enhance should not override default descriptors', () {
    expect(container.has<_ServiceThatDependOnEnhancedService>(), isTrue);
    expect(
      () => container.resolve<_ServiceThatDependOnEnhancedService>(),
      throwsA(const TypeMatcher<DependencyNotFoundException>()),
    );

    var enhanced = container.enhance(
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

  test('enhance should register singletons in the root container', () {
    var enhanced1 = container.enhance();
    expect(enhanced1.resolve<_SingletonThatShouldBeRegisteredInRoot>().count,
        equals(1));

    var enhanced2 = container.enhance();
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

  _ServiceWithTaggedDependencies(@Inject(tag: #tagToInject) this.dependencies);
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

class _TestPlugin implements ServiceContainerPlugin {
  @override
  Map<Type, Type> provideExposes() {
    return {};
  }

  @override
  Map<Type, ServiceDescriptor> provideKnownServices(
      AbstractServiceContainer p) {
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

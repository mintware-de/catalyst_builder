import 'package:catalyst_builder_runtime/catalyst_builder_runtime.dart';
import 'package:test/test.dart';

void main() {
  late ServiceContainer root;

  setUp(() {
    root = ServiceContainer();
    root.register<_ScopedService>(
      (_) => _ScopedService(),
      const Service(lifetime: ServiceLifetime.scoped),
    );
    root.register<_SingletonService>(
      (_) => _SingletonService(),
      const Service(),
    );
    root.register<_TransientService>(
      (_) => _TransientService(),
      const Service(lifetime: ServiceLifetime.transient),
    );
    root.boot();
  });

  test('scoped services are the same inside one scope', () {
    var scope = root.createScope();
    expect(
        scope.resolve<_ScopedService>(), same(scope.resolve<_ScopedService>()));
  });

  test('scoped services differ between two scopes', () {
    var scope1 = root.createScope();
    var scope2 = root.createScope();
    expect(
      scope1.resolve<_ScopedService>(),
      isNot(same(scope2.resolve<_ScopedService>())),
    );
  });

  test('scoped services resolved from the root throw ScopeRequiredException',
      () {
    expect(
      () => root.resolve<_ScopedService>(),
      throwsA(const TypeMatcher<ScopeRequiredException>()),
    );
    expect(
      () => root.tryResolve<_ScopedService>(),
      throwsA(const TypeMatcher<ScopeRequiredException>()),
    );
  });

  test(
      'a root singleton that needs a scoped service throws '
      'ScopeRequiredException', () {
    var c = ServiceContainer()
      ..register<_ScopedService>(
        (_) => _ScopedService(),
        const Service(lifetime: ServiceLifetime.scoped),
      )
      ..register<_RootNeedsScoped>(
        (c) => _RootNeedsScoped(c.resolve<_ScopedService>()),
      );
    c.boot();

    expect(
      () => c.resolve<_RootNeedsScoped>(),
      throwsA(const TypeMatcher<ScopeRequiredException>()),
    );
    // The captive dependency stays a configuration error inside a scope:
    // the singleton is built by the root.
    expect(
      () => c.createScope().resolve<_RootNeedsScoped>(),
      throwsA(const TypeMatcher<ScopeRequiredException>()),
    );
  });

  test(
      'a singleton resolved from a scope is the root instance built with '
      'root parameters', () {
    var c = ServiceContainer()
      ..register<_ParamReader>(
        (c) => _ParamReader(c.tryResolveOrGetParameter<String>('p')),
      );
    c.parameters['p'] = 'root';
    c.boot();

    var scope = c.createScope(parameters: {'p': 'scope'});
    var fromScope = scope.resolve<_ParamReader>();
    expect(fromScope.value, 'root');
    expect(c.resolve<_ParamReader>(), same(fromScope));
  });

  test('scope service overrides are only visible inside the scope', () {
    var c = ServiceContainer()..register<_Cfg>((_) => _Cfg('root'));
    c.boot();

    var scope = c.createScope(services: [
      LazyServiceDescriptor<_Cfg>((_) => _Cfg('scope')),
    ]);

    expect(scope.resolve<_Cfg>().value, 'scope');
    expect(c.resolve<_Cfg>().value, 'root');
  });

  test('scope parameters are overridden in the scope only', () {
    root.parameters['x'] = 'root-value';
    var scope = root.createScope(parameters: {'x': 'scope-value'});
    expect(scope.parameters['x'], 'scope-value');
    expect(root.parameters['x'], 'root-value');
  });

  test('transient services are created per resolve inside a scope', () {
    var scope = root.createScope();
    expect(
      scope.resolve<_TransientService>(),
      isNot(same(scope.resolve<_TransientService>())),
    );
  });

  test(
      'nested scopes keep one instance per innermost scope and fall '
      'through to the root', () {
    var scope1 = root.createScope();
    var scope2 = scope1.createScope();

    expect(scope2.resolve<_ScopedService>(),
        same(scope2.resolve<_ScopedService>()));
    expect(
      scope1.resolve<_ScopedService>(),
      isNot(same(scope2.resolve<_ScopedService>())),
    );
    // Lookup falls through to the root for services that neither scope
    // registers itself.
    expect(scope2.resolve<_SingletonService>(),
        same(root.resolve<_SingletonService>()));
  });

  test(
      'dispose disposes scoped and transient instances of the scope in '
      'reverse creation order, but not root singletons', () async {
    var events = <String>[];
    var c = ServiceContainer()
      ..register<_Tracked>(
        (_) => _Tracked(events),
        const Service(lifetime: ServiceLifetime.scoped),
      )
      ..register<_TransientTracked>(
        (_) => _TransientTracked(events),
        const Service(lifetime: ServiceLifetime.transient),
      )
      ..register<_SingletonDisposable>(
        (c) => _SingletonDisposable(events),
      );
    c.boot();

    var scope = c.createScope();
    var tracked1 = scope.resolve<_Tracked>();
    var tracked2 = scope.resolve<_Tracked>();
    expect(tracked2, same(tracked1)); // scoped: one instance per scope
    scope.resolve<_TransientTracked>();
    var singleton = c.resolve<_SingletonDisposable>();
    expect(events, isEmpty); // construction does not dispose

    await scope.dispose();
    expect(
      events,
      ['dispose:transient', 'dispose:tracked'],
      reason: 'reverse creation order, root singleton stays alive',
    );

    await c.dispose();
    expect(events, contains('dispose:singleton'));
    expect(singleton, isNotNull);
  });

  test('dispose is idempotent', () async {
    var scope = root.createScope();
    scope.resolve<_ScopedService>();
    await scope.dispose();
    await scope.dispose();
    expect(scope.isDisposed, isTrue);
  });

  test('using a disposed scope throws ScopeDisposedException', () async {
    var scope = root.createScope();
    await scope.dispose();
    expect(
      () => scope.resolve<_SingletonService>(),
      throwsA(const TypeMatcher<ScopeDisposedException>()),
    );
    expect(
      () => scope.resolveByTag(#anything),
      throwsA(const TypeMatcher<ScopeDisposedException>()),
    );
    expect(
      () => scope.createScope(),
      throwsA(const TypeMatcher<ScopeDisposedException>()),
    );
  });

  test(
      'a throwing dispose does not stop the others and the first error '
      'is rethrown', () async {
    var events = <String>[];
    var c = ServiceContainer()
      ..register<_Throwing>((_) => _Throwing(events),
          const Service(lifetime: ServiceLifetime.scoped))
      ..register<_Tracked>((_) => _Tracked(events),
          const Service(lifetime: ServiceLifetime.scoped));
    c.boot();

    var scope = c.createScope();
    scope.resolve<_Throwing>();
    scope.resolve<_Tracked>();

    await expectLater(scope.dispose(), throwsStateError);
    // Both were disposed despite the first one throwing (reverse order:
    // _Tracked was created last and is disposed first).
    expect(events, ['dispose:tracked', 'dispose:throwing']);
  });

  test('a cycle A -> B -> A throws CircularDependencyException', () {
    var c = ServiceContainer()
      ..register<_A>((c) => _A(c.resolve<_B>()))
      ..register<_B>((c) => _B(c.resolve<_A>()));
    c.boot();
    expect(
      () => c.resolve<_A>(),
      throwsA(
        isA<CircularDependencyException>()
            .having((e) => e.path, 'path', [_A, _B, _A]),
      ),
    );
  });

  test('a self cycle A -> A throws CircularDependencyException', () {
    var c = ServiceContainer()
      ..register<_SelfCycle>((c) => _SelfCycle(c.resolve<_SelfCycle>()));
    c.boot();
    expect(
      () => c.resolve<_SelfCycle>(),
      throwsA(const TypeMatcher<CircularDependencyException>()),
    );
  });

  test('createScope before boot throws ContainerNotBootedException', () {
    var c = ServiceContainer();
    expect(
      () => c.createScope(),
      throwsA(const TypeMatcher<ContainerNotBootedException>()),
    );
  });

  test('resolveByTag inside a scope returns root and scope registrations', () {
    var scope = root.createScope(services: [
      LazyServiceDescriptor<_ScopedTagged>(
        (_) => _ScopedTagged(),
        const Service(tags: [#tagged], lifetime: ServiceLifetime.scoped),
      ),
    ]);
    root.register<_RootTagged>(
      (_) => _RootTagged(),
      const Service(tags: [#tagged]),
    );

    var services = scope.resolveByTag(#tagged);
    expect(services, hasLength(2));
    expect(services.first, isA<_ScopedTagged>());
    expect(services.last, isA<_RootTagged>());
  });
}

class _ScopedService {}

class _SingletonService {}

class _TransientService {}

class _RootNeedsScoped {
  final _ScopedService scoped;

  _RootNeedsScoped(this.scoped);
}

class _ParamReader {
  final String? value;

  _ParamReader(this.value);
}

class _Cfg {
  final String value;

  _Cfg(this.value);
}

class _Tracked implements Disposable {
  final List<String> events;

  _Tracked(this.events);

  @override
  void dispose() => events.add('dispose:tracked');
}

class _TransientTracked implements Disposable {
  final List<String> events;

  _TransientTracked(this.events);

  @override
  void dispose() => events.add('dispose:transient');
}

class _Throwing implements Disposable {
  final List<String> events;

  _Throwing(this.events);

  @override
  void dispose() {
    events.add('dispose:throwing');
    throw StateError('dispose failed');
  }
}

class _SingletonDisposable implements Disposable {
  final List<String> events;

  _SingletonDisposable(this.events);

  @override
  void dispose() => events.add('dispose:singleton');
}

class _A {
  final _B b;

  _A(this.b);
}

class _B {
  final _A a;

  _B(this.a);
}

class _SelfCycle {
  final _SelfCycle self;

  _SelfCycle(this.self);
}

class _ScopedTagged {}

class _RootTagged {}

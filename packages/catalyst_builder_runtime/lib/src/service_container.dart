import 'package:catalyst_builder_runtime/catalyst_builder_runtime.dart';

/// This is a service container. Use it to register and resolve services
/// from your app.
///
/// Containers can be organized as a chain: [createScope] creates a child
/// container that shares the registrations of its parent but keeps its own
/// additional services and parameters. A child never copies descriptor maps
/// from its parent; lookups walk up the chain, starting at the child.
class ServiceContainer
    implements AbstractServiceContainer, ServiceRegistry, ServiceScope {
  /// Creates a new root service container.
  ServiceContainer() : _parent = null;

  ServiceContainer._child(this._parent);

  final ServiceContainer? _parent;

  ServiceContainer get _root => _parent?._root ?? this;

  @override
  final parameters = <String, dynamic>{};

  /// The services registered in this container.
  final _descriptors = <Type, ServiceDescriptor>{};

  final _exposeMap = <Type, Type>{};

  final _servicesByTag = <Symbol, List<Type>>{};

  /// The cached instances owned by this container (singletons and, in a
  /// scope, the scoped services created inside it).
  final _instances = <Type, dynamic>{};

  /// The [Disposable] instances created by this container, in creation
  /// order.
  final _disposables = <Disposable>[];

  /// The types that are instantiated on [boot]. Only relevant in the root.
  final _preloadedTypes = <Type>[];

  /// The types that are currently being instantiated. Lives at the root so
  /// it is shared across the whole chain; resolution is synchronous.
  final _resolving = <Type>[];

  var _booted = false;
  var _disposed = false;

  @override
  AbstractServiceContainer get parent => _parent ?? this;

  @override
  bool get isDisposed => _disposed;

  @override
  T? tryResolve<T>([Type? t]) {
    return _tryResolveInternal<T>(t ?? T);
  }

  T? _tryResolveInternal<T>(Type t) {
    _ensureBoot();
    var hit = _lookup(t);
    if (hit == null) {
      return null;
    }
    switch (hit.descriptor.service.lifetime) {
      case ServiceLifetime.singleton:
        // Singletons are always built and cached by the container that
        // registered them, so they can never capture a child container.
        return hit.owner._getOrCreate(hit.key, hit.descriptor, hit.owner) as T?;
      case ServiceLifetime.scoped:
        if (_parent == null) {
          throw ScopeRequiredException(t);
        }
        // A scoped instance lives in the innermost resolving scope.
        return _getOrCreate(hit.key, hit.descriptor, this) as T?;
      case ServiceLifetime.transient:
        return _create(hit.key, hit.descriptor, this, trackIn: this) as T?;
    }
  }

  /// Returns the cached instance for [key] or creates it with [descriptor]
  /// using [builder] as the resolving container. The instance is cached in
  /// this container.
  dynamic _getOrCreate(
    Type key,
    ServiceDescriptor descriptor,
    ServiceContainer builder,
  ) {
    if (_instances.containsKey(key)) {
      return _instances[key];
    }
    var instance = _create(key, descriptor, builder, trackIn: this);
    _instances[key] = instance;
    return instance;
  }

  /// Creates a new instance using [descriptor].
  ///
  /// [builder] is passed to the factory as the resolving container.
  /// The instance is registered for disposal in [trackIn] when it
  /// implements [Disposable]. Throws a [CircularDependencyException] when
  /// the type [key] is already being resolved further up the call stack.
  dynamic _create(
    Type key,
    ServiceDescriptor descriptor,
    ServiceContainer builder, {
    required ServiceContainer trackIn,
  }) {
    var root = _root;
    var cycleIndex = root._resolving.indexOf(key);
    if (cycleIndex != -1) {
      throw CircularDependencyException([
        ...root._resolving.sublist(cycleIndex),
        key,
      ]);
    }
    root._resolving.add(key);
    try {
      var instance = descriptor.produce(builder);
      if (instance is Disposable) {
        trackIn._disposables.add(instance);
      }
      return instance;
    } finally {
      root._resolving.removeLast();
    }
  }

  @override
  T resolve<T>([Type? t]) {
    _ensureBoot();
    var resolved = tryResolve<T>(t);
    if (resolved != null) {
      return resolved;
    }
    throw ServiceNotFoundException(t ?? T);
  }

  @override
  List<dynamic> resolveByTag(Symbol tag) {
    _ensureBoot();
    var services = <dynamic>[];
    var seen = <Type>{};
    // Collect types from the whole chain, the child first, then the
    // parent. Each type is resolved using this container.
    for (ServiceContainer? current = this;
        current != null;
        current = current._parent) {
      for (var type in current._servicesByTag[tag] ?? const <Type>[]) {
        if (seen.add(type)) {
          services.add(_tryResolveInternal<dynamic>(type));
        }
      }
    }
    return services;
  }

  @override
  T? tryResolveOrGetParameter<T>(String parameter) {
    var resolvedService = tryResolve<T>();
    if (resolvedService != null) {
      return resolvedService;
    }
    if (parameters[parameter] is T) {
      return (parameters[parameter] as T);
    }
    return null;
  }

  @override
  T resolveOrGetParameter<T>(
    Type requiredBy,
    String param, [
    String? parameter,
  ]) {
    var resolved = tryResolveOrGetParameter<T>(parameter ?? param);
    if (resolved == null) {
      throw DependencyNotFoundException(
        requiredBy,
        param,
        ServiceNotFoundException(T),
      );
    }
    return resolved;
  }

  @override
  void boot() {
    _ensureNotDisposed();
    if (_root._booted) {
      throw const ContainerAlreadyBootedException();
    }
    _root._booted = true;
    for (var type in _root._preloadedTypes) {
      _root._tryResolveInternal<dynamic>(type);
    }
  }

  void _ensureBoot() {
    _ensureNotDisposed();
    if (!_root._booted) {
      throw const ContainerNotBootedException();
    }
  }

  void _ensureNotDisposed() {
    if (_disposed) {
      throw const ScopeDisposedException();
    }
  }

  @override
  bool has<T>([Type? type]) {
    _ensureNotDisposed();
    return _lookup(type ?? T) != null;
  }

  @override
  void register<T>(
    ServiceFactory<T> factory, [
    Service service = const Service(),
  ]) {
    _ensureNotDisposed();
    _registerInternal(T, factory, service);
  }

  void _registerInternal<T>(
    Type tReal,
    ServiceFactory<T> factory, [
    Service service = const Service(),
  ]) {
    _descriptors[tReal] = ServiceDescriptor(service, factory);
    if (service.exposeAs != null) {
      _exposeMap[service.exposeAs!] = tReal;
    }
    if (service.tags.isNotEmpty) {
      for (final tag in service.tags) {
        _registerServiceForTag(tag, tReal);
      }
    }
  }

  @override
  ServiceScope createScope({
    List<LazyServiceDescriptor> services = const <LazyServiceDescriptor>[],
    Map<String, dynamic> parameters = const <String, dynamic>{},
  }) {
    _ensureBoot();
    var scope = ServiceContainer._child(this);
    for (var service in services) {
      scope._registerInternal(
        service.returnType,
        service.factory,
        service.service,
      );
    }
    // Parameters are copied when the scope is created.
    scope.parameters.addAll(this.parameters);
    scope.parameters.addAll(parameters);
    return scope;
  }

  @override
  Future<void> dispose() async {
    if (_disposed) {
      return;
    }
    _disposed = true;
    Object? firstError;
    StackTrace? firstStackTrace;
    for (var disposable in _disposables.reversed) {
      try {
        await disposable.dispose();
      } catch (error, stackTrace) {
        firstError ??= error;
        firstStackTrace ??= stackTrace;
      }
    }
    _disposables.clear();
    _instances.clear();
    if (firstError != null) {
      Error.throwWithStackTrace(firstError, firstStackTrace!);
    }
  }

  @override
  void applyPlugin(ServiceContainerPlugin plugin) {
    _ensureNotDisposed();
    if (_root._booted) {
      throw const ContainerAlreadyBootedException();
    }
    _descriptors.addAll(plugin.provideKnownServices());
    _exposeMap.addAll(plugin.provideExposes());
    _preloadedTypes.addAll(plugin.providePreloadedTypes());
    for (var entry in plugin.provideServiceTags().entries) {
      for (var type in entry.value) {
        _registerServiceForTag(entry.key, type);
      }
    }
  }

  void _registerServiceForTag(Symbol tag, Type type) {
    if (!_servicesByTag.containsKey(tag)) {
      _servicesByTag[tag] = <Type>[];
    }
    if (!_servicesByTag[tag]!.contains(type)) {
      _servicesByTag[tag]!.add(type);
    }
  }

  /// Walks up the chain and returns the first registration for the type [t].
  ///
  /// The search starts at this container, so a descriptor of a child wins
  /// over a descriptor of its parent.
  _ServiceHit? _lookup(Type t) {
    for (ServiceContainer? current = this;
        current != null;
        current = current._parent) {
      var key = current._exposeMap[t] ?? t;
      var descriptor = current._descriptors[key];
      if (descriptor != null) {
        return _ServiceHit(current, key, descriptor);
      }
    }
    return null;
  }
}

/// The result of a successful lookup inside the container chain.
class _ServiceHit {
  /// The container that owns the registration.
  final ServiceContainer owner;

  /// The type the descriptor is registered and cached under.
  final Type key;

  /// The found descriptor.
  final ServiceDescriptor descriptor;

  const _ServiceHit(this.owner, this.key, this.descriptor);
}

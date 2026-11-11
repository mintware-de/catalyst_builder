import 'package:catalyst_builder_runtime/catalyst_builder_runtime.dart';

/// This is a service container. Use it to register and resolve services
/// from your app.
///
/// Containers can be organized as a chain: [enhance] creates a child
/// container that shares the registrations of its parent but keeps its own
/// additional services and parameters. A child never copies descriptor maps
/// from its parent; lookups walk up the chain, starting at the child.
class ServiceContainer implements AbstractServiceContainer, ServiceRegistry {
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

  /// The singleton instances that are owned by this container.
  final _instances = <Type, dynamic>{};

  /// The types that are instantiated on [boot]. Only relevant in the root.
  final _preloadedTypes = <Type>[];

  var _booted = false;

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
    if (hit.descriptor.service.lifetime == ServiceLifetime.singleton) {
      var owner = hit.owner;
      if (owner._instances.containsKey(hit.key)) {
        return owner._instances[hit.key] as T?;
      }
      // Singletons are always built in the context of the container that
      // registered them, so they can never capture a child container.
      var instance = hit.descriptor.produce(owner);
      owner._instances[hit.key] = instance;
      return instance as T?;
    }
    return hit.descriptor.produce(this) as T?;
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
    if (_root._booted) {
      throw const ContainerAlreadyBootedException();
    }
    _root._booted = true;
    for (var type in _root._preloadedTypes) {
      _root._tryResolveInternal<dynamic>(type);
    }
  }

  void _ensureBoot() {
    if (!_root._booted) {
      throw const ContainerNotBootedException();
    }
  }

  @override
  bool has<T>([Type? type]) {
    return _lookup(type ?? T) != null;
  }

  @override
  void register<T>(
    ServiceFactory<T> factory, [
    Service service = const Service(),
  ]) {
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
  AbstractServiceContainer enhance({
    List<LazyServiceDescriptor> services = const <LazyServiceDescriptor>[],
    Map<String, dynamic> parameters = const <String, dynamic>{},
  }) {
    _ensureBoot();
    var child = ServiceContainer._child(this);
    for (var service in services) {
      child._registerInternal(
        service.returnType,
        service.factory,
        service.service,
      );
    }
    // Parameters are copied when the child is created.
    child.parameters.addAll(this.parameters);
    child.parameters.addAll(parameters);
    return child;
  }

  @override
  void applyPlugin(ServiceContainerPlugin plugin) {
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

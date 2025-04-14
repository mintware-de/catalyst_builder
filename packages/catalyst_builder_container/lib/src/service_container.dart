import 'package:catalyst_builder_contracts/catalyst_builder_contracts.dart';

/// This is a service container. Use it to register and resolve services
/// from your app.
class ServiceContainer implements ServiceProvider, ServiceRegistry {
  @override
  final parameters = <String, dynamic>{};

  final _knownServices = <Type, ServiceDescriptor>{};

  final _exposeMap = <Type, Type>{};

  final _servicesByTag = <Symbol, List<Type>>{};

  final _preloadedTypes = <Type>[];

  final _appliedPlugins = <ServiceProviderPlugin>[];

  var _serviceInstances = <Type, dynamic>{};

  var _booted = false;

  @override
  T? tryResolve<T>() {
    return _tryResolveInternal<T>(T);
  }

  T? _tryResolveInternal<T>(Type t) {
    _ensureBoot();
    var exposedType = _exposeMap[t];
    exposedType ??= t;
    if (_serviceInstances.containsKey(exposedType)) {
      return (_serviceInstances[exposedType] as T?);
    }
    var descriptor = _knownServices[exposedType];
    if (descriptor == null) {
      return null;
    }
    var instance = descriptor.produce();
    if (descriptor.service.lifetime == ServiceLifetime.singleton) {
      _serviceInstances[exposedType] = instance;
    }
    return (instance as T?);
  }

  @override
  T resolve<T>() {
    _ensureBoot();
    var resolved = tryResolve<T>();
    if (resolved != null) {
      return resolved;
    }
    throw ServiceNotFoundException(T);
  }

  @override
  List<dynamic> resolveByTag(Symbol tag) {
    var services = <dynamic>[];
    if (!_servicesByTag.containsKey(tag)) {
      return services;
    }
    for (var svc in _servicesByTag[tag]!) {
      services.add((_tryResolveInternal(svc) as dynamic));
    }
    return services;
  }

  @override
  T? tryResolveOrGetParameter<T>(String b) {
    var resolvedService = tryResolve<T>();
    if (resolvedService != null) {
      return resolvedService;
    }
    if (parameters[b] is T) {
      return (parameters[b] as T);
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
    if (_booted) {
      throw const ProviderAlreadyBootedException();
    }
    _booted = true;
    for (var type in _preloadedTypes) {
      _tryResolveInternal<dynamic>(type);
    }
  }

  void _ensureBoot() {
    if (_booted == false) {
      throw const ProviderNotBootedException();
    }
  }

  @override
  bool has<T>([Type? type]) {
    var lookupType = type ?? T;
    return _knownServices.containsKey(_exposeMap[lookupType] ?? lookupType);
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
    _knownServices[tReal] = ServiceDescriptor(service, () => factory(this));
    if (service.exposeAs != null) {
      _exposeMap[service.exposeAs!] = tReal;
    }
  }

  @override
  ServiceProvider enhance({
    List<LazyServiceDescriptor> services = const <LazyServiceDescriptor>[],
    Map<String, dynamic> parameters = const <String, dynamic>{},
  }) {
    _ensureBoot();
    var enhanced = ServiceContainer();
    _appliedPlugins.forEach(enhanced.applyPlugin);
    enhanced._serviceInstances = _serviceInstances;
    enhanced._knownServices.addAll(
      Map.fromEntries(
        _knownServices.entries.where(
          (el) => !enhanced._knownServices.containsKey(el.key),
        ),
      ),
    );
    enhanced._exposeMap.addAll(_exposeMap);
    for (var service in services) {
      enhanced._registerInternal(
        service.returnType,
        service.factory,
        service.service,
      );
    }
    enhanced.parameters.addAll(this.parameters);
    enhanced.parameters.addAll(parameters);
    enhanced._booted = true;
    return enhanced;
  }

  @override
  void applyPlugin(ServiceProviderPlugin plugin) {
    if (_booted) {
      throw const ProviderAlreadyBootedException();
    }
    _appliedPlugins.add(plugin);
    _knownServices.addAll(plugin.provideKnownServices(this));
    _exposeMap.addAll(plugin.provideExposes());
    _preloadedTypes.addAll(plugin.providePreloadedTypes());
    for (var entry in plugin.provideServiceTags().entries) {
      if (!_servicesByTag.containsKey(entry.key)) {
        _servicesByTag[entry.key] = <Type>[];
      }
      for (var type in entry.value) {
        if (!_servicesByTag[entry.key]!.contains(type)) {
          _servicesByTag[entry.key]!.add(type);
        }
      }
    }
  }
}

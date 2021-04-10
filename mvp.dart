import './lib/di_experimental.dart';

class DefaultServiceProvider implements ServiceProvider {
  final _knownServices = <Type, ServiceDescriptor>{
    Pizza: ServiceDescriptor(
      Service(lifetime: ServiceLifetime.transient),
      (p) => Pizza(
        p.resolve(),
      ),
    ),
    TunaTopping: ServiceDescriptor(
        Service(lifetime: ServiceLifetime.transient, exposeAs: Topping),
        (p) => TunaTopping()),
  };

  final _exposeMap = <Type, Type>{
    Topping: TunaTopping,
  };

  var _serviceInstances = <Type, dynamic>{};

  @override
  T resolve<T>() {
    var resolved = tryResolve<T>();
    if (resolved != null) {
      return resolved;
    }
    throw Exception('Service $T not found.');
  }

  @override
  T? tryResolve<T>() {
    var _exposedType = _exposeMap[T];
    _exposedType ??= T;

    if (_serviceInstances.containsKey(_exposedType)) {
      return _serviceInstances[_exposedType];
    }
    var descriptor = _knownServices[_exposedType];
    if (descriptor != null) {
      var instance = descriptor.produce(this);

      if (descriptor.service.lifetime == ServiceLifetime.singleton) {
        _serviceInstances[_exposedType] = instance;
      }
      return instance;
    }
    return null;
  }
}

void main() {
  // var container = ServiceProvider();
  // var myPizza = container.resolve<Pizza>();
  // print(myPizza.topping.name);
  // myPizza = container.resolve<Pizza>();
  // print(myPizza.topping.name);
}

class Pizza {
  final Topping topping;

  Pizza(this.topping);
}

abstract class Topping {
  String get name;
}

class TunaTopping extends Topping {
  final String name = 'Tuna';

  TunaTopping() {
    print('Fishing tuna :-)');
  }
}

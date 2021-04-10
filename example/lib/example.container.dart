import 'package:di_experimental/di_experimental.dart' as _i1;
import 'package:di_experimental_example/chat_provider.dart' as _i5;
import 'package:di_experimental_example/cool_chat_provider.dart' as _i3;
import 'package:di_experimental_example/singleton_service.dart' as _i4;
import 'package:di_experimental_example/transport.dart' as _i2;

class DefaultServiceProvider extends _i1.ServiceProvider {
  DefaultServiceProvider() {
    _knownServices.addAll(<Type, _i1.ServiceDescriptor>{
      _i2.ConsoleTransport:
          _i1.ServiceDescriptor(_i1.Service(exposeAs: _i2.Transport), (p) {
        return _i2.ConsoleTransport();
      }),
      _i3.CoolChatProvider:
          _i1.ServiceDescriptor(_i1.Service(exposeAs: _i5.ChatProvider), (p) {
        return _i3.CoolChatProvider(
            transport: bindings.containsKey('transport')
                ? (p.tryResolve() ?? bindings['transport'])
                : p.resolve(),
            username: bindings.containsKey('username')
                ? (p.tryResolve() ?? bindings['username'])
                : p.resolve());
      }),
      _i4.MySingletonService: _i1.ServiceDescriptor(_i1.Service(), (p) {
        return _i4.MySingletonService();
      })
    });
  }

  final _knownServices = <Type, _i1.ServiceDescriptor>{};

  final _exposeMap = <Type, Type>{
    _i2.Transport: _i2.ConsoleTransport,
    _i5.ChatProvider: _i3.CoolChatProvider
  };

  final _serviceInstances = <Type, dynamic>{};

  final bindings = <String, dynamic>{};

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

      if (descriptor.service.lifetime == _i1.ServiceLifetime.singleton) {
        _serviceInstances[_exposedType] = instance;
      }
      return instance;
    }
    return null;
  }

  @override
  T resolve<T>() {
    var resolved = tryResolve<T>();
    if (resolved != null) {
      return resolved;
    }

    throw Exception('Service $T not found.');
  }
}

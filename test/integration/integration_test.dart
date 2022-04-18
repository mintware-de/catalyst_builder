import 'package:catalyst_builder/catalyst_builder.dart';
import 'package:test/test.dart';

// ignore: avoid_relative_lib_imports
import '../../example/lib/example.dart';

// ignore: avoid_relative_lib_imports
import '../third_party_dependency/lib/third_party_dependency.dart';

void main() {
  late ServiceProvider serviceProvider;

  resetServiceProvider() {
    serviceProvider = ExampleProvider();
    serviceProvider.parameters['sender_username'] = 'XYZ';
  }

  setUp(() {
    resetServiceProvider();
    serviceProvider.boot();
  });

  test('try/Resolve should throw when the provider is not booted', () {
    resetServiceProvider();
    expect(
      () => serviceProvider.resolve<ChatProvider>(),
      throwsA(const TypeMatcher<ProviderNotBootedException>()),
    );
    expect(
      () => serviceProvider.tryResolve<ChatProvider>(),
      throwsA(const TypeMatcher<ProviderNotBootedException>()),
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
    expect(serviceProvider.resolve<ChatProvider>().username, 'XYZ');
    expect(serviceProvider.tryResolve<ChatProvider>()?.username, 'XYZ');
  });

  test('Services can be exposed as a specific type', () {
    var provider = serviceProvider.resolve<ChatProvider>();
    expect(provider, const TypeMatcher<CoolChatProvider>());
  });

  test('PreLoaded services should be loaded on boot', () {
    expect(PreloadService.shouldPreload, isFalse);
    expect(PreloadService.wasPreloaded, isFalse);
    resetServiceProvider();
    PreloadService.shouldPreload = true;
    expect(PreloadService.wasPreloaded, isFalse);
    serviceProvider.boot();
    expect(PreloadService.wasPreloaded, isTrue);
  });

  test('Singleton Service Lifetime', () {
    var instance1 = serviceProvider.resolve<MySingletonService>();
    var instance2 = serviceProvider.resolve<MySingletonService>();

    expect(instance1, same(instance2));
  });

  test('Transient Service Lifetime', () {
    var instance1 = serviceProvider.resolve<MyTransientService>();
    var instance2 = serviceProvider.resolve<MyTransientService>();

    expect(instance1, isNot(same(instance2)));
  });

  test('Third party services', () {
    var svc = serviceProvider.resolve<ThirdPartyService>();

    expect(svc, const TypeMatcher<ThirdPartyService>());
  });

  test('Manually wired services', () {
    expect(ManuallyWiredServiceImplementation.shouldPreload, isFalse);
    expect(ManuallyWiredServiceImplementation.wasPreloaded, isFalse);
    resetServiceProvider();
    ManuallyWiredServiceImplementation.shouldPreload = true;
    expect(ManuallyWiredServiceImplementation.wasPreloaded, isFalse);
    serviceProvider.boot();
    expect(ManuallyWiredServiceImplementation.wasPreloaded, isTrue);

    var svc = serviceProvider.resolve<ManuallyWiredService>();
    expect(svc, const TypeMatcher<ManuallyWiredService>());
  });

  test('hasService', () {
    expect(serviceProvider.has<MySingletonService>(), isTrue);
    expect(serviceProvider.has(MySingletonService), isTrue);
    expect(serviceProvider.has<ChatProvider>(), isTrue);
    expect(serviceProvider.has(ChatProvider), isTrue);
  });

  test('service registration', () {
    if (serviceProvider is! ServiceRegistry) {
      fail('Service provider is not a ServiceRegistry');
    }
    expect(serviceProvider.has<SelfRegisteredService>(), isFalse);
    (serviceProvider as ServiceRegistry).register(
      (provider) => MySelfRegisteredService(provider.resolve()),
      const Service(exposeAs: SelfRegisteredService),
    );
    expect(serviceProvider.has<SelfRegisteredService>(), isTrue);
  });
}

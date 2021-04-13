# Catalyst Builder

A dependency injection provider builder for dart.

## Background
Since [Catalyst](https://github.com/mintware-de/catalyst) is only for Dart and [Flutter Catalyst](https://github.com/mintware-de/flutter_catalyst)
supports Flutter, but a mess to configure I decided to do something cooler.

Catalyst Builder is a dependency injection provider builder for both, Dart and Flutter. It's easy to use and 
dependency injection is almost done automatically. You only have to decorate your services with `@Service` and the 
build_runner will create a service provider for you.


## Installation
**Warning, I am offering this package at an early stage. It may not perform as expected.**

Add this to your pubspec.yaml and run `pub get` or `flutter pub get`:
```yaml
dependencies:
  catalyst_builder: ^0.0.1

dev_dependencies:
  build_runner: ^1.12.2
```

## Usage
Decorate your services with `@Service`:
```dart
@Service()
class MyService {}
```

Then run `pub run build_runner build` or `flutter pub run build_runner build`. <br>
You can also run `pub run build_runner watch` or `flutter pub run build_runner watch` to update the provider automatically as you perform changes.

After the build is completed, you should see a new file `service_provider.dart`. Import it to use the service provider.

```dart
import 'default_service_provider.dart';

void main()
{
  var provider = DefaultServiceProvider();
  
  var myService1 = provider.resolve<MyService>();
  
  // Inferred types are also supported
  MyService myService2 = provider.resolve();
}
```

## Advanced usage

### Service lifetime
You can specify the lifetime of the service in the annotation.

```dart
@Service(
  lifetime: ServiceLifetime.singleton, // default
)
class SingletonService {}

@Service(
  lifetime: ServiceLifetime.transient,
)
class TransientService {}
```

| Lifetime  | Description |
| --------- | ----------- |
| Singleton | The instance is stored in the provider. You'll always receive the same instance. | 
| Transient | Everytime you call `resolve` or `tryResolve` you'll receive a fresh instance. |

### Exposing
You can expose the service with another type in the service provider. 
This is useful if you want to depend on an interface instead of an implementation.

```dart

abstract class Transport {
  void transferData(String data);
}

@Service(exposeAs: Transport)
class ConsoleTransport implements Transport {
  @override
  void transferData(String data) {}
}

abstract class ChatProvider {
  Transport transport;
  Future<void> sendChatMessage(String message);
}

@Service(exposeAs: ChatProvider)
class CoolChatProvider implements ChatProvider {
  @override
  Transport transport;

  CoolChatProvider(this.transport);

  @override
  Future<void> sendChatMessage(String message) {}
}

void main() {
  var provider = DefaultServiceProvider();

  var chatService = provider.resolve<ChatProvider>();

  print(chatService is CoolChatProvider); // true
  print(chatService.transport is ConsoleTransport); // true
}
```

## Inject parameters by name
The service provider will try to lookup values for non-existent services in the parameters map.
By default, the lookup is done based on the name of the parameter. For example:
```dart
@Service()
class MyService {
  String username;
  MyService(this.username);
}

void main() {
  ServiceProvider provider;
  provider['username'] = 'Test';
  
  var myService = provider.resolve<MyService>();
  
  print(myService.username); // Test 
}
```

In many cases you've generic terms like 'key' or 'name'. If you've many services with the same name, 
you'll get in trouble.

You can use the `@Parameter('param name')` annotation to solve this problem:
```dart
@Service()
class MyService {
  String username;
  MyService(@Parameter('senderUserName') this.username);
}

void main() {
  ServiceProvider provider;
  provider['senderUserName'] = 'Test 2';
  
  var myService = provider.resolve<MyService>();
  
  print(myService.username); // Test 2 
}
```
## Configuration
To customize the builder, create a `build.yaml` beside your `pubsepc.yaml` with this content:
```yaml
targets:
  $default:
    auto_apply_builders: true
    builders:
      catalyst_builder|buildServiceProvider:
        options:
            providerClassName: 'DefaultServiceProvider' # class name of the provider
            outputName: 'default_service_provider.dart' # file name of the provider. (Can also contain /)

```
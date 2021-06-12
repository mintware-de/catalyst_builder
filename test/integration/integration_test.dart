import 'package:catalyst_builder/catalyst_builder.dart';
import 'package:test/test.dart';

// ignore: avoid_relative_lib_imports
import '../../example/lib/example.dart';

void main() {
  late ServiceProvider serviceProvider;
  setUp(() {
    serviceProvider = ExampleProvider();
    serviceProvider.parameters['sender_username'] = 'Julian';

  });

  test('try/Resolve should throw when the provider is not booted', () {
    expect(
      () => serviceProvider.resolve<ChatProvider>(),
      throwsA(TypeMatcher<ProviderNotBootedException>()),
    );    expect(
      () => serviceProvider.tryResolve<ChatProvider>(),
      throwsA(TypeMatcher<ProviderNotBootedException>()),
    );
  });

  test('double boot should throw an exception', () {
    serviceProvider.boot();
    expect(
      () => serviceProvider.boot(),
      throwsA(TypeMatcher<ProviderAlreadyBootedException>()),
    );
  });
}

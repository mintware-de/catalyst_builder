import 'package:catalyst_builder_runtime/catalyst_builder_runtime.dart';
import 'package:test/test.dart';

void main() {
  group('Bugfixes', () {
    test('resolve should report the runtime type when one was passed (3.5)',
        () {
      final c = ServiceContainer();
      c.boot();
      expect(
        () => c.resolve<Object>(String),
        throwsA(
          isA<ServiceNotFoundException>()
              .having((e) => e.service, 'service', String),
        ),
      );
    });

    // Regression for 3.1: the generator used to emit
    // `resolveOrGetParameter<Logger?>('logger')` for required parameters
    // with a nullable type. The Type `Logger?` never matches the registered
    // `Logger`, and `parameters['logger'] is Logger?` is true for `null`,
    // so the resolve call threw even though the service was registered.
    // The generator now emits `tryResolveOrGetParameter<Logger>('logger')`
    // (explicit non-nullable type argument) for those parameters.
    test(
        'required nullable dependency resolves with explicit non-nullable '
        'type argument (3.1)', () {
      final c = ServiceContainer()
        ..register<_Logger>((_) => _Logger())
        ..register<_NeedsNullableLogger>(
          (c) => _NeedsNullableLogger(
            c.tryResolveOrGetParameter<_Logger>('logger'),
          ),
        );
      c.boot();
      expect(c.resolve<_NeedsNullableLogger>().logger, isA<_Logger>());
    });

    test('required nullable dependency is null when not registered (3.1)', () {
      final c = ServiceContainer()
        ..register<_NeedsNullableLogger>(
          (c) => _NeedsNullableLogger(
            c.tryResolveOrGetParameter<_Logger>('logger'),
          ),
        );
      c.boot();
      expect(c.resolve<_NeedsNullableLogger>().logger, isNull);
    });

    test('enhance should keep tags of manually registered services (3.6)', () {
      final c = ServiceContainer()
        ..register<_TaggedService>(
          (_) => _TaggedService(),
          const Service(tags: [#t]),
        );
      c.boot();
      final e = c.enhance();
      expect(e.resolveByTag(#t), hasLength(1));
    });
  });
}

class _Logger {}

class _NeedsNullableLogger {
  final _Logger? logger;

  const _NeedsNullableLogger(this.logger);
}

class _TaggedService {}

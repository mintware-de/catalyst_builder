import 'package:catalyst_builder_runtime/catalyst_builder_runtime.dart';
import 'package:test/test.dart';

void main() {
  group('Bugfixes', () {
    test(
        'resolve should report the runtime type when one was passed (3.5)',
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

    test('required nullable dependency should resolve (3.1)', () {
      final c = ServiceContainer()
        ..register<_Logger>((_) => _Logger())
        ..register<_NeedsNullableLogger>(
          (c) => _NeedsNullableLogger(
            c.resolveOrGetParameter<_Logger?>(_NeedsNullableLogger, 'logger'),
          ),
        );
      c.boot();
      expect(c.resolve<_NeedsNullableLogger>().logger, isA<_Logger>());
    });

    test('enhance should keep tags of manually registered services (3.6)',
        () {
      final c = ServiceContainer()
        ..register<_TaggedService>(
          (_) => _TaggedService(),
          const Service(tags: [#t]),
        );
      c.boot();
      final e = c.enhance();
      expect(e.resolveByTag(#t), hasLength(1));
    }, skip: 'fixed in task 04');
  });
}

class _Logger {}

class _NeedsNullableLogger {
  final _Logger? logger;

  const _NeedsNullableLogger(this.logger);
}

class _TaggedService {}

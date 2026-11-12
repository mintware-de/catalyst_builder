import 'package:catalyst_builder/src/builder/dto/dto.dart';
import 'package:catalyst_builder/src/builder/validation/service_graph_validator.dart';
import 'package:test/test.dart';

const _library = 'package:app/app.dart';

ExtractedService _svc(
  String name, {
  String lifetime = 'ServiceLifetime.singleton',
  List<ConstructorArg> args = const [],
  String? exposeAs,
}) {
  return ExtractedService(
    lifetime: lifetime,
    service: SymbolReference(symbolName: name, library: _library),
    exposeAs: exposeAs != null
        ? SymbolReference(symbolName: exposeAs, library: _library)
        : null,
    constructorArgs: args,
    preload: false,
    tags: const [],
  );
}

ConstructorArg _dep(String name, String typeName) {
  return ConstructorArg(
    name: name,
    defaultValue: '',
    isOptional: false,
    isPositional: true,
    isNamed: false,
    inject: null,
    type: TypeRef(symbolName: typeName, library: _library),
  );
}

void main() {
  test('empty graph produces no messages', () {
    expect(validateServiceGraph([]), isEmpty);
  });

  test('a cycle A -> B -> A produces one error with the path', () {
    var messages = validateServiceGraph([
      _svc('A', args: [_dep('b', 'B')]),
      _svc('B', args: [_dep('a', 'A')]),
    ]);
    expect(messages, hasLength(1));
    expect(messages.single.severity, ValidationSeverity.error);
    expect(messages.single.message, 'Circular dependency: A -> B -> A');
  });

  test('singleton depending on scoped produces one error', () {
    var messages = validateServiceGraph([
      _svc('A', args: [_dep('b', 'B')]),
      _svc('B', lifetime: 'ServiceLifetime.scoped'),
    ]);
    expect(messages, hasLength(1));
    expect(messages.single.severity, ValidationSeverity.error);
    expect(
      messages.single.message,
      'Singleton A depends on scoped B (captive dependency). '
      'Make A scoped/transient or inject a factory.',
    );
  });

  test('scoped depending on singleton produces no message', () {
    var messages = validateServiceGraph([
      _svc('A', lifetime: 'ServiceLifetime.scoped', args: [_dep('b', 'B')]),
      _svc('B'),
    ]);
    expect(messages, isEmpty);
  });

  test('an unknown required type produces one warning', () {
    var messages = validateServiceGraph([
      _svc('A', args: [_dep('x', 'Unknown')]),
    ]);
    expect(messages, hasLength(1));
    expect(messages.single.severity, ValidationSeverity.warning);
    expect(
      messages.single.message,
      'A(x): Unknown is not a known service in this plugin. Provide it '
      'via parameters, register() or another plugin.',
    );
  });

  test('nullable, optional and defaulted parameters produce no warning', () {
    var nullable = ConstructorArg(
      name: 'x',
      defaultValue: '',
      isOptional: false,
      isPositional: true,
      isNamed: false,
      inject: null,
      type: const TypeRef(symbolName: 'Unknown', library: _library),
      isNullable: true,
    );
    var optional = ConstructorArg(
      name: 'x',
      defaultValue: '',
      isOptional: true,
      isPositional: false,
      isNamed: true,
      inject: null,
      type: const TypeRef(symbolName: 'Unknown', library: _library),
    );
    var withDefault = ConstructorArg(
      name: 'x',
      defaultValue: 'null',
      isOptional: true,
      isPositional: false,
      isNamed: true,
      inject: null,
      type: const TypeRef(symbolName: 'Unknown', library: _library),
    );

    var messages = validateServiceGraph([
      _svc('A', args: [nullable, optional, withDefault]),
    ]);
    expect(messages, isEmpty);
  });

  test('parameters injected by tag or parameter are ignored', () {
    var byTag = ConstructorArg(
      name: 'x',
      defaultValue: '',
      isOptional: false,
      isPositional: true,
      isNamed: false,
      inject: const InjectAnnotation(tag: 'unknownTag'),
      type: const TypeRef(symbolName: 'Unknown', library: _library),
    );
    var byParameter = ConstructorArg(
      name: 'x',
      defaultValue: '',
      isOptional: false,
      isPositional: true,
      isNamed: false,
      inject: const InjectAnnotation(parameter: 'someParameter'),
      type: const TypeRef(symbolName: 'Unknown', library: _library),
    );

    var messages = validateServiceGraph([
      _svc('A', args: [byTag, byParameter]),
    ]);
    expect(messages, isEmpty);
  });

  test('two services with the same exposeAs produce one warning', () {
    var messages = validateServiceGraph([
      _svc('X', exposeAs: 'Z'),
      _svc('Y', exposeAs: 'Z'),
    ]);
    expect(messages, hasLength(1));
    expect(messages.single.severity, ValidationSeverity.warning);
    expect(
      messages.single.message,
      'Both X and Y are exposed as Z; Y wins.',
    );
  });

  test('validationModeFromOptions maps the config value', () {
    expect(validationModeFromOptions('strict'), ValidationMode.strict);
    expect(validationModeFromOptions('off'), ValidationMode.off);
    expect(validationModeFromOptions('warn'), ValidationMode.warn);
    expect(validationModeFromOptions(null), ValidationMode.warn);
    expect(validationModeFromOptions('nope'), ValidationMode.warn);
  });
}

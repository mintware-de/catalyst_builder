import 'package:catalyst_builder_runtime/catalyst_builder_runtime.dart';

import '../dto/dto.dart';

/// The severity of a [ValidationMessage].
enum ValidationSeverity {
  /// A problem that probably is a bug but may be intentional, for example
  /// a dependency that is provided by another plugin or at runtime.
  warning,

  /// A problem that breaks the application, for example a circular
  /// dependency.
  error,
}

/// A single message produced by [validateServiceGraph].
class ValidationMessage {
  /// How serious this message is.
  final ValidationSeverity severity;

  /// The human readable message.
  final String message;

  /// Creates a new [ValidationMessage].
  const ValidationMessage(this.severity, this.message);

  @override
  bool operator ==(Object other) =>
      other is ValidationMessage &&
      other.severity == severity &&
      other.message == message;

  @override
  int get hashCode => Object.hash(severity, message);

  @override
  String toString() => '${severity.name}: $message';
}

/// How the plugin builder treats the messages of [validateServiceGraph].
enum ValidationMode {
  /// Errors and warnings abort the build.
  strict,

  /// Errors abort the build, warnings are logged. This is the default.
  warn,

  /// The service graph is not validated.
  off,
}

/// Maps the value of the `validation` builder option to a
/// [ValidationMode].
///
/// Unknown or missing values result in [ValidationMode.warn].
ValidationMode validationModeFromOptions(Object? value) {
  switch (value?.toString()) {
    case 'strict':
      return ValidationMode.strict;
    case 'off':
      return ValidationMode.off;
    default:
      return ValidationMode.warn;
  }
}

String _nodeKey(SymbolReference reference) =>
    '${reference.library}:${reference.symbolName}';

String _displayName(ExtractedService service) => service.service.symbolName;

/// Validates the service graph described by [services].
///
/// The graph has one node per service, keyed by `exposeAs ?? service`, and
/// an edge from `A` to `B` for every constructor parameter of `A` that is
/// not injected by tag or parameter and whose type is a known service.
///
/// Returns one [ValidationMessage] per problem. Services registered by
/// other plugins are invisible to the validator, which is why an unknown
/// dependency is only a warning.
List<ValidationMessage> validateServiceGraph(List<ExtractedService> services) {
  var messages = <ValidationMessage>[];

  var byKey = <String, ExtractedService>{};
  for (var service in services) {
    byKey[_nodeKey(service.exposeAs ?? service.service)] = service;
  }

  // The dependency edges of each node, in registration order.
  var edges = <String, List<String>>{};
  for (var service in services) {
    var nodeKey = _nodeKey(service.exposeAs ?? service.service);
    var targets = <String>[];
    for (var arg in service.constructorArgs) {
      var inject = arg.inject;
      if (inject != null && (inject.tag != null || inject.parameter != null)) {
        continue;
      }
      var type = arg.type;
      if (type == null) {
        continue;
      }
      var targetKey = '${type.library}:${type.symbolName}';
      var target = byKey[targetKey];
      if (target == null) {
        // Services from other packages are not visible here, so an
        // unknown type is only reported for required parameters.
        if (!_isOptional(arg) && !arg.isNullable) {
          messages.add(
            ValidationMessage(
              ValidationSeverity.warning,
              '${_displayName(service)}(${arg.name}): ${type.symbolName} is '
              'not a known service in this plugin. Provide it via '
              'parameters, register() or another plugin.',
            ),
          );
        }
        continue;
      }
      targets.add(targetKey);
    }
    edges[nodeKey] = targets;
  }

  messages.addAll(_validateCycles(services, byKey, edges));
  messages.addAll(_validateCaptiveDependencies(services, byKey, edges));
  messages.addAll(_validateExposeAs(services));

  return messages;
}

bool _isOptional(ConstructorArg arg) =>
    arg.isOptional || arg.defaultValue.isNotEmpty;

List<ValidationMessage> _validateCycles(
  List<ExtractedService> services,
  Map<String, ExtractedService> byKey,
  Map<String, List<String>> edges,
) {
  var messages = <ValidationMessage>[];
  var seenCycles = <String>{};
  var completed = <String>{};
  var stack = <String>[];
  var onStack = <String>{};

  void visit(String nodeKey) {
    if (onStack.contains(nodeKey)) {
      var start = stack.indexOf(nodeKey);
      var path = [
        for (var key in stack.sublist(start)) _displayName(byKey[key]!),
        _displayName(byKey[nodeKey]!),
      ];
      var signature = path.join(' -> ');
      if (seenCycles.add(signature)) {
        messages.add(
          ValidationMessage(
            ValidationSeverity.error,
            'Circular dependency: $signature',
          ),
        );
      }
      return;
    }
    if (completed.contains(nodeKey)) {
      return;
    }
    stack.add(nodeKey);
    onStack.add(nodeKey);
    for (var target in edges[nodeKey] ?? const <String>[]) {
      visit(target);
    }
    stack.removeLast();
    onStack.remove(nodeKey);
    completed.add(nodeKey);
  }

  for (var service in services) {
    visit(_nodeKey(service.exposeAs ?? service.service));
  }
  return messages;
}

List<ValidationMessage> _validateCaptiveDependencies(
  List<ExtractedService> services,
  Map<String, ExtractedService> byKey,
  Map<String, List<String>> edges,
) {
  var messages = <ValidationMessage>[];
  var seen = <String>{};
  for (var service in services) {
    if (service.typedLifetime != ServiceLifetime.singleton) {
      continue;
    }
    var nodeKey = _nodeKey(service.exposeAs ?? service.service);
    for (var targetKey in edges[nodeKey] ?? const <String>[]) {
      var target = byKey[targetKey]!;
      if (target.typedLifetime != ServiceLifetime.scoped) {
        continue;
      }
      var signature = '${_displayName(service)} -> ${_displayName(target)}';
      if (seen.add(signature)) {
        messages.add(
          ValidationMessage(
            ValidationSeverity.error,
            'Singleton ${_displayName(service)} depends on scoped '
            '${_displayName(target)} (captive dependency). Make '
            '${_displayName(service)} scoped/transient or inject a '
            'factory.',
          ),
        );
      }
    }
  }
  return messages;
}

List<ValidationMessage> _validateExposeAs(List<ExtractedService> services) {
  var messages = <ValidationMessage>[];
  var firstProviderByExpose = <String, String>{};
  for (var service in services) {
    var exposeAs = service.exposeAs;
    if (exposeAs == null) {
      continue;
    }
    var key = _nodeKey(exposeAs);
    var previous = firstProviderByExpose[key];
    if (previous == null) {
      firstProviderByExpose[key] = _displayName(service);
    } else {
      messages.add(
        ValidationMessage(
          ValidationSeverity.warning,
          'Both $previous and ${_displayName(service)} are exposed as '
          '${exposeAs.symbolName}; ${_displayName(service)} wins.',
        ),
      );
      // The last registration wins in the generated code.
      firstProviderByExpose[key] = _displayName(service);
    }
  }
  return messages;
}

import 'dart:async';
import 'dart:convert';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';

import '../../catalyst_builder.dart';
import 'dto/dto.dart';

/// The PreflightBuilder scans the files for @Service annotations.
/// The result is stored in preflight.json files.
class PreflightBuilder implements Builder {
  final Map<String, dynamic> _config;

  /// PreflightBuilder constructor
  PreflightBuilder(this._config);

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    if (!await buildStep.resolver.isLibrary(buildStep.inputId)) {
      return;
    }

    final entryLib = await buildStep.inputLibrary;

    final preflightAsset =
        buildStep.inputId.changeExtension(_config['preflightExtension']);
    var extractedAnnotations = await _extractAnnotations(entryLib);

    await buildStep.writeAsString(
      preflightAsset,
      jsonEncode(extractedAnnotations),
    );
  }

  @override
  Map<String, List<String>> get buildExtensions => {
        r'$lib$': [],
        '.dart': [_config['preflightExtension']],
      };

  Future<PreflightPart> _extractAnnotations(LibraryElement entryLib) async {
    var services = <ExtractedService>[];
    for (var el in entryLib.topLevelElements) {
      var isPreloaded =
          el.metadata.any((a) => _isLibraryAnnotation(a, 'Preload'));
      for (var annotation in el.metadata) {
        if (_isLibraryAnnotation(annotation, 'Service') && el is ClassElement) {
          var serviceAnnotation = annotation.computeConstantValue();

          var lifetimeIndex = serviceAnnotation
                  ?.getField('lifetime')
                  ?.getField('index')
                  ?.toIntValue() ??
              1;

          var exposeAsElement =
              serviceAnnotation?.getField('exposeAs')?.toTypeValue()?.element;

          SymbolReference? exposeAs;
          if (exposeAsElement != null) {
            exposeAs = SymbolReference(
              symbolName: exposeAsElement.name!,
              library: exposeAsElement.librarySource?.uri.toString(),
            );
          }

          var lifetime = ServiceLifetime.values[lifetimeIndex];
          services.add(ExtractedService(
            lifetime: lifetime.toString(),
            service: SymbolReference(
              symbolName: el.name,
              library: el.librarySource.uri.toString(),
            ),
            constructorArgs: await _extractConstructorArgs(el),
            exposeAs: exposeAs,
            preload: isPreloaded && lifetime == ServiceLifetime.singleton,
          ));
        }
      }
    }
    return PreflightPart(
      services: services,
    );
  }

  Future<List<ConstructorArg>> _extractConstructorArgs(ClassElement el) async {
    var args = <ConstructorArg>[];

    for (var ctor in el.constructors) {
      if (ctor.isFactory || ctor.name != '') {
        continue;
      }
      args.clear();

      for (var param in ctor.parameters) {
        args.add(await _buildConstructorArg(param));
      }
      break;
    }
    return args;
  }

  Future<ConstructorArg> _buildConstructorArg(ParameterElement param) async {
    String? binding;
    for (var annotation in param.metadata) {
      if (_isLibraryAnnotation(annotation, 'Parameter')) {
        binding = annotation
            .computeConstantValue()
            ?.getField('name')
            ?.toStringValue();
        if (binding?.isNotEmpty == true) {
          break;
        }
      }
    }

    return ConstructorArg(
      boundParameter: binding,
      name: param.name,
      isOptional: param.isOptional,
      isPositional: param.isPositional,
      isNamed: param.isNamed,
      defaultValue: param.defaultValueCode ?? '',
    );
  }

  bool _isLibraryAnnotation(ElementAnnotation annotation, String name) {
    return annotation.element != null &&
        (annotation.element!.library?.source.uri
                .toString()
                .startsWith('package:catalyst_builder/src/annotation/') ??
            false) &&
        annotation.element?.enclosingElement?.name == name;
  }
}

/// Runs the preflight builder
Builder runPreflight(BuilderOptions options) =>
    PreflightBuilder(options.config);

import 'dart:async';
import 'dart:convert';

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';

import '../../catalyst_builder.dart';
import 'dto/dto.dart';

/// The PreflightBuilder scans the files for @Service annotations.
/// The result is stored in preflight.json files.
class PreflightBuilder implements Builder {
  @override
  FutureOr<void> build(BuildStep buildStep) async {
    if (!await buildStep.resolver.isLibrary(buildStep.inputId)) {
      return;
    }

    final entryLib = await buildStep.inputLibrary;

    final preflightAsset =
        buildStep.inputId.changeExtension('.catalyst_builder.preflight.json');
    var extractedAnnotations = await _extractAnnotations(entryLib);

    await buildStep.writeAsString(
      preflightAsset,
      jsonEncode(extractedAnnotations),
    );
  }

  @override
  Map<String, List<String>> get buildExtensions => {
        r'$lib$': [],
        '.dart': ['.catalyst_builder.preflight.json'],
      };

  Future<PreflightPart> _extractAnnotations(LibraryElement entryLib) async {
    var services = <ExtractedService>[];
    for (var el in entryLib.topLevelElements) {
      var isPreloaded =
          el.metadata.any((a) => _isLibraryAnnotation(a, 'Preload'));
      for (var annotation in el.metadata) {
        if (_isLibraryAnnotation(annotation, 'ServiceMap')) {
          var serviceMapAnnotation = annotation.computeConstantValue();

          var serviceMap =
              serviceMapAnnotation?.getField('services')?.toMapValue() ?? {};
          for (var kvp in serviceMap.entries) {
            var typed = kvp.key?.toTypeValue();
            if (typed is! InterfaceType) {
              continue;
            }

            var keyElement = typed.element2;
            if (keyElement is! ClassElement) {
              continue;
            }

            services.add(await _mapToExtractedService(
              keyElement,
              kvp.value,
              isPreloaded,
            ));
          }
        }
        if (_isLibraryAnnotation(annotation, 'Service') && el is ClassElement) {
          var serviceAnnotation = annotation.computeConstantValue();
          services.add(await _mapToExtractedService(
            el,
            serviceAnnotation,
            isPreloaded,
          ));
        }
      }
    }
    return PreflightPart(
      services: services,
    );
  }

  Future<ExtractedService> _mapToExtractedService(
    ClassElement serviceClass,
    DartObject? serviceAnnotation,
    bool isPreloaded,
  ) async {
    var serviceReference = SymbolReference(
      symbolName: serviceClass.name,
      library: serviceClass.librarySource.uri.toString(),
    );

    var lifetime = _getLifetimeFromAnnotation(serviceAnnotation);
    var exposeAs = _getExposeAs(serviceAnnotation);
    var tags = _getTags(serviceAnnotation);

    var extractedService = ExtractedService(
      lifetime: lifetime.toString(),
      service: serviceReference,
      constructorArgs: await _extractConstructorArgs(serviceClass),
      exposeAs: exposeAs,
      preload: isPreloaded && lifetime == ServiceLifetime.singleton,
      tags: tags,
    );
    return extractedService;
  }

  SymbolReference? _getExposeAs(DartObject? serviceAnnotation) {
    var typeValue = serviceAnnotation?.getField('exposeAs')?.toTypeValue();
    if (typeValue is! InterfaceType) {
      return null;
    }

    var exposeAsElement = typeValue.element2;

    return SymbolReference(
      symbolName: exposeAsElement.name,
      library: exposeAsElement.librarySource.uri.toString(),
    );
  }

  ServiceLifetime _getLifetimeFromAnnotation(DartObject? serviceAnnotation) {
    var lifetimeIndex = serviceAnnotation
            ?.getField('lifetime')
            ?.getField('index')
            ?.toIntValue() ??
        1;
    var lifetime = ServiceLifetime.values[lifetimeIndex];
    return lifetime;
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
        annotation.element?.enclosingElement3?.name == name;
  }

  List<String> _getTags(DartObject? serviceAnnotation) {
    var tags = <String>[];

    var tagsElement = serviceAnnotation?.getField('tags')?.toListValue();
    if (tagsElement != null) {
      for (var tag in tagsElement.toList()) {
        var stringValue = tag.toSymbolValue();
        if (stringValue != null) {
          tags.add(stringValue);
        }
      }
    }
    return tags;
  }
}

/// Runs the preflight builder
Builder runPreflight(BuilderOptions options) => PreflightBuilder();

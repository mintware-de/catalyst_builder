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
    var extractedAnnotations = _extractAnnotations(entryLib);

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

  PreflightPart _extractAnnotations(LibraryElement entryLib) {
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

            var keyElement = typed.element;
            if (keyElement is! ClassElement) {
              continue;
            }

            services.add(_mapToExtractedService(
              keyElement,
              kvp.value,
              isPreloaded,
            ));
          }
        }
        if (_isLibraryAnnotation(annotation, 'Service') && el is ClassElement) {
          var serviceAnnotation = annotation.computeConstantValue();
          services.add(_mapToExtractedService(
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

  ExtractedService _mapToExtractedService(
    ClassElement serviceClass,
    DartObject? serviceAnnotation,
    bool isPreloaded,
  ) {
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
      constructorArgs: _extractConstructorArgs(serviceClass),
      exposeAs: exposeAs,
      preload: isPreloaded && lifetime == ServiceLifetime.singleton,
      tags: tags,
    );
    return extractedService;
  }

  SymbolReference? _getExposeAs(DartObject? serviceAnnotation) {
    var typed = serviceAnnotation?.getField('exposeAs')?.toTypeValue();
    if (typed is! InterfaceType) {
      return null;
    }

    var exposeAsElement = typed.element;

    return SymbolReference(
      symbolName: exposeAsElement.name,
      library: exposeAsElement.librarySource.uri.toString(),
    );
  }

  ServiceLifetime _getLifetimeFromAnnotation(DartObject? serviceAnnotation) {
    var lifetimeIndex = serviceAnnotation
        ?.getField('lifetime')
        ?.getField('index')
        ?.toIntValue();
    return ServiceLifetime.values[lifetimeIndex ?? 1];
  }

  List<ConstructorArg> _extractConstructorArgs(ClassElement el) {
    return el.constructors
            .cast<ConstructorElement?>()
            .firstWhere(
              (ctor) => ctor != null && !ctor.isFactory && ctor.name == '',
              orElse: () => null,
            )
            ?.parameters
            .map(_buildConstructorArg)
            .toList() ??
        [];
  }

  ConstructorArg _buildConstructorArg(ParameterElement param) {
    var binding = param.metadata
        .cast<ElementAnnotation?>()
        .firstWhere(
          (a) => _isLibraryAnnotation(a!, 'Parameter'),
          orElse: () => null,
        )
        ?.computeConstantValue()
        ?.getField('name')
        ?.toStringValue();

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

  List<String> _getTags(DartObject? serviceAnnotation) {
    return serviceAnnotation
            ?.getField('tags')
            ?.toListValue()
            ?.toList()
            .map((e) => e.toSymbolValue())
            .where((e) => e != null)
            .cast<String>()
            .toList() ??
        [];
  }
}

/// Runs the preflight builder
Builder runPreflight(BuilderOptions options) => PreflightBuilder();

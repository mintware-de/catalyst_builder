import 'dart:async';
import 'dart:convert';

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:path/path.dart' as p;

import '../cache_helper.dart';
import '../service_lifetime.dart';
import 'constants.dart';
import 'dto/dto.dart';
import 'helpers.dart';

/// The PreflightBuilder scans the files for @Service annotations.
/// The result is stored in preflight.json files.
class PreflightBuilder implements Builder {
  @override
  final Map<String, List<String>> buildExtensions = {
    r'$lib$': [],
    '.dart': [preflightExtension],
  };

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    if (!await buildStep.resolver.isLibrary(buildStep.inputId)) {
      return;
    }

    var extractedAnnotations = _extractAnnotations(
      await buildStep.inputLibrary,
    );

    final cachedPath = _getFilename(buildStep);
    if (extractedAnnotations.services.isEmpty) {
      await CacheHelper.deleteFileFromCache(cachedPath);
      return;
    }

    await CacheHelper.writeFileToCache(
      cachedPath,
      jsonEncode(extractedAnnotations),
    );
  }

  String _getFilename(BuildStep buildStep) {
    final preflightAsset = buildStep.inputId.changeExtension(
      preflightExtension,
    );

    var cachedPath = p.join(preflightAsset.package, preflightAsset.path);
    return cachedPath;
  }

  PreflightPart _extractAnnotations(LibraryElement entryLib) {
    var services = <ExtractedService>[];

    for (var lib in entryLib.topLevelElements) {
      services.addAll(_extractFromTopLevelElement(lib));
    }

    return PreflightPart(
      services: services,
    );
  }

  List<ExtractedService> _extractFromTopLevelElement(Element el) {
    var services = <ExtractedService>[];
    var isPreloaded = el.metadata.any((a) => a.isLibraryAnnotation('Preload'));

    for (var annotation in el.metadata) {
      if (annotation.isLibraryAnnotation('ServiceMap')) {
        services.addAll(
          _extractServicesFromServiceMap(annotation, isPreloaded),
        );
      }
      if (annotation.isLibraryAnnotation('Service') && el is ClassElement) {
        var serviceAnnotation = annotation.computeConstantValue();
        services.add(_mapToExtractedService(
          el,
          serviceAnnotation,
          isPreloaded,
        ));
      }
    }
    return services;
  }

  List<ExtractedService> _extractServicesFromServiceMap(
    ElementAnnotation annotation,
    bool isPreloaded,
  ) {
    var serviceMapServices = <ExtractedService>[];

    var serviceMapAnnotation = annotation.computeConstantValue();
    var map = serviceMapAnnotation?.getField('services')?.toMapValue() ?? {};
    for (var kvp in map.entries) {
      var typed = kvp.key?.toTypeValue();
      if (typed is! InterfaceType) {
        continue;
      }

      var keyElement = typed.element;
      if (keyElement is! ClassElement) {
        continue;
      }

      serviceMapServices.add(_mapToExtractedService(
        keyElement,
        kvp.value,
        isPreloaded,
      ));
    }
    return serviceMapServices;
  }

  ExtractedService _mapToExtractedService(
    ClassElement serviceClass,
    DartObject? serviceAnnotation,
    bool isPreloaded,
  ) {
    var lifetime = _getLifetimeFromAnnotation(serviceAnnotation);

    return ExtractedService(
      lifetime: lifetime.toString(),
      service: SymbolReference(
        symbolName: serviceClass.name,
        library: serviceClass.librarySource.uri.toString(),
      ),
      constructorArgs: _extractConstructorArgs(serviceClass),
      exposeAs: _getExposeAs(serviceAnnotation),
      preload: isPreloaded && lifetime == ServiceLifetime.singleton,
      tags: _getTags(serviceAnnotation),
    );
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
        .firstWhere((ctor) => !ctor.isFactory && ctor.name == '')
        .parameters
        .map(_buildConstructorArg)
        .toList();
  }

  ConstructorArg _buildConstructorArg(ParameterElement param) {
    var annotations = param.metadata.cast<ElementAnnotation?>();

    return ConstructorArg(
      name: param.name,
      isOptional: param.isOptional,
      isPositional: param.isPositional,
      isNamed: param.isNamed,
      defaultValue: param.defaultValueCode ?? '',
      inject: _extractInjectAnnotation(annotations),
    );
  }

  InjectAnnotation? _extractInjectAnnotation(
    List<ElementAnnotation?> annotations,
  ) {
    var injectAnnotation = annotations.firstWhere(
      (a) => a!.isLibraryAnnotation('Inject'),
      orElse: () => null,
    );

    if (injectAnnotation == null) {
      return null;
    }

    var constantValue = injectAnnotation.computeConstantValue();
    var tag = constantValue?.getField('tag')?.toSymbolValue();
    var parameter = constantValue?.getField('parameter')?.toStringValue();

    return InjectAnnotation(
      tag: tag,
      parameter: parameter,
    );
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

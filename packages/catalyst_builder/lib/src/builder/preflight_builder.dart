import 'dart:async';
import 'dart:convert';

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:catalyst_builder_contracts/catalyst_builder_contracts.dart';

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

    LibraryElement2 libraryElement;
    try {
      libraryElement = await buildStep.inputLibrary;
    } catch (e) {
      log.warning('Error while processing input library. Skip for now.', e);
      return;
    }
    var extractedAnnotations = _extractAnnotations(libraryElement);

    if (extractedAnnotations.services.isEmpty) {
      return;
    }

    buildStep.writeAsString(
      buildStep.inputId.changeExtension(preflightExtension),
      jsonEncode(extractedAnnotations),
    );
  }

  PreflightPart _extractAnnotations(LibraryElement2 entryLib) {
    var services = <ExtractedService>[];

    for (var lib in entryLib.children2.whereType<Annotatable>()) {
      services.addAll(_extractFromTopLevelElement(lib));
    }

    return PreflightPart(services: services);
  }

  List<ExtractedService> _extractFromTopLevelElement(Annotatable el) {
    var services = <ExtractedService>[];
    var isPreloaded = el.metadata2.annotations.any(
      (a) => a.isLibraryAnnotation('Preload'),
    );

    for (var annotation in el.metadata2.annotations) {
      if (annotation.isLibraryAnnotation('ServiceMap')) {
        services.addAll(
          _extractServicesFromServiceMap(annotation, isPreloaded),
        );
      }
      if (annotation.isLibraryAnnotation('Service') && el is ClassElement2) {
        var serviceAnnotation = annotation.computeConstantValue();
        services.add(
          _mapToExtractedService(el, serviceAnnotation, isPreloaded),
        );
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

      var keyElement = typed.element3;
      if (keyElement is! ClassElement2) {
        continue;
      }

      serviceMapServices.add(
        _mapToExtractedService(keyElement, kvp.value, isPreloaded),
      );
    }
    return serviceMapServices;
  }

  ExtractedService _mapToExtractedService(
    ClassElement2 serviceClass,
    DartObject? serviceAnnotation,
    bool isPreloaded,
  ) {
    var lifetime = _getLifetimeFromAnnotation(serviceAnnotation);

    return ExtractedService(
      lifetime: lifetime.toString(),
      service: SymbolReference(
        symbolName: serviceClass.displayName,
        library: serviceClass.library2.uri.toString(),
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

    var exposeAsElement = typed.element3;

    return SymbolReference(
      symbolName: exposeAsElement.displayName,
      library: exposeAsElement.library2.uri.toString(),
    );
  }

  ServiceLifetime _getLifetimeFromAnnotation(DartObject? serviceAnnotation) {
    var lifetimeIndex = serviceAnnotation
        ?.getField('lifetime')
        ?.getField('index')
        ?.toIntValue();
    return ServiceLifetime.values[lifetimeIndex ?? 1];
  }

  List<ConstructorArg> _extractConstructorArgs(ClassElement2 el) {
    var constructors = el.children2
        .whereType<ConstructorElement2>()
        .where(
          (ctor) =>
              !ctor.isFactory &&
              (ctor.firstFragment.name2 == '' ||
                  ctor.firstFragment.name2 == 'new'),
        )
        .toList();
    return constructors.firstOrNull?.formalParameters
            .map(_buildConstructorArg)
            .toList() ??
        [];
  }

  ConstructorArg _buildConstructorArg(FormalParameterElement param) {
    var annotations = param.metadata2.annotations;

    return ConstructorArg(
      name: param.displayName,
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
    var injectAnnotation = annotations.cast<ElementAnnotation?>().firstWhere(
          (a) => a!.isLibraryAnnotation('Inject'),
          orElse: () => null,
        );

    if (injectAnnotation == null) {
      return null;
    }

    var constantValue = injectAnnotation.computeConstantValue();
    var tag = constantValue?.getField('tag')?.toSymbolValue();
    var parameter = constantValue?.getField('parameter')?.toStringValue();

    return InjectAnnotation(tag: tag, parameter: parameter);
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

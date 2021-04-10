import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:di_experimental/di_experimental.dart';

class ServiceElementPair {
  final ElementAnnotation service;
  final ClassElement element;

  const ServiceElementPair(this.service, this.element);
}

class PreflightStorage {
  ElementAnnotation? containerRoot;
  List<ServiceElementPair> services = [];

  void dispose() {
    containerRoot = null;
    services.clear();
  }
}

final preflightResource = Resource(
  () => PreflightStorage(),
  dispose: (instance) => instance.dispose(),
);

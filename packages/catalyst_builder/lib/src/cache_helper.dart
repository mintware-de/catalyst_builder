import 'dart:io';

import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:path/path.dart' as p;

import './builder/constants.dart';
import './builder/dto/dto.dart';

final class CacheHelper {
  static const _preflightFilePattern = '**/*$preflightExtension';
  static final _preflightFiles = Glob(_preflightFilePattern, recursive: true);

  static const _entrypointFilePattern = '**/*$entrypointExtension';
  static final _entrypointFiles = Glob(_entrypointFilePattern, recursive: true);

  /// Returns the path to the cache directory
  late final String _cachePath;

  late final Directory _cacheDir = Directory(_cachePath);

  CacheHelper() {
    var config = Config.load();
    _cachePath = p.isAbsolute(config.cacheDir)
        ? config.cacheDir
        : p.join(p.current, config.cacheDir);
  }

  Stream<FileSystemEntity> get preflightFiles =>
      _preflightFiles.list(root: _cachePath);

  Stream<FileSystemEntity> get entrypointFiles =>
      _entrypointFiles.list(root: _cachePath);

  Stream<FileSystemEntity> getPreflightFilesForPackage(String package) {
    return Glob('$package/$_preflightFilePattern', recursive: true)
        .list(root: _cachePath);
  }

  Future<void> cleanCacheDir() async {
    if (await _cacheDir.exists()) {
      await _cacheDir.delete(recursive: true);
    }
  }

  Future<void> createCacheDirectory() async {
    if (!(await _cacheDir.exists())) {
      await _cacheDir.create(recursive: true);
    }
  }

  Future<void> deleteFileFromCache(String filename) async {
    var f = _getCacheFile(filename);
    if (await f.exists()) {
      await f.delete(recursive: true);
    }
  }

  Future<void> writeFileToCache(
    String filename,
    String contents,
  ) async {
    File f = _getCacheFile(filename);
    if (!(await f.exists())) {
      await f.create(recursive: true);
    }
    await f.writeAsString(contents, mode: FileMode.writeOnly);
  }

  File _getCacheFile(String filename) {
    var cachedName = p.join(_cachePath, filename);
    var f = File(cachedName);
    return f;
  }
}

import 'dart:io';

import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:path/path.dart' as p;

import './builder/constants.dart';

abstract final class CacheHelper {
  static final _filePattern = '**/*$preflightExtension';
  static final _preflightFiles = Glob(_filePattern, recursive: true);

  /// Returns the path to the cache directory
  static final String _cachePath = p.join(
    p.current,
    cacheDir,
  );

  static final Directory _cacheDir = Directory(_cachePath);

  static Stream<FileSystemEntity> get preflightFiles =>
      _preflightFiles.list(root: _cachePath);

  static Stream<FileSystemEntity> getPreflightFilesForPackage(String package) {
    return Glob('$package/$_filePattern', recursive: true)
        .list(root: _cachePath);
  }

  static Future<void> cleanCacheDir() async {
    if (await _cacheDir.exists()) {
      await _cacheDir.delete(recursive: true);
    }
  }

  static Future<void> createCacheDirectory() async {
    if (!(await _cacheDir.exists())) {
      await _cacheDir.create(recursive: true);
    }
  }

  static Future<void> deleteFileFromCache(String filename) async {
    var f = _getCacheFile(filename);
    if (await f.exists()) {
      await f.delete(recursive: true);
    }
  }

  static Future<void> writeFileToCache(
    String filename,
    String contents,
  ) async {
    File f = _getCacheFile(filename);
    if (!(await f.exists())) {
      await f.create(recursive: true);
    }
    await f.writeAsString(contents, mode: FileMode.writeOnly);
  }

  static File _getCacheFile(String filename) {
    var cachedName = p.join(_cachePath, filename);
    var f = File(cachedName);
    return f;
  }
}

import 'package:flutter/foundation.dart';

abstract class CacheKey {
  final String name;

  const CacheKey({required this.name});

  String get key => switch (kDebugMode) {
    true => '${name}_debug',
    false => name,
  };

  String keyByPath(String path) => '$key$path';

  String savedAt(String path) => '${key}${path}_saved_at';
}

class UrlCacheKey extends CacheKey {
  const UrlCacheKey() : super(name: 'url');
}

class JsonCacheKey extends CacheKey {
  const JsonCacheKey() : super(name: 'json');
}

import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../data/repositories/analytics_repository.dart';

final _kCamelCaseRegExp = RegExp('(?<=[a-z])[A-Z]');

abstract class EventEntity {
  const EventEntity();

  Map<String, Object>? get properties;

  Map<String, Object>? get propertiesToAvoidAssertInputTypes =>
      deepToStringAndRemoveNulls(properties);

  Map<String, Object>? deepToStringAndRemoveNulls(Map<String, Object>? map) {
    if (map == null) return null;
    final Map<String, Object> result = {};
    map.forEach((key, value) {
      if (value is Map<String, Object>) {
        // Processa mapas aninhados
        final processedMap = deepToStringAndRemoveNulls(value);
        if (processedMap != null && processedMap.isNotEmpty) {
          result[key] = processedMap;
        }
      } else if (value is List) {
        final processedList = _processListItems(value);
        if (processedList.isNotEmpty) {
          result[key] = processedList;
        }
      } else {
        result[key] = value.toString();
      }
    });
    return result.isNotEmpty ? result : null;
  }

  List<Object> _processListItems(List items) {
    final List<Object> result = [];
    for (final item in items) {
      if (item != null) {
        if (item is Map<String, Object>) {
          final processedMap = deepToStringAndRemoveNulls(item);
          if (processedMap != null && processedMap.isNotEmpty) {
            result.add(processedMap);
          }
        } else if (item is List) {
          final processedList = _processListItems(item);
          if (processedList.isNotEmpty) {
            result.add(processedList);
          }
        } else {
          result.add(item.toString());
        }
      }
    }

    return result;
  }

  String get name => formatToSnakeCase(runtimeType.toString());

  String formatToSnakeCase(String value) => value
      .replaceAllMapped(_kCamelCaseRegExp, (match) => '_${match.group(0)}')
      .toLowerCase();

  Future<void> track({required BuildContext context}) async {
    if (kDebugMode) {
      log('track event - ${name} - ${properties}');
    }
    final providerContainer = ProviderScope.containerOf(context);
    return providerContainer.read(analyticsRepositoryProvider).track(this);
  }
}

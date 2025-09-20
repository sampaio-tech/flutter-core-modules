import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/presentation/setup/shared_preferences/provider.dart';
import '../../domain/repositories/locale_repository.dart';

class LocaleRepositoryImpl extends LocaleRepository {
  final SharedPreferences _sharedPreferences;

  const LocaleRepositoryImpl({
    required SharedPreferences sharedPreferences,
  }) : _sharedPreferences = sharedPreferences;

  @override
  Locale? getLocale() =>
      switch (_sharedPreferences.getStringList(DatabaseKeys.locale.key)) {
        null => null,
        [final languageCode, final countryCode] =>
          Locale(languageCode, countryCode),
        [final languageCode] => Locale(languageCode),
        _ => null,
      };

  @override
  Future<bool> setLocale({
    required Locale locale,
  }) {
    final languageCode = locale.languageCode;
    final countryCode = locale.countryCode;
    return _sharedPreferences.setStringList(
      DatabaseKeys.locale.key,
      [
        languageCode,
        if (countryCode != null) countryCode,
      ],
    );
  }

  @override
  Future<bool> removeLocale() =>
      _sharedPreferences.remove(DatabaseKeys.locale.key);
}

enum DatabaseKeys {
  locale;

  String get key => switch (kDebugMode) {
        true => '${name}Debug',
        false => name,
      };
}

final localeRepositoryProvider = Provider.autoDispose<LocaleRepository>(
  (ref) => LocaleRepositoryImpl(
    sharedPreferences: ref.read(sharedPreferencesProvider),
  ),
);

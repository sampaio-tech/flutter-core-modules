import 'dart:ui';

abstract class LocaleRepository {
  const LocaleRepository();

  Locale? getLocale();

  Future<bool> setLocale({required Locale locale});

  Future<bool> removeLocale();
}

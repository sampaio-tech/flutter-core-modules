import 'package:ios_design_system/ios_design_system.dart';

import 'event_entity.dart';

class TapOnDarkModeSettings extends EventEntity {
  final IosThemeData themeData;
  const TapOnDarkModeSettings({required this.themeData});

  @override
  Map<String, Object>? get properties => {
    'enable': themeData is IosDarkThemeData,
    'theme': themeData.runtimeType
        .toString()
        .replaceAll('Ios', '')
        .replaceAll('ThemeData', '')
        .toLowerCase(),
  };
}

class TapOnChangeLanguageSettings extends EventEntity {
  const TapOnChangeLanguageSettings();

  @override
  Map<String, Object>? get properties => const {};
}

class TapOnPreventSleepSettings extends EventEntity {
  final bool enable;
  const TapOnPreventSleepSettings({required this.enable});

  @override
  Map<String, Object>? get properties => {'enable': enable};
}

class TapOnVibrationFeedbackSettings extends EventEntity {
  final bool enable;
  const TapOnVibrationFeedbackSettings({required this.enable});

  @override
  Map<String, Object>? get properties => {'enable': enable};
}

class TapOnCopyToClipboard extends EventEntity {
  final String? label;
  final String? title;
  final String? description;

  const TapOnCopyToClipboard({
    required this.label,
    required this.title,
    required this.description,
  });

  @override
  Map<String, Object>? get properties => {
    if (label != null) 'label': label ?? '',
    if (title != null) 'title': title ?? '',
    if (description != null) 'description': description ?? '',
  };
}

class TapOnOpenLink extends EventEntity {
  final String? label;
  final String? title;
  final String? description;

  const TapOnOpenLink({
    required this.label,
    required this.title,
    required this.description,
  });

  @override
  Map<String, Object>? get properties => {
    if (label != null) 'label': label ?? '',
    if (title != null) 'title': title ?? '',
    if (description != null) 'description': description ?? '',
  };
}

class TapOnReviewButton extends EventEntity {
  const TapOnReviewButton();

  @override
  Map<String, Object>? get properties => {};
}

class TapOnFeedbackButton extends EventEntity {
  const TapOnFeedbackButton();

  @override
  Map<String, Object>? get properties => {};
}

class TapOnGetPremiumButton extends EventEntity {
  const TapOnGetPremiumButton();

  @override
  Map<String, Object>? get properties => {};
}

class TapOnManagePremiumButton extends EventEntity {
  const TapOnManagePremiumButton();

  @override
  Map<String, Object>? get properties => {};
}

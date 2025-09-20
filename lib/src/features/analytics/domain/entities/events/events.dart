import 'dart:ui';

import 'package:purchases_ui_flutter/paywall_result.dart';

import 'event_entity.dart';

class ChangeLanguageTo extends EventEntity {
  final Locale locale;

  const ChangeLanguageTo({required this.locale});

  @override
  Map<String, Object>? get properties => {
    'locale': {
      'languageCode': locale.languageCode,
      if (locale.countryCode != null) 'countryCode': locale.countryCode,
    },
  };
}

class InAppReviewIsAvailable extends EventEntity {
  final bool isAvailable;
  const InAppReviewIsAvailable({required this.isAvailable});

  @override
  Map<String, Object>? get properties => {'isAvailable': isAvailable};
}

class OnHasActiveSubscriptionCallback extends EventEntity {
  final EventEntity? event;
  final bool featureLocked;

  const OnHasActiveSubscriptionCallback({
    required this.event,
    required this.featureLocked,
  });

  @override
  Map<String, Object>? get properties => {
    'featureLocked': featureLocked,
    if (event != null) 'event': event!.name,
  };
}

class OnPresentedPaywallCallback extends EventEntity {
  final EventEntity? event;
  final bool featureLocked;

  const OnPresentedPaywallCallback({
    required this.event,
    required this.featureLocked,
  });

  @override
  Map<String, Object>? get properties => {
    'featureLocked': featureLocked,
    if (event != null) 'event': event!.name,
  };
}

class OnSyncPurchasesCallback extends EventEntity {
  final EventEntity? event;
  final bool featureLocked;
  final PaywallResult paywallResult;

  const OnSyncPurchasesCallback({
    required this.event,
    required this.featureLocked,
    required this.paywallResult,
  });

  @override
  Map<String, Object>? get properties => {
    'featureLocked': featureLocked,
    if (event != null) 'event': event!.name,
    'paywallResult': paywallResult.name.toString(),
  };
}

class OnPresentPaywallResultCallback extends EventEntity {
  final EventEntity? event;
  final bool featureLocked;
  final PaywallResult paywallResult;

  const OnPresentPaywallResultCallback({
    required this.event,
    required this.featureLocked,
    required this.paywallResult,
  });

  @override
  Map<String, Object>? get properties => {
    'featureLocked': featureLocked,
    if (event != null) 'event': event!.name,
    'paywallResult': paywallResult.name.toString(),
  };
}

class InitApp extends EventEntity {
  const InitApp();

  @override
  Map<String, Object>? get properties => {};
}

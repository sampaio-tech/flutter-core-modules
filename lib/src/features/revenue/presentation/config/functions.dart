import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:purchases_ui_flutter/paywall_result.dart';

import '../../../analytics/domain/entities/events/event_entity.dart';
import '../../../analytics/domain/entities/events/events.dart';
import '../notifiers/customer_info/customer_info_state_notifier.dart';

Future<PaywallResult?> presentPaywallForwarded({
  required BuildContext context,
  required EventEntity? event,
  required bool enable,
  required bool featureLocked,
  required void Function()? onTap,
  void Function()? onHasActiveSubscriptionCallback,
  void Function()? onPresentedPaywallCallback,
  void Function(PaywallResult)? onSyncPurchasesCallback,
  void Function(PaywallResult)? onPresentPaywallResultCallback,
}) async {
  final providerContainer = ProviderScope.containerOf(context);
  if (!enable) {
    onTap?.call();
    return null;
  }
  return providerContainer
      .read(customerInfoStateNotifierProvider.notifier)
      .presentPaywall(
        onHasActiveSubscriptionCallback: () {
          OnHasActiveSubscriptionCallback(
            event: event,
            featureLocked: featureLocked,
          ).track(context: context);
          onHasActiveSubscriptionCallback?.call();
          onTap?.call();
        },
        onPresentedPaywallCallback: () {
          OnPresentedPaywallCallback(
            event: event,
            featureLocked: featureLocked,
          ).track(context: context);
          onPresentedPaywallCallback?.call();
        },
        onSyncPurchasesCallback: (paywallResult) {
          OnSyncPurchasesCallback(
            event: event,
            featureLocked: featureLocked,
            paywallResult: paywallResult,
          ).track(context: context);
          onSyncPurchasesCallback?.call(paywallResult);
        },
        onPresentPaywallResultCallback: (paywallResult) {
          OnPresentPaywallResultCallback(
            event: event,
            featureLocked: featureLocked,
            paywallResult: paywallResult,
          ).track(context: context);
          onPresentPaywallResultCallback?.call(paywallResult);
          if (!featureLocked) {
            onTap?.call();
          }
        },
      );
}

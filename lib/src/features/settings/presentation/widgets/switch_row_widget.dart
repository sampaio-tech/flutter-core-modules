import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ios_design_system/ios_design_system.dart';

class SwitchRowWidget extends HookConsumerWidget {
  final ValueNotifier<bool>? state;
  final bool initialData;
  final bool displayDivider;
  final void Function(bool newState)? onPressed;
  final void Function(bool newState)? onChanged;
  final Widget? leftWidget;
  final String title;
  final String? description;

  const SwitchRowWidget({
    required this.state,
    required this.displayDivider,
    required this.initialData,
    required this.leftWidget,
    required this.title,
    required this.description,
    required this.onPressed,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final internalState = state ?? useValueNotifier(initialData);
    return RowWidget(
      divider: DividerWidget.stocks,
      contentPadding:
          const EdgeInsets.symmetric(vertical: 7).copyWith(right: 16),
      leftWidget: leftWidget,
      title: (theme) => Text(
        title,
        style: theme.typography.subheadlineRegular.copyWith(
          color: switch (theme) {
            IosLightThemeData() => theme.defaultLabelColors.primary,
            IosDarkThemeData() => theme.stocksDecorations.defaultColors.primary,
          },
        ),
        textAlign: TextAlign.start,
        overflow: TextOverflow.visible,
      ),
      description: switch (description) {
        null => null,
        final description => (theme) => Text(
              description,
              style: theme.typography.footnoteRegular.copyWith(
                color: switch (theme) {
                  IosLightThemeData() => theme.defaultLabelColors.secondary,
                  IosDarkThemeData() =>
                    theme.stocksDecorations.defaultColors.secondary,
                },
              ),
              textAlign: TextAlign.start,
              overflow: TextOverflow.visible,
            ),
      },
      displayDivider: displayDivider,
      onPressed: () {
        final newState = switch (internalState.value) {
          false => true,
          true => false,
        };
        onPressed?.call(newState);
        WidgetsBinding.instance.addPostFrameCallback(
          (timeStamp) => internalState.value = newState,
        );
      },
      rightWidget: ValueListenableBuilder<bool>(
        valueListenable: internalState,
        builder: (context, internalValue, child) => SwitchWidget.stocks(
          value: internalValue,
          onChanged: (value) {
            onChanged?.call(value);
            WidgetsBinding.instance.addPostFrameCallback(
              (timeStamp) => internalState.value = value,
            );
          },
        ),
      ),
    );
  }
}

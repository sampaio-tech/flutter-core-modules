import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ios_design_system/ios_design_system.dart';

import '../../../../core/presentation/hooks/safe_effect.dart';
import '../../../../core/presentation/widgets/label_row_widget.dart';
import '../../../theme/presentation/notifiers/theme_state_notifier.dart';

class ThemeRowWidget extends HookConsumerWidget {
  final ValueNotifier<IosThemeData>? state;
  final bool displayDivider;
  final void Function(IosThemeData newState)? onPressed;
  final void Function(IosThemeData newState)? onChanged;
  final String label;
  final String? description;

  const ThemeRowWidget({
    required this.state,
    required this.displayDivider,
    required this.label,
    required this.description,
    super.key,
    this.onPressed,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = IosTheme.of(context);
    final internalState = state ?? useValueNotifier(theme);
    useSafeEffect(() {
      void listenInternalState() {
        final iosThemeData = internalState.value;
        WidgetsBinding.instance.addPostFrameCallback(
          (timeStamp) => ref
              .read(themeStateNotifierProvider.notifier)
              .setThemeData(iosThemeData: iosThemeData),
        );
      }

      internalState.addListener(listenInternalState);
      return () {
        internalState.removeListener(listenInternalState);
      };
    }, []);
    return RowWidget(
      divider: DividerWidget.stocks,
      contentPadding: const EdgeInsets.symmetric(
        vertical: 7,
      ).copyWith(right: 16),
      leftWidget: AppIconWidget.icon(iconData: Icons.dark_mode),
      title: (theme) => Text(
        label,
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
        final description => (theme) => DescriptionRegularWidget(
          description: description,
          displayCupertinoActivityIndicator: false,
          colorBuilder: null,
        ),
      },
      displayDivider: displayDivider,
      onPressed: () {
        final newState = switch (internalState.value) {
          IosLightThemeData() => IosDarkThemeData(),
          IosDarkThemeData() => IosLightThemeData(),
        };
        onPressed?.call(newState);
        WidgetsBinding.instance.addPostFrameCallback(
          (timeStamp) => internalState.value = newState,
        );
      },
      rightWidget: ValueListenableBuilder<IosThemeData>(
        valueListenable: internalState,
        builder: (context, internalValue, child) => SwitchWidget.stocks(
          value: switch (internalValue) {
            IosLightThemeData() => false,
            IosDarkThemeData() => true,
          },
          onChanged: (value) {
            final newState = switch (value) {
              false => IosLightThemeData(),
              true => IosDarkThemeData(),
            };
            onChanged?.call(newState);
            WidgetsBinding.instance.addPostFrameCallback(
              (timeStamp) => internalState.value = newState,
            );
          },
        ),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ios_design_system/ios_design_system.dart';

import '../../../../core/presentation/hooks/safe_effect.dart';
import '../../../../core/presentation/widgets/label_cupertino_child_picker_widget.dart';
import '../../../../core/presentation/widgets/label_row_widget.dart';
import '../../../theme/presentation/notifiers/theme_state_notifier.dart';

enum ThemePickerOption {
  light,
  system,
  dark;

  IosThemeData? toThemeData() => switch (this) {
    ThemePickerOption.light => IosLightThemeData(),
    ThemePickerOption.system => null,
    ThemePickerOption.dark => IosDarkThemeData(),
  };
}

class ThemePickerRowWidget extends HookConsumerWidget {
  final String title;
  final String? description;
  final String lightLabel;
  final String systemLabel;
  final String darkLabel;
  final bool displayDivider;
  final Color? iconColor;
  final void Function(ThemePickerOption option)? onChanged;

  const ThemePickerRowWidget({
    required this.title,
    required this.description,
    required this.lightLabel,
    required this.systemLabel,
    required this.darkLabel,
    required this.displayDivider,
    super.key,
    this.iconColor,
    this.onChanged,
  });

  static const _options = [
    ThemePickerOption.light,
    ThemePickerOption.system,
    ThemePickerOption.dark,
  ];

  String _labelFor(ThemePickerOption option) => switch (option) {
    ThemePickerOption.light => lightLabel,
    ThemePickerOption.system => systemLabel,
    ThemePickerOption.dark => darkLabel,
  };

  IconData _iconFor(ThemePickerOption option) => switch (option) {
    ThemePickerOption.light => CupertinoIcons.sun_max,
    ThemePickerOption.system => CupertinoIcons.circle_lefthalf_fill,
    ThemePickerOption.dark => CupertinoIcons.moon,
  };

  ThemePickerOption _optionFromTheme(IosThemeData? themeData) =>
      switch (themeData) {
        IosLightThemeData() => ThemePickerOption.light,
        IosDarkThemeData() => ThemePickerOption.dark,
        null => ThemePickerOption.system,
      };

  void _apply(ThemePickerOption option, WidgetRef ref) {
    switch (option) {
      case ThemePickerOption.light:
        ref
            .read(themeStateNotifierProvider.notifier)
            .setThemeData(iosThemeData: IosLightThemeData());
      case ThemePickerOption.system:
        ref.read(themeStateNotifierProvider.notifier).removeThemeData();
      case ThemePickerOption.dark:
        ref
            .read(themeStateNotifierProvider.notifier)
            .setThemeData(iosThemeData: IosDarkThemeData());
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = IosTheme.of(context);
    final currentTheme = ref.watch(themeStateNotifierProvider);
    final currentOption = _optionFromTheme(currentTheme);
    final selected = useValueNotifier<ThemePickerOption>(currentOption);

    useSafeEffect(() {
      void onSelectionChanged() {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _apply(selected.value, ref),
        );
      }

      selected.addListener(onSelectionChanged);
      return () => selected.removeListener(onSelectionChanged);
    }, []);

    return RowWidget(
      divider: DividerWidget.stocks,
      description: switch (description) {
        null => null,
        final description => (theme) => DescriptionRegularWidget(
              description: description,
              displayCupertinoActivityIndicator: false,
              colorBuilder: null,
            ),
      },
      contentPadding:
          const EdgeInsets.symmetric(vertical: 16.5).copyWith(right: 16),
      leftWidget: AppIconWidget.icon(
        iconData: CupertinoIcons.circle_lefthalf_fill,
      ),
      title: (theme) => Text(
        title,
        style: theme.typography.subheadlineRegular.copyWith(
          color: switch (theme) {
            IosLightThemeData() => theme.defaultLabelColors.primary,
            IosDarkThemeData() =>
              theme.stocksDecorations.defaultColors.primary,
          },
        ),
        textAlign: TextAlign.start,
        overflow: TextOverflow.visible,
      ),
      rightWidget: ValueListenableBuilder<ThemePickerOption>(
        valueListenable: selected,
        builder: (context, value, _) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _iconFor(value),
              size: 16,
              color: switch (theme) {
                IosLightThemeData() => theme.defaultLabelColors.secondary,
                IosDarkThemeData() =>
                  theme.stocksDecorations.defaultColors.secondary,
              },
            ),
            const SizedBox(width: 4),
            Text(
              _labelFor(value),
              style: theme.typography.calloutRegular.copyWith(
                color: switch (theme) {
                  IosLightThemeData() => theme.defaultLabelColors.secondary,
                  IosDarkThemeData() =>
                    theme.stocksDecorations.defaultColors.secondary,
                },
              ),
            ),
            const SizedBox(width: 6),
            IconWidget.transparentBackground(
              iconColorCallback: (t) => t.defaultLabelColors.tertiary,
              iconData: CupertinoIcons.right_chevron,
              iconSize: 18,
            ),
          ],
        ),
      ),
      displayDivider: displayDivider,
      onPressed: () async {
        final initialItem = _options.indexOf(currentOption).clamp(0, 2);
        await CupertinoPickerWidget.show(
          context: context,
          initialItem: initialItem,
          diameterRatio: 10,
          onSelectedItemChanged: (index) {
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => selected.value = _options[index],
            );
          },
          boxConstraints: BoxConstraints.expand(
            height: MediaQuery.sizeOf(context).height / 4,
          ),
          itemExtent: LabelCupertinoChildPickerWidget.itemExtent(context),
          children: _options
              .map(
                (option) => Center(
                  child: LabelCupertinoChildPickerWidget(
                    label: _labelFor(option),
                    iconWidget: Icon(
                      _iconFor(option),
                      size: 20,
                      color: iconColor,
                    ),
                  ),
                ),
              )
              .toList(),
        );
        onChanged?.call(selected.value);
      },
    );
  }
}

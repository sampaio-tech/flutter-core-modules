import 'package:flutter/cupertino.dart';
import 'package:ios_design_system/ios_design_system.dart';

class LabelCupertinoChildPickerWidget extends StatelessWidget {
  final String label;
  final Widget? iconWidget;
  final double spacing;

  const LabelCupertinoChildPickerWidget({
    required this.label,
    Key? key,
    this.iconWidget,
    this.spacing = 3,
  }) : super(key: key);

  static double itemExtent(BuildContext context) =>
      MediaQuery.textScalerOf(context).scale(_kItemExtent);

  static const _kItemExtent = 44.0;

  @override
  Widget build(BuildContext context) {
    final theme = IosTheme.of(context);
    final typographyColor = theme.defaultLabelColors.primary;
    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          label,
          style: theme.typography.calloutBold.copyWith(color: typographyColor),
          textAlign: TextAlign.center,
          overflow: TextOverflow.visible,
        ),
        if (iconWidget != null) iconWidget ?? const SizedBox.shrink(),
      ],
    );
  }
}

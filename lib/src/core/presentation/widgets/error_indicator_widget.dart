import 'package:flutter/cupertino.dart';
import 'package:ios_design_system/ios_design_system.dart';

class ErrorIndicatorWidget extends StatelessWidget {
  final Future<void> Function()? retryCallback;
  final String retryLabel;
  final String label;
  final Axis axis;
  final Widget? iconWidget;

  const ErrorIndicatorWidget({
    required this.retryCallback,
    required this.retryLabel,
    required this.label,
    required this.iconWidget,
    required this.axis,
    Key? key,
  }) : super(key: key);

  Color iconColorCallback(IosThemeData theme) => theme.defaultColors.systemRed;

  @override
  Widget build(BuildContext context) {
    final theme = IosTheme.of(context);
    return switch (axis) {
      Axis.horizontal => CupertinoButtonWidget(
        onPressed: retryCallback,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                label,
                style: theme.typography.bodyRegular.copyWith(
                  color: iconColorCallback(theme),
                ),
                overflow: TextOverflow.visible,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 6),
            iconWidget ??
                IconWidget.transparentBackground(
                  iconData: CupertinoIcons.exclamationmark_circle,
                  iconColorCallback: iconColorCallback,
                  iconSize: 18,
                ),
          ],
        ),
      ),
      Axis.vertical => CupertinoButtonWidget(
        onPressed: retryCallback,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            iconWidget ??
                IconWidget.transparentBackground(
                  iconData: CupertinoIcons.exclamationmark_circle,
                  iconColorCallback: iconColorCallback,
                  iconSize: 48,
                ),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.typography.title3Regular.copyWith(
                color: theme.defaultLabelColors.primary,
              ),
              overflow: TextOverflow.visible,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            if (retryCallback != null)
              IgnorePointer(
                child: ButtonWidget.label(
                  size: const SmallButtonSize(),
                  color: const BlueButtonColor(),
                  label: retryLabel,
                  onPressed: retryCallback,
                ),
              ),
          ],
        ),
      ),
    };
  }
}

class CheckInternetErrorIndicatorWidget extends StatelessWidget {
  final Future<void> Function()? retryCallback;
  final Widget? iconWidget;
  final Axis axis;
  final String label;
  final String retryLabel;

  const CheckInternetErrorIndicatorWidget({
    required this.retryCallback,
    required this.label,
    required this.retryLabel,
    super.key,
    this.axis = Axis.vertical,
    this.iconWidget,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorIndicatorWidget(
      retryCallback: retryCallback,
      retryLabel: retryLabel,

      label: label,
      iconWidget: iconWidget,
      axis: axis,
    );
  }
}

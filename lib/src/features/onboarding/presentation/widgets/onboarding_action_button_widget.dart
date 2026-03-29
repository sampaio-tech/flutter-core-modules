import 'package:flutter/cupertino.dart';
import 'package:ios_design_system/ios_design_system.dart';

class OnboardingActionButtonWidget extends StatelessWidget {
  final String label;
  final Color buttonColor;
  final Color? backgroundColor;
  final Color? buttonTextColor;
  final VoidCallback onPressed;

  const OnboardingActionButtonWidget({
    required this.label,
    required this.buttonColor,
    required this.onPressed,
    this.backgroundColor,
    this.buttonTextColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = IosTheme.of(context);
    final resolvedBackgroundColor = switch (theme) {
      IosLightThemeData() =>
        backgroundColor ?? const Color.fromRGBO(236, 236, 236, 1),
      _ =>
        backgroundColor ??
            theme.defaultSystemBackgroundsColors.secondaryDarkElevated,
    };
    final resolvedButtonTextColor = switch (theme) {
      IosLightThemeData() =>
        buttonTextColor ?? const Color.fromRGBO(28, 28, 30, 1),
      _ =>
        buttonTextColor ?? theme.defaultSystemBackgroundsColors.primaryDarkBase,
    };

    return ColoredBox(
      color: resolvedBackgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const DividerWidget(),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoButton(
                      borderRadius: const BorderRadius.all(Radius.circular(14)),
                      color: buttonColor,
                      onPressed: onPressed,
                      child: Text(
                        label,
                        style: theme.typography.bodyBold.copyWith(
                          color: resolvedButtonTextColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

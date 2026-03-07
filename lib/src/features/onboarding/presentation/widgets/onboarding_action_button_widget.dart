import 'package:flutter/cupertino.dart';
import 'package:ios_design_system/ios_design_system.dart';

class OnboardingActionButtonWidget extends StatelessWidget {
  final String label;
  final Color buttonColor;
  final VoidCallback onPressed;

  const OnboardingActionButtonWidget({
    required this.label,
    required this.buttonColor,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = IosTheme.of(context);
    return ColoredBox(
      color: theme.defaultSystemBackgroundsColors.secondaryDarkElevated,
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
                          color: theme
                              .defaultSystemBackgroundsColors
                              .primaryDarkBase,
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

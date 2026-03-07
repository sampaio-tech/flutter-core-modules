import 'package:flutter/cupertino.dart';
import 'package:ios_design_system/ios_design_system.dart';

class OnboardingFeatureItemWidget extends StatelessWidget {
  final IconData? iconData;
  final String title;
  final String description;
  final Color accentColor;

  const OnboardingFeatureItemWidget({
    required this.title,
    required this.description,
    required this.accentColor,
    this.iconData = CupertinoIcons.checkmark_circle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = IosTheme.of(context);
    final textScaler = MediaQuery.textScalerOf(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (iconData != null)
            Padding(
              padding: const EdgeInsets.only(top: 2, right: 14),
              child: Icon(
                iconData,
                color: accentColor,
                size: textScaler.scale(26),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.typography.bodyBold.copyWith(
                    color: theme.defaultLabelColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.typography.footnoteRegular.copyWith(
                    color: theme.defaultLabelColors.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

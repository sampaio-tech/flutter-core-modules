import 'package:flutter/cupertino.dart';
import 'package:ios_design_system/ios_design_system.dart';

class TitleGroupedTableWidget extends StatelessWidget {
  final String title;
  final bool loadInProgress;
  final bool large;
  final EdgeInsets padding;

  const TitleGroupedTableWidget({
    required this.title,
    this.loadInProgress = false,
    this.large = false,
    this.padding = const EdgeInsets.only(
      left: 16,
      right: 16,
      bottom: 8,
    ),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = IosTheme.of(context);
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Flexible(
            child: Text(
              switch (large) {
                true => title,
                false => title.toUpperCase(),
              },
              textAlign: TextAlign.start,
              overflow: TextOverflow.visible,
              style: switch (theme) {
                IosLightThemeData() => switch (large) {
                    true => theme.typography.calloutBold.copyWith(
                        color: theme.defaultLabelColors.primary,
                      ),
                    false => theme.typography.caption1Regular.copyWith(
                        color: theme.defaultLabelColors.secondary,
                      ),
                  },
                IosDarkThemeData() => switch (large) {
                    true => theme.typography.calloutBold.copyWith(
                        color: theme.defaultLabelColors.primary,
                      ),
                    false => theme.typography.caption1Regular.copyWith(
                        color: theme.defaultLabelColors.secondary,
                      ),
                  },
              },
            ),
          ),
          if (loadInProgress) const SizedBox(width: 4),
          if (loadInProgress) const CupertinoActivityIndicator(radius: 8),
          if (!loadInProgress) const SizedBox(height: 16),
        ],
      ),
    );
  }
}

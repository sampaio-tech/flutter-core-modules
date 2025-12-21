import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ios_design_system/ios_design_system.dart';

import '../../../features/analytics/domain/entities/events/tap_on_events.dart';
import '../../../features/settings/presentation/notifiers/haptic_feedback_state_notifier.dart';
import 'web_view_modal_sheet_widget.dart';

class LabelRowWidget extends HookConsumerWidget {
  final Widget? leftWidget;
  final bool displayDivider;
  final bool displayChevronRight;
  final bool displayCupertinoActivityIndicator;
  final Color? Function(IosThemeData)? titleColorBuilder;
  final void Function({
    required String? label,
    required String? description,
    required String title,
    required String? toastMessage,

    required BuildContext context,
  })?
  onPressed;
  final void Function({
    required String? label,
    required String? description,
    required String title,
    required String? toastMessage,

    required BuildContext context,
  })?
  onLongPress;
  final String title;
  final String? description;
  final String? label;
  final String? toastMessage;

  final Widget Function({
    required String title,
    required Color? Function(IosThemeData theme)? colorBuilder,
    required bool displayCupertinoActivityIndicator,
  })
  titleBuilder;
  final Widget Function({
    required String description,
    required Color? Function(IosThemeData theme)? colorBuilder,
    required bool displayCupertinoActivityIndicator,
  })
  descriptionBuilder;
  final Widget Function({
    required String? label,
    required bool displayChevronRight,
    required bool displayCupertinoActivityIndicator,
  })
  labelBuilder;

  const LabelRowWidget({
    required this.displayDivider,
    required this.title,
    required this.description,
    required this.label,
    required this.toastMessage,
    this.displayChevronRight = false,
    this.displayCupertinoActivityIndicator = false,
    this.labelBuilder = LabelWidget.new,
    this.titleBuilder = TitleRegularWidget.new,
    this.descriptionBuilder = DescriptionRegularWidget.new,
    super.key,
    this.onPressed = copyToClipboard,
    this.onLongPress = copyToClipboard,
    this.titleColorBuilder,
    this.leftWidget,
  });

  factory LabelRowWidget.link({
    required bool displayDivider,
    required String title,
    required String? description,
    required String? label,
    required String toastMessage,
    void Function({
      required String? label,
      required String? description,
      required String title,
      required String? toastMessage,

      required BuildContext context,
    })?
    onPressed,
    void Function({
      required String? label,
      required String? description,
      required String title,
      required String? toastMessage,
      required BuildContext context,
    })?
    onLongPress,
    Widget? leftWidget,
  }) => LabelRowWidget(
    leftWidget: leftWidget,
    displayDivider: displayDivider,
    title: title,
    description: description,
    label: label,
    toastMessage: toastMessage,
    labelBuilder: LinkLabelWidget.new,
    descriptionBuilder: DescriptionLinkWidget.new,
    onPressed: onPressed ?? openLink,
    onLongPress: onLongPress ?? copyToClipboard,
  );

  factory LabelRowWidget.button({
    required bool displayDivider,
    required String title,
    required String? description,
    required String? label,
    required void Function({
      required String? label,
      required String? description,
      required String title,
      required String? toastMessage,
      required BuildContext context,
    })?
    onPressed,
    required void Function({
      required String? label,
      required String? description,
      required String title,
      required String? toastMessage,
      required BuildContext context,
    })?
    onLongPress,
    String? toastMessage,
    Widget? leftWidget,
    bool displayChevronRight = true,
    bool displayCupertinoActivityIndicator = false,
  }) => LabelRowWidget(
    leftWidget: leftWidget,
    displayChevronRight: displayChevronRight,
    displayCupertinoActivityIndicator: displayCupertinoActivityIndicator,
    displayDivider: displayDivider,
    title: title,
    description: description,
    label: label,
    toastMessage: toastMessage,
    onPressed: onPressed,
    onLongPress: onLongPress,
  );

  factory LabelRowWidget.blueButton({
    required bool displayDivider,
    required String title,
    required String? description,
    required String? label,
    required void Function({
      required String? label,
      required String? description,
      required String title,
      required String? toastMessage,

      required BuildContext context,
    })?
    onPressed,
    required void Function({
      required String? label,
      required String? description,
      required String title,
      required String? toastMessage,

      required BuildContext context,
    })?
    onLongPress,
    String? toastMessage,
    Widget? leftWidget,
    bool displayChevronRight = false,
    bool displayCupertinoActivityIndicator = false,
  }) => LabelRowWidget(
    leftWidget: leftWidget,
    displayChevronRight: displayChevronRight,
    displayCupertinoActivityIndicator: displayCupertinoActivityIndicator,
    displayDivider: displayDivider,
    title: title,
    description: description,
    label: label,
    toastMessage: toastMessage,
    onPressed: onPressed,
    onLongPress: onLongPress,
    titleColorBuilder: (theme) => theme.defaultColors.systemBlue,
  );

  factory LabelRowWidget.orangeButton({
    required bool displayDivider,
    required String title,
    required String? description,
    required String? label,
    required void Function({
      required String? label,
      required String? description,
      required String title,
      required String? toastMessage,

      required BuildContext context,
    })?
    onPressed,
    required void Function({
      required String? label,
      required String? description,
      required String title,
      required String? toastMessage,

      required BuildContext context,
    })?
    onLongPress,
    String? toastMessage,
    Widget? leftWidget,
    bool displayChevronRight = false,
    bool displayCupertinoActivityIndicator = false,
  }) => LabelRowWidget(
    leftWidget: leftWidget,
    displayChevronRight: displayChevronRight,
    displayCupertinoActivityIndicator: displayCupertinoActivityIndicator,
    displayDivider: displayDivider,
    title: title,
    description: description,
    label: label,
    toastMessage: toastMessage,
    onPressed: onPressed,
    onLongPress: onLongPress,
    titleColorBuilder: (theme) => theme.defaultColors.systemOrange,
  );

  factory LabelRowWidget.redButton({
    required bool displayDivider,
    required String title,
    required String? description,
    required String? label,
    required void Function({
      required String? label,
      required String? description,
      required String title,
      required String? toastMessage,
      required BuildContext context,
    })?
    onPressed,
    required void Function({
      required String? label,
      required String? description,
      required String title,
      required String? toastMessage,
      required BuildContext context,
    })?
    onLongPress,
    String? toastMessage,

    bool displayChevronRight = false,
    Widget? leftWidget,
    bool displayCupertinoActivityIndicator = false,
  }) => LabelRowWidget(
    leftWidget: leftWidget,
    displayChevronRight: displayChevronRight,
    displayCupertinoActivityIndicator: displayCupertinoActivityIndicator,
    displayDivider: displayDivider,
    title: title,
    description: description,
    label: label,
    toastMessage: toastMessage,
    onPressed: onPressed,
    onLongPress: onLongPress,
    titleColorBuilder: (theme) => theme.defaultColors.systemRed,
  );

  static Future<void> copyToClipboard({
    required String? label,
    required String? description,
    required String title,
    required String? toastMessage,
    required BuildContext context,
  }) async {
    final value = description ?? label;
    if (value == null) {
      return;
    }
    final theme = IosTheme.of(context);
    final providerContainer = ProviderScope.containerOf(context);
    final hapticFeedbackState = providerContainer.read(
      hapticFeedbackStateNotifierProvider,
    );
    if (hapticFeedbackState) {
      HapticFeedback.lightImpact();
    }
    TapOnCopyToClipboard(
      label: label,
      description: description,
      title: title,
    ).track(context: context);
    return Clipboard.setData(ClipboardData(text: value)).then((value) {
      if (toastMessage != null) {
        Fluttertoast.showToast(
          // ignore: use_build_context_synchronously
          msg: toastMessage,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          backgroundColor:
              theme.defaultSystemBackgroundsColors.primaryDarkElevated,
          textColor: theme.defaultSystemBackgroundsColors.primaryLight,
          fontSize: 16,
          fontAsset: 'SF',
        );
      }
    });
  }

  static Future<void> openLink({
    required String? label,
    required String? description,
    required String title,
    required BuildContext context,
    required String? toastMessage,
  }) async {
    final link = description ?? label;
    if (link == null) {
      return;
    }
    TapOnOpenLink(
      label: label,
      description: description,
      title: title,
    ).track(context: context);
    final providerContainer = ProviderScope.containerOf(context);
    final hapticFeedbackState = providerContainer.read(
      hapticFeedbackStateNotifierProvider,
    );
    if (hapticFeedbackState) {
      HapticFeedback.lightImpact();
    }
    final theme = IosTheme.of(context);
    return Clipboard.setData(ClipboardData(text: link)).then((value) {
      WebViewModalSheetWidget(url: link, title: title)
      // ignore: use_build_context_synchronously
      .show(context: context);
      if (toastMessage != null) {
        Fluttertoast.showToast(
          // ignore: use_build_context_synchronously
          msg: toastMessage,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          backgroundColor:
              theme.defaultSystemBackgroundsColors.primaryDarkElevated,
          textColor: theme.defaultSystemBackgroundsColors.primaryLight,
          fontSize: 16,
          fontAsset: 'SF',
        );
      }
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RowWidget(
      divider: DividerWidget.stocks,
      description: switch (description) {
        null => null,
        final description => (theme) => descriptionBuilder(
          description: description,
          displayCupertinoActivityIndicator: displayCupertinoActivityIndicator,
          colorBuilder: switch (onPressed == null && onLongPress == null) {
            true => (theme) => theme.defaultLabelColors.tertiary,
            false => null,
          },
        ),
      },
      contentPadding: const EdgeInsets.symmetric(
        vertical: 16.5,
      ).copyWith(right: 16),
      leftWidget: leftWidget,
      rightWidget: switch (label == null) {
        true => labelBuilder(
          label: label,
          displayChevronRight: displayChevronRight,
          displayCupertinoActivityIndicator: displayCupertinoActivityIndicator,
        ),
        false => Expanded(
          child: labelBuilder(
            label: label,
            displayChevronRight: displayChevronRight,
            displayCupertinoActivityIndicator:
                displayCupertinoActivityIndicator,
          ),
        ),
      },
      title: (theme) => titleBuilder(
        title: title,
        colorBuilder: switch (onPressed == null && onLongPress == null) {
          true => (theme) => theme.defaultLabelColors.tertiary,
          false => titleColorBuilder,
        },
        displayCupertinoActivityIndicator: displayCupertinoActivityIndicator,
      ),
      displayDivider: displayDivider,
      onPressed: switch (onPressed) {
        null => null,
        final onPressed => () => onPressed(
          context: context,
          label: label,
          description: description,
          toastMessage: toastMessage,
          title: title,
        ),
      },
      onLongPress: switch (onLongPress) {
        null => null,
        final onLongPress => () => onLongPress(
          context: context,
          label: label,
          description: description,
          toastMessage: toastMessage,
          title: title,
        ),
      },
    );
  }
}

class TitleRegularWidget extends StatelessWidget {
  final String title;
  final bool displayCupertinoActivityIndicator;
  final Color? Function(IosThemeData theme)? colorBuilder;

  const TitleRegularWidget({
    required this.title,
    required this.displayCupertinoActivityIndicator,
    required this.colorBuilder,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = IosTheme.of(context);
    return Text(
      title,
      style: theme.typography.subheadlineRegular.copyWith(
        color: switch (displayCupertinoActivityIndicator) {
          true => theme.defaultLabelColors.tertiary,
          false =>
            colorBuilder?.call(theme) ??
                switch (theme) {
                  IosLightThemeData() => theme.defaultLabelColors.primary,
                  IosDarkThemeData() =>
                    theme.stocksDecorations.defaultColors.primary,
                },
        },
      ),
      textAlign: TextAlign.start,
      overflow: TextOverflow.visible,
    );
  }
}

class TitleBoldWidget extends StatelessWidget {
  final String title;
  final bool displayCupertinoActivityIndicator;
  final Color? Function(IosThemeData theme)? colorBuilder;

  const TitleBoldWidget({
    required this.title,
    required this.displayCupertinoActivityIndicator,
    required this.colorBuilder,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = IosTheme.of(context);
    return Text(
      title,
      style: theme.typography.subheadlineBold.copyWith(
        color: switch (displayCupertinoActivityIndicator) {
          true => theme.defaultLabelColors.tertiary,
          false =>
            colorBuilder?.call(theme) ??
                switch (theme) {
                  IosLightThemeData() => theme.defaultLabelColors.primary,
                  IosDarkThemeData() =>
                    theme.stocksDecorations.defaultColors.primary,
                },
        },
      ),
      textAlign: TextAlign.start,
      overflow: TextOverflow.visible,
    );
  }
}

class DescriptionRegularWidget extends StatelessWidget {
  final String description;
  final bool displayCupertinoActivityIndicator;
  final Color? Function(IosThemeData theme)? colorBuilder;

  const DescriptionRegularWidget({
    required this.description,
    required this.displayCupertinoActivityIndicator,
    required this.colorBuilder,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = IosTheme.of(context);
    return Text(
      description,
      style: theme.typography.footnoteRegular.copyWith(
        color: switch (displayCupertinoActivityIndicator) {
          true => theme.defaultLabelColors.tertiary,
          false =>
            colorBuilder?.call(theme) ??
                switch (theme) {
                  IosLightThemeData() => theme.defaultLabelColors.secondary,
                  IosDarkThemeData() =>
                    theme.stocksDecorations.defaultColors.secondary,
                },
        },
      ),
      textAlign: TextAlign.start,
      overflow: TextOverflow.visible,
    );
  }
}

class DescriptionLinkWidget extends StatelessWidget {
  final String description;
  final bool displayCupertinoActivityIndicator;
  final Color? Function(IosThemeData theme)? colorBuilder;

  const DescriptionLinkWidget({
    required this.description,
    required this.displayCupertinoActivityIndicator,
    required this.colorBuilder,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = IosTheme.of(context);
    return Text(
      description,
      style: theme.typography.footnoteRegular.copyWith(
        color: switch (displayCupertinoActivityIndicator) {
          true => theme.defaultLabelColors.tertiary,
          false => colorBuilder?.call(theme) ?? theme.defaultColors.systemBlue,
        },
      ),
      textAlign: TextAlign.start,
      overflow: TextOverflow.visible,
    );
  }
}

class LabelWidget extends StatelessWidget {
  final String? label;
  final bool displayChevronRight;
  final bool displayCupertinoActivityIndicator;

  const LabelWidget({
    required this.label,
    required this.displayChevronRight,
    required this.displayCupertinoActivityIndicator,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = IosTheme.of(context);
    return Row(
      children: [
        switch (label) {
          null => const SizedBox.shrink(),
          final label => Expanded(
            child: Text(
              label,
              style: theme.typography.footnoteRegular.copyWith(
                color: switch (theme) {
                  IosLightThemeData() => theme.defaultLabelColors.secondary,
                  IosDarkThemeData() =>
                    theme.stocksDecorations.defaultColors.secondary,
                },
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.visible,
              maxLines: 3,
            ),
          ),
        },
        if (displayChevronRight || displayCupertinoActivityIndicator)
          const SizedBox(width: 6),
        if (displayChevronRight && !displayCupertinoActivityIndicator)
          IconWidget.transparentBackground(
            iconColorCallback: (theme) => theme.defaultLabelColors.tertiary,
            iconData: CupertinoIcons.right_chevron,
            iconSize: 18,
          ),
        if (displayCupertinoActivityIndicator)
          const CupertinoActivityIndicator(radius: 9),
      ],
    );
  }
}

class LinkLabelWidget extends StatelessWidget {
  final String? label;
  final bool displayChevronRight;
  final bool displayCupertinoActivityIndicator;

  const LinkLabelWidget({
    required this.label,
    required this.displayChevronRight,
    required this.displayCupertinoActivityIndicator,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = IosTheme.of(context);
    return Row(
      children: [
        switch (label) {
          null => const SizedBox.shrink(),
          final label => Expanded(
            child: Text(
              label,
              style: theme.typography.footnoteRegular.copyWith(
                color: theme.defaultColors.systemBlue,
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
            ),
          ),
        },
        if (displayChevronRight || displayCupertinoActivityIndicator)
          const SizedBox(width: 6),
        if (displayChevronRight && !displayCupertinoActivityIndicator)
          IconWidget.transparentBackground(
            iconColorCallback: (theme) => theme.defaultLabelColors.tertiary,
            iconData: CupertinoIcons.right_chevron,
            iconSize: 18,
          ),
        if (displayCupertinoActivityIndicator)
          const CupertinoActivityIndicator(radius: 9),
      ],
    );
  }
}

class ImageIconWidget extends StatelessWidget {
  final String imageUrl;
  final Size size;
  final BorderRadius borderRadius;
  final bool displayBorder;
  final Duration fadeDuration;

  const ImageIconWidget({
    required this.imageUrl,
    this.displayBorder = true,
    this.size = const Size.square(36),
    this.borderRadius = const BorderRadius.all(Radius.circular(7)),
    this.fadeDuration = const Duration(milliseconds: 300),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const borderSide = BorderSide(
      strokeAlign: BorderSide.strokeAlignCenter,
      color: const Color(0xFFE5E5E5),
      width: .27,
    );
    const border = Border(
      top: borderSide,
      bottom: borderSide,
      left: borderSide,
      right: borderSide,
    );
    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        border: switch (displayBorder) {
          true => border,
          false => null,
        },
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: SizedBox.fromSize(
          size: size,
          child: Stack(
            children: [
              Positioned.fill(child: Container(color: const Color(0xFFE5E5E5))),
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fadeInDuration: fadeDuration,
                  fadeOutDuration: fadeDuration,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

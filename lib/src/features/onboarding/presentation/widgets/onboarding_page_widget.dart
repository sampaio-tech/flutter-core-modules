import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:ios_design_system/ios_design_system.dart';

import 'onboarding_action_button_widget.dart';

class OnboardingPageWidget extends HookWidget {
  final Widget header;
  final List<Widget> features;
  final String buttonLabel;
  final Color accentColor;
  final Color? backgroundColor;
  final Color? bottomSectionColor;
  final Color? buttonTextColor;
  final VoidCallback onPressed;
  final bool showCloseButton;

  const OnboardingPageWidget({
    required this.header,
    required this.features,
    required this.buttonLabel,
    required this.accentColor,
    required this.onPressed,
    this.backgroundColor,
    this.bottomSectionColor,
    this.buttonTextColor,
    this.showCloseButton = true,
    super.key,
  });

  static const headerDuration = Duration(milliseconds: 800);
  static const featuresDuration = Duration(milliseconds: 1200);
  static const buttonDuration = Duration(milliseconds: 600);

  @override
  Widget build(BuildContext context) {
    final canPop = ModalRoute.of(context)?.canPop ?? false;
    final headerController = useAnimationController(duration: headerDuration);
    final featuresController = useAnimationController(
      duration: featuresDuration,
    );
    final buttonController = useAnimationController(duration: buttonDuration);

    final headerFade = useMemoized(
      () => CurvedAnimation(parent: headerController, curve: Curves.easeOut),
      [headerController],
    );
    final headerScale = useMemoized(
      () => Tween<double>(begin: 0.85, end: 1).animate(
        CurvedAnimation(parent: headerController, curve: Curves.easeOutCubic),
      ),
      [headerController],
    );

    final buttonFade = useMemoized(
      () => CurvedAnimation(parent: buttonController, curve: Curves.easeOut),
      [buttonController],
    );
    final buttonSlide = useMemoized(
      () =>
          Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
            CurvedAnimation(
              parent: buttonController,
              curve: Curves.easeOutCubic,
            ),
          ),
      [buttonController],
    );

    final staggeredFeatures = useMemoized(
      () => features
          .mapIndexed(
            (index, feature) => _StaggeredFeatureWidget(
              controller: featuresController,
              index: index,
              totalCount: features.length,
              child: feature,
            ),
          )
          .toList(),
      [featuresController, features],
    );

    useEffect(() {
      Future<void> startAnimations() async {
        if (!context.mounted) return;
        headerController.forward();
        await Future<void>.delayed(const Duration(milliseconds: 400));
        if (!context.mounted) return;
        featuresController.forward();
        await Future<void>.delayed(
          Duration(
            milliseconds: (featuresDuration.inMilliseconds * 0.4).round(),
          ),
        );
        if (!context.mounted) return;
        buttonController.forward();
      }

      startAnimations();
      return null;
    }, const []);

    final theme = IosTheme.of(context);
    final resolvedBackgroundColor = switch (theme) {
      IosLightThemeData() =>
        backgroundColor ?? const Color.fromRGBO(245, 245, 245, 1),
      _ =>
        backgroundColor ??
            theme.defaultSystemBackgroundsColors.secondaryDarkBase,
    };
    final resolvedBottomSectionColor = switch (theme) {
      IosLightThemeData() =>
        bottomSectionColor ?? const Color.fromRGBO(236, 236, 236, 1),
      _ =>
        bottomSectionColor ??
            theme.defaultSystemBackgroundsColors.secondaryDarkElevated,
    };

    return ColoredBox(
      color: resolvedBackgroundColor,
      child: Column(
        children: [
          Expanded(
            child: CupertinoScrollbar(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverSafeArea(
                    bottom: false,
                    sliver: SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      sliver: SliverList.list(
                        children: [
                          if (canPop && showCloseButton)
                            Align(
                              alignment: Alignment.topRight,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  top: 8,
                                  right: 8,
                                ),
                                child: CloseButtonWidget(
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                              ),
                            ),
                          FadeTransition(
                            opacity: headerFade,
                            child: ScaleTransition(
                              scale: headerScale,
                              child: header,
                            ),
                          ),
                          ...staggeredFeatures,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SlideTransition(
            position: buttonSlide,
            child: FadeTransition(
              opacity: buttonFade,
              child: OnboardingActionButtonWidget(
                label: buttonLabel,
                buttonColor: accentColor,
                backgroundColor: resolvedBottomSectionColor,
                buttonTextColor: buttonTextColor,
                onPressed: onPressed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StaggeredFeatureWidget extends StatelessWidget {
  final AnimationController controller;
  final int index;
  final int totalCount;
  final Widget child;

  const _StaggeredFeatureWidget({
    required this.controller,
    required this.index,
    required this.totalCount,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final start = index / (totalCount + 1);
    final end = (index + 2) / (totalCount + 1);

    final fade = CurvedAnimation(
      parent: controller,
      curve: Interval(start, end.clamp(0, 1), curve: Curves.easeOut),
    );

    final slide = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(start, end.clamp(0, 1), curve: Curves.easeOutCubic),
          ),
        );

    return SlideTransition(
      position: slide,
      child: FadeTransition(opacity: fade, child: child),
    );
  }
}

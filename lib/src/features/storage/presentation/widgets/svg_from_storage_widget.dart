import 'package:cached_network_svg_image/cached_network_svg_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/presentation/hooks/safe_effect.dart';
import '../../../../core/presentation/notifiers/state.dart';
import '../notifiers/get_download_url_state_notifier.dart';

class SvgFromStorageWidget extends HookConsumerWidget {
  final String path;
  final DateTime? invalidateCacheBefore;
  final Duration? invalidateCacheDuration;
  final BoxFit fit;
  final Alignment alignment;
  final Color? color;
  final double? width;
  final double? height;
  final bool enableSvgCache;
  final Widget? progressIndicatorWidget;
  final Widget? errorWidget;

  const SvgFromStorageWidget({
    required this.path,
    super.key,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.color,
    this.width,
    this.height,
    this.invalidateCacheBefore,
    this.invalidateCacheDuration,
    this.enableSvgCache = true,
    this.progressIndicatorWidget,
    this.errorWidget,
  });

  factory SvgFromStorageWidget.fromStoragePath({
    required String path,
    BoxFit fit = BoxFit.contain,
    Alignment alignment = Alignment.center,
    Color? color,
    double? width,
    double? height,
    DateTime? invalidateCacheBefore,
    Duration? invalidateCacheDuration,
    bool enableSvgCache = true,
    Widget? progressIndicatorWidget,
    Widget? errorWidget,
  }) => SvgFromStorageWidget(
    path: path,
    fit: fit,
    alignment: alignment,
    color: color,
    width: width,
    height: height,
    enableSvgCache: enableSvgCache,
    invalidateCacheBefore: invalidateCacheBefore,
    invalidateCacheDuration: invalidateCacheDuration,
    progressIndicatorWidget: progressIndicatorWidget,
    errorWidget: errorWidget,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final familyArgs = useMemoized(
      () => GetDownloadUrlFamilyArgs(
        path: path,
        invalidateCacheBefore: invalidateCacheBefore,
        invalidateCacheDuration: invalidateCacheDuration,
      ),
      [path, invalidateCacheBefore, invalidateCacheDuration],
    );

    final state = ref.watch(
      getDownloadUrlStateNotifierProvider.call(familyArgs),
    );
    useSafeEffect(() {
      ref
          .read(getDownloadUrlStateNotifierProvider.call(familyArgs).notifier)
          .lazyGet();
      return () {};
    }, [familyArgs]);
    return SizedBox(
      width: width,
      height: height,
      child: switch (state) {
        LoadFailureState() => errorWidget,
        LoadSuccessState(value: final String src) => switch (enableSvgCache) {
          true => CachedNetworkSVGImage(
            src,
            width: width,
            height: height,
            fit: fit,
            alignment: alignment,
            colorFilter: switch (color) {
              null => null,
              final color => ColorFilter.mode(color, BlendMode.srcIn),
            },
            errorWidget: errorWidget,
            placeholder: progressIndicatorWidget,
          ),
          false => SvgPicture.network(
            src,
            width: width,
            height: height,
            fit: fit,
            alignment: alignment,
            colorFilter: switch (color) {
              null => null,
              final color => ColorFilter.mode(color, BlendMode.srcIn),
            },
            errorBuilder: (context, error, stackTrace) =>
                errorWidget ?? const SizedBox.shrink(),
            placeholderBuilder: (context) =>
                progressIndicatorWidget ?? const SizedBox.shrink(),
          ),
        },
        _ => progressIndicatorWidget,
      },
    );
  }
}

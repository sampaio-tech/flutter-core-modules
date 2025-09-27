import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/presentation/hooks/safe_effect.dart';
import '../../../../core/presentation/notifiers/state.dart';
import '../notifiers/get_download_url_state_notifier.dart';

class ImageNetworkFromStorageWidget extends HookConsumerWidget {
  final String path;
  final DateTime? invalidateCacheBefore;
  final Duration? invalidateCacheDuration;
  final BoxFit fit;
  final Alignment alignment;
  final Color? color;
  final double? width;
  final double? height;
  final bool enableImageCache;
  final Widget? progressIndicatorWidget;
  final Widget? errorWidget;

  const ImageNetworkFromStorageWidget({
    required this.path,
    super.key,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.color,
    this.width,
    this.height,
    this.invalidateCacheBefore,
    this.invalidateCacheDuration,
    this.enableImageCache = true,
    this.progressIndicatorWidget,
    this.errorWidget,
  });

  factory ImageNetworkFromStorageWidget.fromPath({
    required String path,
    BoxFit fit = BoxFit.cover,
    Alignment alignment = Alignment.center,
    Color? color,
    double? width,
    double? height,
    DateTime? invalidateCacheBefore,
    Duration? invalidateCacheDuration,
    bool enableImageCache = true,
    Widget? progressIndicatorWidget,
    Widget? errorWidget,
  }) => ImageNetworkFromStorageWidget(
    path: path,
    fit: fit,
    alignment: alignment,
    color: color,
    width: width,
    height: height,
    invalidateCacheBefore: invalidateCacheBefore,
    invalidateCacheDuration: invalidateCacheDuration,
    enableImageCache: enableImageCache,
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
        LoadSuccessState(value: final String src) => switch (enableImageCache) {
          true => CachedNetworkImage(
            imageUrl: src,
            width: width,
            height: height,
            fit: fit,
            alignment: alignment,
            color: color,
            progressIndicatorBuilder: (context, url, progress) =>
                progressIndicatorWidget ?? const SizedBox.shrink(),
            errorWidget: (context, url, error) =>
                errorWidget ?? const SizedBox.shrink(),
          ),
          false => Image.network(
            src,
            width: width,
            height: height,
            fit: fit,
            alignment: alignment,
            color: color,
            errorBuilder: (context, url, error) =>
                errorWidget ?? const SizedBox.shrink(),
            loadingBuilder: (context, url, progress) =>
                progressIndicatorWidget ?? const SizedBox.shrink(),
          ),
        },
        _ => progressIndicatorWidget,
      },
    );
  }
}

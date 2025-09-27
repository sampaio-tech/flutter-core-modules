import 'package:flutter/cupertino.dart' hide State;
import 'package:hooks_riverpod/legacy.dart';

import '../../../../../flutter_core_modules.dart';

class GetDownloadUrlStateNotifier
    extends GetStateNotifier<StorageFailure, String> {
  final String path;
  final DateTime? invalidateCacheBefore;
  final Duration? invalidateCacheDuration;
  final GetDownloadUrlUsecase _getDownloadUrlUsecase;

  GetDownloadUrlStateNotifier({
    required this.path,
    required this.invalidateCacheBefore,
    required this.invalidateCacheDuration,
    required GetDownloadUrlUsecase getDownloadURLUsecase,
  }) : _getDownloadUrlUsecase = getDownloadURLUsecase;

  @override
  Future<Either<StorageFailure, String>> forwardedGet() =>
      _getDownloadUrlUsecase(
        path: path,
        invalidateCacheBefore: invalidateCacheBefore,
        invalidateCacheDuration: invalidateCacheDuration,
      );
}

class GetDownloadUrlFamilyArgs {
  final String path;
  final DateTime? invalidateCacheBefore;
  final Duration? invalidateCacheDuration;

  const GetDownloadUrlFamilyArgs({
    required this.path,
    this.invalidateCacheBefore,
    this.invalidateCacheDuration,
  });
}

final getDownloadUrlStateNotifierProvider = StateNotifierProvider.autoDispose
    .family<
      GetDownloadUrlStateNotifier,
      State<StorageFailure, String>,
      GetDownloadUrlFamilyArgs
    >((ref, args) {
      final notifier = GetDownloadUrlStateNotifier(
        path: args.path,
        invalidateCacheBefore: args.invalidateCacheBefore,
        invalidateCacheDuration: args.invalidateCacheDuration,
        getDownloadURLUsecase: ref.read(getDownloadUrlUsecaseProvider),
      );
      WidgetsBinding.instance.addPostFrameCallback(
        (timeStamp) => notifier.lazyGet(),
      );
      return notifier;
    });

import 'package:flutter/cupertino.dart' hide State;
import 'package:hooks_riverpod/legacy.dart';

import '../../../../../flutter_core_modules.dart';

class GetJsonStateNotifier extends GetStateNotifier<StorageFailure, dynamic> {
  final String path;
  final DateTime? invalidateCacheBefore;
  final Duration? invalidateCacheDuration;
  final GetJsonUsecase _getJsonUsecase;

  GetJsonStateNotifier({
    required this.path,
    required this.invalidateCacheBefore,
    required this.invalidateCacheDuration,
    required GetJsonUsecase getJsonUsecase,
  }) : _getJsonUsecase = getJsonUsecase;

  @override
  Future<Either<StorageFailure, dynamic>> forwardedGet() => _getJsonUsecase(
    path: path,
    invalidateCacheBefore: invalidateCacheBefore,
    invalidateCacheDuration: invalidateCacheDuration,
  );
}

class GetJsonFamilyArgs {
  final String path;
  final DateTime? invalidateCacheBefore;
  final Duration? invalidateCacheDuration;

  const GetJsonFamilyArgs({
    required this.path,
    this.invalidateCacheBefore,
    this.invalidateCacheDuration,
  });
}

final getJsonStateNotifierProvider = StateNotifierProvider.autoDispose
    .family<
      GetJsonStateNotifier,
      State<StorageFailure, dynamic>,
      GetJsonFamilyArgs
    >((ref, args) {
      final notifier = GetJsonStateNotifier(
        path: args.path,
        invalidateCacheBefore: args.invalidateCacheBefore,
        invalidateCacheDuration: args.invalidateCacheDuration,
        getJsonUsecase: ref.read(getJsonUsecaseProvider),
      );
      WidgetsBinding.instance.addPostFrameCallback(
        (timeStamp) => notifier.lazyGet(),
      );
      return notifier;
    });

import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/legacy.dart';

import '../../../../core/domain/usecases/get_bool_usecase.dart';
import '../../../../core/domain/usecases/remove_cache_usecase.dart';
import '../../../../core/domain/usecases/set_bool_usecase.dart';
import '../../../../core/presentation/notifiers/cache_bool_state_notifier.dart';

const _key = 'hapticFeedback';
const kDefaultHapticFeedback = true;

String hapticFeedbackKey() => switch (kDebugMode) {
  true => '${_key}Debug',
  false => _key,
};

class HapticFeedbackStateNotifier extends CacheBoolStateNotifier {
  HapticFeedbackStateNotifier({
    required super.getBoolUsecase,
    required super.setBoolUsecase,
    required super.removeCacheUsecase,
    super.initialData = kDefaultHapticFeedback,
  }) : super(key: hapticFeedbackKey());
}

final hapticFeedbackStateNotifierProvider =
    StateNotifierProvider<HapticFeedbackStateNotifier, bool>(
      (ref) => HapticFeedbackStateNotifier(
        getBoolUsecase: ref.read(getBoolUsecaseProvider),
        setBoolUsecase: ref.read(setBoolUsecaseProvider),
        removeCacheUsecase: ref.read(removeCacheUsecaseProvider),
      ),
    );

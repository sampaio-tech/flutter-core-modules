import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/legacy.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../../core/domain/usecases/get_bool_usecase.dart';
import '../../../../core/domain/usecases/remove_cache_usecase.dart';
import '../../../../core/domain/usecases/set_bool_usecase.dart';
import '../../../../core/presentation/notifiers/cache_bool_state_notifier.dart';

const _key = 'wakelock';
const kDefaultWakelock = true;

String wakelockKey() => switch (kDebugMode) {
  true => '${_key}Debug',
  false => _key,
};

class WakelockStateNotifier extends CacheBoolStateNotifier {
  WakelockStateNotifier({
    required super.getBoolUsecase,
    required super.setBoolUsecase,
    required super.removeCacheUsecase,
    super.initialData = kDefaultWakelock,
  }) : super(key: wakelockKey()) {
    _setWakelock(enable: state);
  }

  Future<void> _setWakelock({required bool enable}) =>
      WakelockPlus.toggle(enable: enable);
}

final wakelockStateNotifierProvider =
    StateNotifierProvider<WakelockStateNotifier, bool>(
      (ref) => WakelockStateNotifier(
        getBoolUsecase: ref.read(getBoolUsecaseProvider),
        setBoolUsecase: ref.read(setBoolUsecaseProvider),
        removeCacheUsecase: ref.read(removeCacheUsecaseProvider),
      ),
    );

import '../../domain/usecases/get_bool_usecase.dart';
import '../../domain/usecases/remove_cache_usecase.dart';
import '../../domain/usecases/set_bool_usecase.dart';
import 'safe_state_notifier.dart';

abstract class CacheBoolStateNotifier extends SafeStateNotifier<bool> {
  CacheBoolStateNotifier({
    required bool initialData,
    required String key,
    required GetBoolUsecase getBoolUsecase,
    required SetBoolUsecase setBoolUsecase,
    required RemoveCacheUsecase removeCacheUsecase,
  })  : _key = key,
        _getBoolUsecase = getBoolUsecase,
        _setBoolUsecase = setBoolUsecase,
        _removeCacheUsecase = removeCacheUsecase,
        super(getBoolUsecase(key: key) ?? initialData);
  final String _key;
  final GetBoolUsecase _getBoolUsecase;
  final SetBoolUsecase _setBoolUsecase;
  final RemoveCacheUsecase _removeCacheUsecase;

  bool? get() {
    final value = _getBoolUsecase(key: _key);
    if (value != null) {
      state = value;
    }
    return value;
  }

  Future<bool> set({
    required bool value,
  }) async {
    final settedUp = await _setBoolUsecase(
      key: _key,
      value: value,
    );
    state = value;
    return settedUp;
  }

  Future<bool> remove() => _removeCacheUsecase(key: _key);
}

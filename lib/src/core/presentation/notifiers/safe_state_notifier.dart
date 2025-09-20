import 'package:hooks_riverpod/legacy.dart';

/// Used to avoid change state after dispose
class SafeStateNotifier<T> extends StateNotifier<T> {
  SafeStateNotifier(super.state);

  @override
  set state(T value) {
    if (mounted) {
      super.state = value;
    }
  }
}

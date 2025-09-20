import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class Debounce {
  final Duration duration;
  Timer? _timer;

  Debounce(this.duration);

  void run(VoidCallback call) {
    if (_timer != null) _timer?.cancel();
    _timer = Timer(duration, call);
  }

  void dispose() {
    _timer?.cancel();
  }
}

ValueChanged<VoidCallback> useDebounce(Duration duration) {
  final debounce = useMemoized(() => Debounce(duration), [duration]);
  useEffect(() => debounce.dispose, [duration]);
  return debounce.run;
}

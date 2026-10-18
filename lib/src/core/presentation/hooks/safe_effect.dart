import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Run effect after first frame
void useSafeEffect(Dispose? Function() effect, [List<Object?>? keys]) {
  useEffect(() {
    var mounted = true;
    Dispose? dispose;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        dispose = effect();
      }
    });
    return () {
      mounted = false;
      dispose?.call();
    };
  }, keys);
}

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Run effect after first frame
void useSafeEffect(Dispose? Function() effect, [List<Object?>? keys]) {
  useEffect(() {
    Dispose? dispose;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      dispose = effect();
    });
    return dispose;
  }, keys);
}

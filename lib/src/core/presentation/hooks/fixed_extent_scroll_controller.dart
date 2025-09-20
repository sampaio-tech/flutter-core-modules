import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

FixedExtentScrollController useFixedExtentScrollController({
  int initialItem = 0,
}) =>
    use<FixedExtentScrollController>(
      _FixedExtentScrollController(initialItem: initialItem),
    );

class _FixedExtentScrollController extends Hook<FixedExtentScrollController> {
  final int initialItem;
  const _FixedExtentScrollController({required this.initialItem});

  @override
  HookState<FixedExtentScrollController, Hook<FixedExtentScrollController>>
      createState() => _FixedExtentScrollControllerHookState();
}

class _FixedExtentScrollControllerHookState extends HookState<
    FixedExtentScrollController, _FixedExtentScrollController> {
  late final controller = FixedExtentScrollController(
    initialItem: hook.initialItem,
  );

  @override
  FixedExtentScrollController build(BuildContext context) => controller;

  @override
  void dispose() => controller.dispose();

  @override
  String get debugLabel => 'fixedExtentScrollController';
}

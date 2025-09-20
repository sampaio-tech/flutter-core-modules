import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hooks_riverpod/legacy.dart';

import '../../../../core/presentation/notifiers/cache_bool_state_notifier.dart';
import 'switch_row_widget.dart';

class CacheBoolRowWidget extends HookConsumerWidget {
  const CacheBoolRowWidget({
    required this.stateNotifierProvider,
    required this.displayDivider,
    required this.leftWidget,
    required this.title,
    required this.description,
    required this.onPressed,
    required this.onChanged,
    super.key,
  });

  final StateNotifierProvider<CacheBoolStateNotifier, bool>
  stateNotifierProvider;
  final bool displayDivider;
  final void Function(bool newState)? onPressed;
  final void Function(bool newState)? onChanged;
  final Widget? leftWidget;
  final String title;
  final String? description;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(stateNotifierProvider.notifier);
    final state = useValueNotifier<bool>(ref.read(stateNotifierProvider));
    return Consumer(
      child: SwitchRowWidget(
        state: state,
        displayDivider: displayDivider,
        initialData: state.value,
        leftWidget: leftWidget,
        title: title,
        description: description,
        onPressed: (value) {
          notifier.set(value: value);
          onPressed?.call(value);
        },
        onChanged: (value) {
          notifier.set(value: value);
          onChanged?.call(value);
        },
      ),
      builder: (context, ref, child) {
        ref.watch(stateNotifierProvider);
        return child ?? const SizedBox.shrink();
      },
    );
  }
}

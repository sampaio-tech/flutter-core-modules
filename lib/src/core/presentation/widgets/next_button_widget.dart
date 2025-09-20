import 'package:flutter/material.dart';
import 'package:ios_design_system/ios_design_system.dart';

class NextButtonWidget extends StatelessWidget {
  final void Function()? onPressed;
  final String label;

  const NextButtonWidget({required this.label, super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ButtonWidget.label(
      size: const LargeButtonSize(),
      color: const BlueButtonColor(),
      onPressed: onPressed,
      label: label,
    );
  }
}

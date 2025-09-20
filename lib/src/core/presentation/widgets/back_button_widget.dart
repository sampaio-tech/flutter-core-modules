import 'package:flutter/cupertino.dart';
import 'package:ios_design_system/ios_design_system.dart';

class BackButtonWidget extends StatelessWidget {
  final String label;

  const BackButtonWidget({required this.label, super.key});

  @override
  Widget build(BuildContext context) =>
      CupertinoNavigationBackButtonWidget(label: label);
}

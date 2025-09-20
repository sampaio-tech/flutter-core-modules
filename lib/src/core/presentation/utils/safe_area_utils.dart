import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:ios_design_system/ios_design_system.dart';
import 'package:sizer/sizer.dart';

EdgeInsets modalBottomSheetSafeArea(BuildContext context) {
  final safeArea = CupertinoSheetWidget.safeArea(context);
  final bottom =
      safeArea.bottom +
      switch (Device.screenType == ScreenType.tablet || Platform.isAndroid) {
        true => 100,
        false => 20,
      };
  return EdgeInsets.only(
    top: safeArea.top,
    left: safeArea.left,
    right: safeArea.right,
    bottom: bottom,
  );
}

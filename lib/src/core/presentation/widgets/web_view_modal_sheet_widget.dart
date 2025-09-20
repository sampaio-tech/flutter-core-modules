import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:ios_design_system/ios_design_system.dart';
import 'package:webview_all/webview_all.dart';

class WebViewModalSheetWidget extends HookWidget {
  final String url;
  final String title;
  const WebViewModalSheetWidget({
    required this.url,
    required this.title,
    super.key,
  });

  Future<T?> show<T>({
    required BuildContext context,
    Widget? leading,
    Widget? separator = DividerWidget.applePay,
  }) =>
      CupertinoSheetWidget.showCupertinoModalSheet<T>(
        context: context,
        title: TitleSheetWidget.applePay02(
          title: title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          separator: separator,
          leading: leading,
        ),
        children: (context) => [this],
        colorCallback: applePlayBackgroundColorCallback01,
        semanticsDismissible: true,
      );

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Webview(url: url));
  }
}

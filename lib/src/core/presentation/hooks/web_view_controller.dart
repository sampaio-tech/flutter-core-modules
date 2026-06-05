import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:webview_all/webview_all.dart';

WebViewController useWebViewController({
  required String url,
  JavaScriptMode javaScriptMode = JavaScriptMode.unrestricted,
  NavigationDelegate? navigationDelegate,
  List<Object?>? keys,
}) =>
    use(
      _WebViewControllerHook(
        url: url,
        javaScriptMode: javaScriptMode,
        navigationDelegate: navigationDelegate,
        keys: keys,
      ),
    );

class _WebViewControllerHook extends Hook<WebViewController> {
  final String url;
  final JavaScriptMode javaScriptMode;
  final NavigationDelegate? navigationDelegate;

  const _WebViewControllerHook({
    required this.url,
    required this.javaScriptMode,
    this.navigationDelegate,
    List<Object?>? keys,
  }) : super(keys: keys);

  @override
  HookState<WebViewController, Hook<WebViewController>> createState() =>
      _WebViewControllerHookState();
}

class _WebViewControllerHookState
    extends HookState<WebViewController, _WebViewControllerHook> {
  late final WebViewController controller;

  @override
  void initHook() {
    controller = WebViewController();
    if (!kIsWeb) {
      controller.setJavaScriptMode(hook.javaScriptMode);
      if (hook.navigationDelegate != null) {
        controller.setNavigationDelegate(hook.navigationDelegate!);
      }
    }
    controller.loadRequest(Uri.parse(hook.url));
  }

  @override
  WebViewController build(BuildContext context) => controller;

  @override
  String get debugLabel => 'useWebViewController';
}

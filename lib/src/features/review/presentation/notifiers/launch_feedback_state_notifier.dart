import 'package:hooks_riverpod/legacy.dart';

import '../../../../core/presentation/notifiers/safe_state_notifier.dart';
import '../config/launch_url.dart';

class LaunchFeedbackStateNotifier extends SafeStateNotifier<bool> {
  LaunchFeedbackStateNotifier() : super(false);

  Future<bool> canLaunch({
    required String appName,
    String? emailAddress,
  }) async {
    final canLaunch = await canLaunchFeedback(
      appName: appName,
      emailAddress: emailAddress,
    );
    state = canLaunch;
    return canLaunch;
  }

  Future<bool> launch({required String appName, String? emailAddress}) async {
    final allow = await canLaunch(appName: appName, emailAddress: emailAddress);
    if (allow) {
      return launchFeedback(appName: appName, emailAddress: emailAddress);
    }
    return allow;
  }
}

final launchFeedbackStateNotifierProvider =
    StateNotifierProvider<LaunchFeedbackStateNotifier, bool>(
      (ref) => LaunchFeedbackStateNotifier(),
    );

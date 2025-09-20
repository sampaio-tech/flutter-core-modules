import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../analytics/presentation/setup/remote_config/remote_config.dart';

Future<bool> canLaunchFeedback({
  required String appName,
  String? emailAddress,
}) async {
  final packageInfo = await PackageInfo.fromPlatform();
  final email = emailAddress ?? FirebaseRemoteConfigCore.feedbackEmail;
  final subject = generateSubject(appName: appName, packageInfo: packageInfo);
  return canLaunchUrlString('mailto:$email?subject=$subject&body=');
}

Future<bool> launchFeedback({
  required String appName,
  String? emailAddress,
}) async {
  final packageInfo = await PackageInfo.fromPlatform();
  final email = emailAddress ?? FirebaseRemoteConfigCore.feedbackEmail;
  final subject = generateSubject(appName: appName, packageInfo: packageInfo);
  return launchUrlString('mailto:$email?subject=$subject&body=');
}

String generateSubject({
  required String appName,
  required PackageInfo packageInfo,
}) => '$appName | Version ${packageInfo.version}+${packageInfo.buildNumber}';

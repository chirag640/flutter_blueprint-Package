import 'package:flutter_blueprint/src/utils/update_checker.dart';

void main() async {
  print('Testing UpdateChecker...\n');

  final checker = UpdateChecker();

  print('Checking for updates...');
  final updateInfo = await checker.checkForUpdates();

  if (updateInfo != null) {
    print('\n✅ Update available!');
    print('   Current version: ${updateInfo.currentVersion}');
    print('   Latest version:  ${updateInfo.latestVersion}');
  } else {
    print('\n✅ You are using the latest version or check was skipped.');
    print('   Current version: 0.8.4');
  }

  // Test the check again immediately - should return null due to interval
  print('\n\nTesting check interval...');
  final secondCheck = await checker.checkForUpdates();

  if (secondCheck == null) {
    print('✅ Check interval respected - second check returned null');
  } else {
    print('⚠️  Second check returned update info (unexpected)');
  }
}

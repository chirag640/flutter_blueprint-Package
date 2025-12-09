import 'package:flutter_blueprint/src/utils/version_reader.dart';

void main() async {
  print('Testing VersionReader...');
  final version = await VersionReader.getVersion();
  print('Version from pubspec.yaml: $version');
  print('Expected: 1.7.1');
  print('Test ${version == '1.7.1' ? 'PASSED' : 'FAILED'}');
}

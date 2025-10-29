import 'dart:io';

import 'package:path/path.dart' as p;

class IoUtils {
  const IoUtils();

  Future<Directory> prepareTargetDirectory(String targetPath,
      {bool overwrite = false}) async {
    final directory = Directory(targetPath);
    if (await directory.exists()) {
      if (!overwrite && await _isDirectoryPopulated(directory)) {
        throw FileSystemException(
          'Target directory is not empty. Use --force to overwrite.',
          directory.path,
        );
      }
      if (overwrite) {
        await directory.delete(recursive: true);
      }
    }
    return directory.create(recursive: true);
  }

  Future<void> writeFile(
      String rootPath, String relativePath, String content) async {
    final file = File(p.join(rootPath, relativePath));
    await file.parent.create(recursive: true);
    await file.writeAsString('$content\n');
  }

  Future<void> copyTemplateFile(
    String templatePath,
    String targetPath,
  ) async {
    final source = File(templatePath);
    final destination = File(targetPath);
    await destination.parent.create(recursive: true);
    await destination.writeAsString(await source.readAsString());
  }

  Future<bool> _isDirectoryPopulated(Directory directory) async {
    await for (final _ in directory.list()) {
      return true;
    }
    return false;
  }
}

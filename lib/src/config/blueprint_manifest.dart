import 'dart:io';

import 'package:yaml/yaml.dart';

import 'blueprint_config.dart';

/// Wrapper for persisted blueprint metadata stored alongside generated apps.
class BlueprintManifest {
  BlueprintManifest({
    required this.config,
    this.version = currentVersion,
  });

  static const currentVersion = 1;

  final int version;
  final BlueprintConfig config;

  /// Converts this manifest to a map for serialization.
  Map<String, dynamic> toMap() {
    final data = <String, dynamic>{
      'version': version,
    };
    data.addAll(config.toMap());
    return data;
  }

  /// Serializes this manifest to YAML format for writing to `blueprint.yaml`.
  String toYaml() {
    final buffer = StringBuffer();
    void writeEntry(String key, Object? value, int indent) {
      final prefix = '  ' * indent;
      if (value is Map) {
        buffer.writeln('$prefix$key:');
        value.forEach((nestedKey, nestedValue) {
          writeEntry('$nestedKey', nestedValue, indent + 1);
        });
      } else {
        buffer.writeln('$prefix$key: ${_scalar(value)}');
      }
    }

    final map = toMap();
    map.forEach((key, value) {
      writeEntry(key, value, 0);
    });
    return buffer.toString().trimRight();
  }

  /// Parses a blueprint manifest from YAML content.
  ///
  /// Throws [FormatException] if the YAML is malformed.
  static BlueprintManifest fromYaml(String yamlContent) {
    final node = loadYaml(yamlContent);
    if (node is! Map) {
      throw const FormatException('Invalid blueprint.yaml structure');
    }
    final version = (node['version'] ?? currentVersion) as int;
    final config = BlueprintConfig.fromMap(Map<Object?, Object?>.from(node));
    return BlueprintManifest(version: version, config: config);
  }
}

String _scalar(Object? value) {
  if (value == null) {
    return 'null';
  }
  if (value is bool || value is num) {
    return '$value';
  }
  final escaped = value.toString().replaceAll('"', '\\"');
  return '"$escaped"';
}

/// Handles reading and writing blueprint manifests on disk.
class BlueprintManifestStore {
  /// Saves a manifest to the specified file.
  ///
  /// Creates the file if it doesn't exist, overwrites it if it does.
  Future<void> save(File file, BlueprintManifest manifest) async {
    await file.writeAsString('${manifest.toYaml()}\n');
  }

  /// Reads and parses a manifest from the specified file.
  ///
  /// Throws [FileSystemException] if the file doesn't exist.
  Future<BlueprintManifest> read(File file) async {
    if (!await file.exists()) {
      throw FileSystemException('blueprint.yaml not found', file.path);
    }
    final content = await file.readAsString();
    return BlueprintManifest.fromYaml(content);
  }
}

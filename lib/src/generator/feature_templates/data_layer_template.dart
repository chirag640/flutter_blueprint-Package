import '../../generator/feature_generator.dart';
import '../../utils/string_extensions.dart';

/// Generates data layer files (repositories, models, data sources).
class DataLayerTemplate {
  static List<FileTemplate> generate({
    required String featureName,
    required bool includeApi,
  }) {
    final templates = <FileTemplate>[];
    final pascalName = featureName.toPascalCase();

    // Models
    templates.add(FileTemplate(
      relativePath: 'data/models/${featureName}_model.dart',
      content: _modelTemplate(featureName, pascalName),
    ));

    // Data sources
    if (includeApi) {
      templates.add(FileTemplate(
        relativePath: 'data/datasources/${featureName}_remote_data_source.dart',
        content: _remoteDataSourceTemplate(featureName, pascalName),
      ));
    }

    templates.add(FileTemplate(
      relativePath: 'data/datasources/${featureName}_local_data_source.dart',
      content: _localDataSourceTemplate(featureName, pascalName),
    ));

    // Repository implementation
    templates.add(FileTemplate(
      relativePath: 'data/repositories/${featureName}_repository_impl.dart',
      content: _repositoryImplTemplate(featureName, pascalName, includeApi),
    ));

    return templates;
  }

  static String _modelTemplate(String featureName, String pascalName) {
    return '''
import '../../domain/entities/${featureName}_entity.dart';

/// Data model for $pascalName feature.
class ${pascalName}Model extends ${pascalName}Entity {
  const ${pascalName}Model({
    required super.id,
    required super.name,
  });

  /// Creates a model from JSON.
  factory ${pascalName}Model.fromJson(Map<String, dynamic> json) {
    return ${pascalName}Model(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }

  /// Converts model to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  /// Creates a copy with updated fields.
  ${pascalName}Model copyWith({
    String? id,
    String? name,
  }) {
    return ${pascalName}Model(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }
}
''';
  }

  static String _remoteDataSourceTemplate(
      String featureName, String pascalName) {
    return '''
import 'package:dio/dio.dart';

import '../models/${featureName}_model.dart';

/// Remote data source for $pascalName feature.
abstract class ${pascalName}RemoteDataSource {
  /// Fetches $featureName list from API.
  Future<List<${pascalName}Model>> getAll();

  /// Fetches a single $featureName by ID.
  Future<${pascalName}Model> getById(String id);

  /// Creates a new $featureName.
  Future<${pascalName}Model> create(${pascalName}Model model);

  /// Updates an existing $featureName.
  Future<${pascalName}Model> update(String id, ${pascalName}Model model);

  /// Deletes a $featureName.
  Future<void> delete(String id);
}

/// Implementation of remote data source using Dio.
class ${pascalName}RemoteDataSourceImpl implements ${pascalName}RemoteDataSource {
  ${pascalName}RemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<${pascalName}Model>> getAll() async {
    try {
      final response = await _dio.get('/$featureName');
      final data = response.data as List;
      return data.map((json) => ${pascalName}Model.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Failed to fetch $featureName list: \$e');
    }
  }

  @override
  Future<${pascalName}Model> getById(String id) async {
    try {
      final response = await _dio.get('/$featureName/\$id');
      return ${pascalName}Model.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch $featureName: \$e');
    }
  }

  @override
  Future<${pascalName}Model> create(${pascalName}Model model) async {
    try {
      final response = await _dio.post('/$featureName', data: model.toJson());
      return ${pascalName}Model.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create $featureName: \$e');
    }
  }

  @override
  Future<${pascalName}Model> update(String id, ${pascalName}Model model) async {
    try {
      final response = await _dio.put('/$featureName/\$id', data: model.toJson());
      return ${pascalName}Model.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update $featureName: \$e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _dio.delete('/$featureName/\$id');
    } catch (e) {
      throw Exception('Failed to delete $featureName: \$e');
    }
  }
}
''';
  }

  static String _localDataSourceTemplate(
      String featureName, String pascalName) {
    return '''
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/${featureName}_model.dart';

/// Local data source for $pascalName feature.
abstract class ${pascalName}LocalDataSource {
  /// Fetches cached $featureName list.
  Future<List<${pascalName}Model>> getCached();

  /// Caches $featureName list.
  Future<void> cache(List<${pascalName}Model> items);

  /// Clears cache.
  Future<void> clearCache();
}

/// Implementation of local data source using shared preferences.
class ${pascalName}LocalDataSourceImpl implements ${pascalName}LocalDataSource {
  ${pascalName}LocalDataSourceImpl(this._prefs);

  final SharedPreferences _prefs;
  static const String _cacheKey = '${featureName}_cache';

  @override
  Future<List<${pascalName}Model>> getCached() async {
    try {
      final jsonString = _prefs.getString(_cacheKey);
      if (jsonString == null) {
        return [];
      }

      final jsonList = json.decode(jsonString) as List;
      return jsonList
          .map((json) => ${pascalName}Model.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // If decoding fails, clear invalid cache
      await clearCache();
      return [];
    }
  }

  @override
  Future<void> cache(List<${pascalName}Model> items) async {
    try {
      final jsonList = items.map((item) => item.toJson()).toList();
      final jsonString = json.encode(jsonList);
      await _prefs.setString(_cacheKey, jsonString);
    } catch (e) {
      throw Exception('Failed to cache $featureName data: \$e');
    }
  }

  @override
  Future<void> clearCache() async {
    await _prefs.remove(_cacheKey);
  }
}
''';
  }

  static String _repositoryImplTemplate(
    String featureName,
    String pascalName,
    bool includeApi,
  ) {
    final remoteImport = includeApi
        ? "import '../datasources/${featureName}_remote_data_source.dart';\n"
        : '';
    final remoteField = includeApi
        ? '  final ${pascalName}RemoteDataSource _remoteDataSource;\n'
        : '';
    final remoteParam = includeApi
        ? '    required ${pascalName}RemoteDataSource remoteDataSource,\n'
        : '';
    final remoteInit =
        includeApi ? '        _remoteDataSource = remoteDataSource,\n' : '';
    final implementation = includeApi
        ? _withApiImplementation(featureName, pascalName)
        : _withoutApiImplementation(featureName, pascalName);

    return '''
${remoteImport}import '../datasources/${featureName}_local_data_source.dart';
import '../../domain/entities/${featureName}_entity.dart';
import '../../domain/repositories/${featureName}_repository.dart';

/// Implementation of ${pascalName}Repository.
class ${pascalName}RepositoryImpl implements ${pascalName}Repository {
  ${pascalName}RepositoryImpl({
$remoteParam    required ${pascalName}LocalDataSource localDataSource,
  })  : ${remoteInit}_localDataSource = localDataSource;

$remoteField  final ${pascalName}LocalDataSource _localDataSource;

$implementation}
''';
  }

  static String _withApiImplementation(String featureName, String pascalName) {
    return '''
  @override
  Future<List<${pascalName}Entity>> getAll() async {
    try {
      // Try to fetch from remote
      final items = await _remoteDataSource.getAll();
      
      // Cache the results
      await _localDataSource.cache(items);
      
      return items;
    } catch (e) {
      // If remote fails, try to get from cache
      final cachedItems = await _localDataSource.getCached();
      if (cachedItems.isNotEmpty) {
        return cachedItems;
      }
      throw Exception('Failed to fetch $featureName list: \$e');
    }
  }

  @override
  Future<${pascalName}Entity> getById(String id) async {
    try {
      return await _remoteDataSource.getById(id);
    } catch (e) {
      throw Exception('Failed to fetch $featureName: \$e');
    }
  }

  @override
  Future<${pascalName}Entity> create(${pascalName}Entity entity) async {
    try {
      final model = entity as ${pascalName}Model;
      return await _remoteDataSource.create(model);
    } catch (e) {
      throw Exception('Failed to create $featureName: \$e');
    }
  }

  @override
  Future<${pascalName}Entity> update(String id, ${pascalName}Entity entity) async {
    try {
      final model = entity as ${pascalName}Model;
      return await _remoteDataSource.update(id, model);
    } catch (e) {
      throw Exception('Failed to update $featureName: \$e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _remoteDataSource.delete(id);
    } catch (e) {
      throw Exception('Failed to delete $featureName: \$e');
    }
  }''';
  }

  static String _withoutApiImplementation(
      String featureName, String pascalName) {
    return '''
  @override
  Future<List<${pascalName}Entity>> getAll() async {
    try {
      return await _localDataSource.getCached();
    } catch (e) {
      throw Exception('Failed to fetch $featureName list: \$e');
    }
  }

  @override
  Future<${pascalName}Entity> getById(String id) async {
    try {
      final items = await _localDataSource.getCached();
      return items.firstWhere(
        (item) => item.id == id,
        orElse: () => throw Exception('$pascalName with id \$id not found'),
      );
    } catch (e) {
      throw Exception('Failed to fetch $featureName: \$e');
    }
  }

  @override
  Future<${pascalName}Entity> create(${pascalName}Entity entity) async {
    try {
      final items = await _localDataSource.getCached();
      final model = entity as ${pascalName}Model;
      final updatedItems = [...items, model];
      await _localDataSource.cache(updatedItems);
      return model;
    } catch (e) {
      throw Exception('Failed to create $featureName: \$e');
    }
  }

  @override
  Future<${pascalName}Entity> update(String id, ${pascalName}Entity entity) async {
    try {
      final items = await _localDataSource.getCached();
      final index = items.indexWhere((item) => item.id == id);
      if (index == -1) {
        throw Exception('$pascalName with id \$id not found');
      }
      final model = entity as ${pascalName}Model;
      final updatedItems = [...items];
      updatedItems[index] = model;
      await _localDataSource.cache(updatedItems);
      return model;
    } catch (e) {
      throw Exception('Failed to update $featureName: \$e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      final items = await _localDataSource.getCached();
      final updatedItems = items.where((item) => item.id != id).toList();
      await _localDataSource.cache(updatedItems);
    } catch (e) {
      throw Exception('Failed to delete $featureName: \$e');
    }
  }''';
  }
}

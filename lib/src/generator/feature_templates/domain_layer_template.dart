import '../../generator/feature_generator.dart';
import '../../utils/string_extensions.dart';

/// Generates domain layer files (entities, repositories, use cases).
class DomainLayerTemplate {
  static List<FileTemplate> generate({
    required String featureName,
  }) {
    final templates = <FileTemplate>[];
    final pascalName = featureName.toPascalCase();

    // Entities
    templates.add(FileTemplate(
      relativePath: 'domain/entities/${featureName}_entity.dart',
      content: _entityTemplate(featureName, pascalName),
    ));

    // Repositories (abstract)
    templates.add(FileTemplate(
      relativePath: 'domain/repositories/${featureName}_repository.dart',
      content: _repositoryTemplate(featureName, pascalName),
    ));

    // Use cases
    templates.add(FileTemplate(
      relativePath: 'domain/usecases/get_${featureName}_list.dart',
      content: _getListUseCaseTemplate(featureName, pascalName),
    ));

    templates.add(FileTemplate(
      relativePath: 'domain/usecases/get_${featureName}_by_id.dart',
      content: _getByIdUseCaseTemplate(featureName, pascalName),
    ));

    templates.add(FileTemplate(
      relativePath: 'domain/usecases/create_${featureName}.dart',
      content: _createUseCaseTemplate(featureName, pascalName),
    ));

    templates.add(FileTemplate(
      relativePath: 'domain/usecases/update_${featureName}.dart',
      content: _updateUseCaseTemplate(featureName, pascalName),
    ));

    templates.add(FileTemplate(
      relativePath: 'domain/usecases/delete_${featureName}.dart',
      content: _deleteUseCaseTemplate(featureName, pascalName),
    ));

    return templates;
  }

  static String _entityTemplate(String featureName, String pascalName) {
    return '''
import 'package:equatable/equatable.dart';

/// Domain entity for $pascalName feature.
class ${pascalName}Entity extends Equatable {
  const ${pascalName}Entity({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;

  @override
  List<Object?> get props => [id, name];
}
''';
  }

  static String _repositoryTemplate(String featureName, String pascalName) {
    return '''
import '../entities/${featureName}_entity.dart';

/// Repository contract for $pascalName feature.
abstract class ${pascalName}Repository {
  /// Fetches all ${featureName} items.
  Future<List<${pascalName}Entity>> getAll();

  /// Fetches a single ${featureName} by ID.
  Future<${pascalName}Entity> getById(String id);

  /// Creates a new ${featureName}.
  Future<${pascalName}Entity> create(${pascalName}Entity entity);

  /// Updates an existing ${featureName}.
  Future<${pascalName}Entity> update(String id, ${pascalName}Entity entity);

  /// Deletes a ${featureName}.
  Future<void> delete(String id);
}
''';
  }

  static String _getListUseCaseTemplate(String featureName, String pascalName) {
    return '''
import '../entities/${featureName}_entity.dart';
import '../repositories/${featureName}_repository.dart';

/// Use case for fetching ${featureName} list.
class Get${pascalName}List {
  Get${pascalName}List(this._repository);

  final ${pascalName}Repository _repository;

  /// Executes the use case.
  Future<List<${pascalName}Entity>> call() async {
    return await _repository.getAll();
  }
}
''';
  }

  static String _getByIdUseCaseTemplate(String featureName, String pascalName) {
    return '''
import '../entities/${featureName}_entity.dart';
import '../repositories/${featureName}_repository.dart';

/// Use case for fetching a single ${featureName}.
class Get${pascalName}ById {
  Get${pascalName}ById(this._repository);

  final ${pascalName}Repository _repository;

  /// Executes the use case.
  Future<${pascalName}Entity> call(String id) async {
    return await _repository.getById(id);
  }
}
''';
  }

  static String _createUseCaseTemplate(String featureName, String pascalName) {
    return '''
import '../entities/${featureName}_entity.dart';
import '../repositories/${featureName}_repository.dart';

/// Use case for creating a ${featureName}.
class Create${pascalName} {
  Create${pascalName}(this._repository);

  final ${pascalName}Repository _repository;

  /// Executes the use case.
  Future<${pascalName}Entity> call(${pascalName}Entity entity) async {
    return await _repository.create(entity);
  }
}
''';
  }

  static String _updateUseCaseTemplate(String featureName, String pascalName) {
    return '''
import '../entities/${featureName}_entity.dart';
import '../repositories/${featureName}_repository.dart';

/// Use case for updating a ${featureName}.
class Update${pascalName} {
  Update${pascalName}(this._repository);

  final ${pascalName}Repository _repository;

  /// Executes the use case.
  Future<${pascalName}Entity> call(String id, ${pascalName}Entity entity) async {
    return await _repository.update(id, entity);
  }
}
''';
  }

  static String _deleteUseCaseTemplate(String featureName, String pascalName) {
    return '''
import '../repositories/${featureName}_repository.dart';

/// Use case for deleting a ${featureName}.
class Delete${pascalName} {
  Delete${pascalName}(this._repository);

  final ${pascalName}Repository _repository;

  /// Executes the use case.
  Future<void> call(String id) async {
    return await _repository.delete(id);
  }
}
''';
  }
}

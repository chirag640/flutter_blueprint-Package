import '../../config/blueprint_config.dart';
import '../../generator/feature_generator.dart';
import '../../utils/string_extensions.dart';

/// Generates presentation layer files (pages, widgets, state management).
class PresentationLayerTemplate {
  static List<FileTemplate> generate({
    required String featureName,
    required StateManagement stateManagement,
  }) {
    final templates = <FileTemplate>[];
    final pascalName = featureName.toPascalCase();

    // Page
    templates.add(FileTemplate(
      relativePath: 'presentation/pages/${featureName}_page.dart',
      content: _pageTemplate(featureName, pascalName, stateManagement),
    ));

    // Widgets
    templates.add(FileTemplate(
      relativePath: 'presentation/widgets/${featureName}_list_item.dart',
      content: _listItemWidgetTemplate(featureName, pascalName),
    ));

    // State management files
    switch (stateManagement) {
      case StateManagement.provider:
        templates.addAll(_generateProviderFiles(featureName, pascalName));
        break;
      case StateManagement.riverpod:
        templates.addAll(_generateRiverpodFiles(featureName, pascalName));
        break;
      case StateManagement.bloc:
        templates.addAll(_generateBlocFiles(featureName, pascalName));
        break;
    }

    return templates;
  }

  static String _pageTemplate(
    String featureName,
    String pascalName,
    StateManagement stateManagement,
  ) {
    final stateImport = switch (stateManagement) {
      StateManagement.provider =>
        "import 'package:provider/provider.dart';\nimport '../provider/${featureName}_provider.dart';",
      StateManagement.riverpod =>
        "import 'package:flutter_riverpod/flutter_riverpod.dart';\nimport '../provider/${featureName}_provider.dart';",
      StateManagement.bloc =>
        "import 'package:flutter_bloc/flutter_bloc.dart';\nimport '../bloc/${featureName}_bloc.dart';\nimport '../bloc/${featureName}_event.dart';\nimport '../bloc/${featureName}_state.dart';",
    };

    final widgetType = switch (stateManagement) {
      StateManagement.provider => 'StatelessWidget',
      StateManagement.riverpod => 'ConsumerWidget',
      StateManagement.bloc => 'StatelessWidget',
    };

    final buildParams = switch (stateManagement) {
      StateManagement.provider => 'BuildContext context',
      StateManagement.riverpod => 'BuildContext context, WidgetRef ref',
      StateManagement.bloc => 'BuildContext context',
    };

    final body = switch (stateManagement) {
      StateManagement.provider => _providerPageBody(featureName, pascalName),
      StateManagement.riverpod => _riverpodPageBody(featureName, pascalName),
      StateManagement.bloc => _blocPageBody(featureName, pascalName),
    };

    return '''
import 'package:flutter/material.dart';
$stateImport
import '../widgets/${featureName}_list_item.dart';

/// Page for $pascalName feature.
class ${pascalName}Page extends $widgetType {
  const ${pascalName}Page({super.key});

  @override
  Widget build($buildParams) {
$body  }
}
''';
  }

  static String _providerPageBody(String featureName, String pascalName) {
    return '''    return Scaffold(
      appBar: AppBar(
        title: const Text('${featureName.toTitleCase()}'),
      ),
      body: Consumer<${pascalName}Provider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: \${provider.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadItems(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.items.isEmpty) {
            return const Center(child: Text('No items found'));
          }

          return ListView.builder(
            itemCount: provider.items.length,
            itemBuilder: (context, index) {
              final item = provider.items[index];
              return ${pascalName}ListItem(
                item: item,
                onTap: () {
                  // TODO: Navigate to detail page
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<${pascalName}Provider>().loadItems();
        },
        child: const Icon(Icons.refresh),
      ),
    );''';
  }

  static String _riverpodPageBody(String featureName, String pascalName) {
    final camelName = featureName.toCamelCase();
    return '''    final ${camelName}State = ref.watch(${camelName}Provider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('${featureName.toTitleCase()}'),
      ),
      body: ${camelName}State.when(
        initial: () => const Center(child: Text('Press refresh to load data')),
        loading: () => const Center(child: CircularProgressIndicator()),
        loaded: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('No items found'));
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ${pascalName}ListItem(
                item: item,
                onTap: () {
                  // TODO: Navigate to detail page
                },
              );
            },
          );
        },
        error: (message) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: \$message'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(${camelName}Provider.notifier).loadItems();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(${camelName}Provider.notifier).loadItems();
        },
        child: const Icon(Icons.refresh),
      ),
    );''';
  }

  static String _blocPageBody(String featureName, String pascalName) {
    return '''    return Scaffold(
      appBar: AppBar(
        title: const Text('${featureName.toTitleCase()}'),
      ),
      body: BlocBuilder<${pascalName}Bloc, ${pascalName}State>(
        builder: (context, state) {
          if (state is ${pascalName}InitialState) {
            return const Center(child: Text('Press refresh to load data'));
          }

          if (state is ${pascalName}LoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ${pascalName}ErrorState) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: \${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<${pascalName}Bloc>().add(const Load${pascalName}Event());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is ${pascalName}LoadedState) {
            if (state.items.isEmpty) {
              return const Center(child: Text('No items found'));
            }

            return ListView.builder(
              itemCount: state.items.length,
              itemBuilder: (context, index) {
                final item = state.items[index];
                return ${pascalName}ListItem(
                  item: item,
                  onTap: () {
                    // TODO: Navigate to detail page
                  },
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<${pascalName}Bloc>().add(const Load${pascalName}Event());
        },
        child: const Icon(Icons.refresh),
      ),
    );''';
  }

  static String _listItemWidgetTemplate(String featureName, String pascalName) {
    return '''
import 'package:flutter/material.dart';

import '../../domain/entities/${featureName}_entity.dart';

/// List item widget for displaying ${featureName} entity.
class ${pascalName}ListItem extends StatelessWidget {
  const ${pascalName}ListItem({
    required this.item,
    required this.onTap,
    super.key,
  });

  final ${pascalName}Entity item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(item.name),
        subtitle: Text('ID: \${item.id}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
''';
  }

  static List<FileTemplate> _generateProviderFiles(
      String featureName, String pascalName) {
    return [
      FileTemplate(
        relativePath: 'presentation/provider/${featureName}_provider.dart',
        content: _providerTemplate(featureName, pascalName),
      ),
    ];
  }

  static String _providerTemplate(String featureName, String pascalName) {
    return '''
import 'package:flutter/foundation.dart';

import '../../domain/entities/${featureName}_entity.dart';
import '../../domain/usecases/get_${featureName}_list.dart';

/// Provider for $pascalName feature state management.
class ${pascalName}Provider extends ChangeNotifier {
  ${pascalName}Provider(this._getList);

  final Get${pascalName}List _getList;

  List<${pascalName}Entity> _items = [];
  bool _isLoading = false;
  String? _error;

  List<${pascalName}Entity> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Loads ${featureName} items.
  Future<void> loadItems() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _items = await _getList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
''';
  }

  static List<FileTemplate> _generateRiverpodFiles(
      String featureName, String pascalName) {
    return [
      FileTemplate(
        relativePath: 'presentation/provider/${featureName}_provider.dart',
        content: _riverpodProviderTemplate(featureName, pascalName),
      ),
    ];
  }

  static String _riverpodProviderTemplate(
      String featureName, String pascalName) {
    final camelName = featureName.toCamelCase();
    return '''
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/${featureName}_entity.dart';
import '../../domain/usecases/get_${featureName}_list.dart';

/// State for $pascalName feature.
sealed class ${pascalName}State {
  const ${pascalName}State();
}

class ${pascalName}InitialState extends ${pascalName}State {
  const ${pascalName}InitialState();
}

class ${pascalName}LoadingState extends ${pascalName}State {
  const ${pascalName}LoadingState();
}

class ${pascalName}LoadedState extends ${pascalName}State {
  const ${pascalName}LoadedState(this.items);

  final List<${pascalName}Entity> items;
}

class ${pascalName}ErrorState extends ${pascalName}State {
  const ${pascalName}ErrorState(this.message);

  final String message;
}

/// Extension for pattern matching on state.
extension ${pascalName}StateExtension on ${pascalName}State {
  T when<T>({
    required T Function() initial,
    required T Function() loading,
    required T Function(List<${pascalName}Entity> items) loaded,
    required T Function(String message) error,
  }) {
    final state = this;
    if (state is ${pascalName}InitialState) return initial();
    if (state is ${pascalName}LoadingState) return loading();
    if (state is ${pascalName}LoadedState) return loaded(state.items);
    if (state is ${pascalName}ErrorState) return error(state.message);
    throw StateError('Unhandled state: \$state');
  }
}

/// Notifier for managing $pascalName state.
class ${pascalName}Notifier extends StateNotifier<${pascalName}State> {
  ${pascalName}Notifier(this._getList) : super(const ${pascalName}InitialState());

  final Get${pascalName}List _getList;

  /// Loads ${featureName} items.
  Future<void> loadItems() async {
    state = const ${pascalName}LoadingState();

    try {
      final items = await _getList();
      state = ${pascalName}LoadedState(items);
    } catch (e) {
      state = ${pascalName}ErrorState(e.toString());
    }
  }
}

/// Provider for $pascalName feature.
final ${camelName}Provider = StateNotifierProvider<${pascalName}Notifier, ${pascalName}State>((ref) {
  // TODO: Inject dependencies properly
  throw UnimplementedError('Inject Get${pascalName}List use case');
});
''';
  }

  static List<FileTemplate> _generateBlocFiles(
      String featureName, String pascalName) {
    return [
      FileTemplate(
        relativePath: 'presentation/bloc/${featureName}_event.dart',
        content: _blocEventTemplate(featureName, pascalName),
      ),
      FileTemplate(
        relativePath: 'presentation/bloc/${featureName}_state.dart',
        content: _blocStateTemplate(featureName, pascalName),
      ),
      FileTemplate(
        relativePath: 'presentation/bloc/${featureName}_bloc.dart',
        content: _blocTemplate(featureName, pascalName),
      ),
    ];
  }

  static String _blocEventTemplate(String featureName, String pascalName) {
    return '''
import 'package:equatable/equatable.dart';

/// Base event for $pascalName feature.
sealed class ${pascalName}Event extends Equatable {
  const ${pascalName}Event();

  @override
  List<Object?> get props => [];
}

/// Event to load ${featureName} items.
class Load${pascalName}Event extends ${pascalName}Event {
  const Load${pascalName}Event();
}

/// Event to refresh ${featureName} items.
class Refresh${pascalName}Event extends ${pascalName}Event {
  const Refresh${pascalName}Event();
}
''';
  }

  static String _blocStateTemplate(String featureName, String pascalName) {
    return '''
import 'package:equatable/equatable.dart';

import '../../domain/entities/${featureName}_entity.dart';

/// Base state for $pascalName feature.
sealed class ${pascalName}State extends Equatable {
  const ${pascalName}State();

  @override
  List<Object?> get props => [];
}

/// Initial state.
class ${pascalName}InitialState extends ${pascalName}State {
  const ${pascalName}InitialState();
}

/// Loading state.
class ${pascalName}LoadingState extends ${pascalName}State {
  const ${pascalName}LoadingState();
}

/// Loaded state with items.
class ${pascalName}LoadedState extends ${pascalName}State {
  const ${pascalName}LoadedState(this.items);

  final List<${pascalName}Entity> items;

  @override
  List<Object?> get props => [items];
}

/// Error state with message.
class ${pascalName}ErrorState extends ${pascalName}State {
  const ${pascalName}ErrorState(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
''';
  }

  static String _blocTemplate(String featureName, String pascalName) {
    return '''
import 'package:bloc/bloc.dart';

import '../../domain/usecases/get_${featureName}_list.dart';
import '${featureName}_event.dart';
import '${featureName}_state.dart';

/// BLoC for managing $pascalName feature.
class ${pascalName}Bloc extends Bloc<${pascalName}Event, ${pascalName}State> {
  ${pascalName}Bloc(this._getList) : super(const ${pascalName}InitialState()) {
    on<Load${pascalName}Event>(_onLoad);
    on<Refresh${pascalName}Event>(_onRefresh);
  }

  final Get${pascalName}List _getList;

  Future<void> _onLoad(
    Load${pascalName}Event event,
    Emitter<${pascalName}State> emit,
  ) async {
    emit(const ${pascalName}LoadingState());

    try {
      final items = await _getList();
      emit(${pascalName}LoadedState(items));
    } catch (e) {
      emit(${pascalName}ErrorState(e.toString()));
    }
  }

  Future<void> _onRefresh(
    Refresh${pascalName}Event event,
    Emitter<${pascalName}State> emit,
  ) async {
    // Same as load for now
    emit(const ${pascalName}LoadingState());

    try {
      final items = await _getList();
      emit(${pascalName}LoadedState(items));
    } catch (e) {
      emit(${pascalName}ErrorState(e.toString()));
    }
  }
}
''';
  }
}

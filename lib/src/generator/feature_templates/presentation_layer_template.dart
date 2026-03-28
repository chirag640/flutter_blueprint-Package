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
      case StateManagement.getx:
        templates.addAll(_generateGetxFiles(featureName, pascalName));
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
      StateManagement.getx =>
        "import 'package:get/get.dart';\nimport '../controllers/${featureName}_controller.dart';",
    };

    final widgetType = switch (stateManagement) {
      StateManagement.provider => 'StatelessWidget',
      StateManagement.riverpod => 'ConsumerWidget',
      StateManagement.bloc => 'StatelessWidget',
      StateManagement.getx => 'GetView<${pascalName}Controller>',
    };

    final buildParams = switch (stateManagement) {
      StateManagement.provider => 'BuildContext context',
      StateManagement.riverpod => 'BuildContext context, WidgetRef ref',
      StateManagement.bloc => 'BuildContext context',
      StateManagement.getx => 'BuildContext context',
    };

    final body = switch (stateManagement) {
      StateManagement.provider => _providerPageBody(featureName, pascalName),
      StateManagement.riverpod => _riverpodPageBody(featureName, pascalName),
      StateManagement.bloc => _blocPageBody(featureName, pascalName),
      StateManagement.getx => _getxPageBody(featureName, pascalName),
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

  Widget _responsiveBody({
    required Widget child,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final horizontalPadding = width >= 1024
            ? 48.0
            : width >= 600
                ? 24.0
                : 12.0;
        final maxContentWidth = width >= 1440
            ? 1100.0
            : width >= 1024
                ? 960.0
                : width >= 600
                    ? 720.0
                    : width;

        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 8,
              ),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
''';
  }

  static String _getxPageBody(String featureName, String pascalName) {
    return '''    return Scaffold(
      appBar: AppBar(
        title: const Text('${featureName.replaceAll('_', ' ')}'),
      ),
      body: _responsiveBody(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.error.value.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: \${controller.error.value}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: controller.loadItems,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (controller.items.isEmpty) {
            return const Center(child: Text('No items found'));
          }

          return ListView.builder(
            itemCount: controller.items.length,
            itemBuilder: (context, index) {
              final item = controller.items[index];
              return ${pascalName}ListItem(
                item: item,
                onTap: () {
                  // Get.toNamed('/\${featureName}-detail', arguments: item);
                },
              );
            },
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.loadItems,
        child: const Icon(Icons.refresh),
      ),
    );''';
  }

  static List<FileTemplate> _generateGetxFiles(
      String featureName, String pascalName) {
    return [
      FileTemplate(
        relativePath: 'presentation/controllers/${featureName}_controller.dart',
        content: _getxControllerTemplate(featureName, pascalName),
      ),
      FileTemplate(
        relativePath: 'presentation/bindings/${featureName}_binding.dart',
        content: _getxBindingTemplate(featureName, pascalName),
      ),
    ];
  }

  static String _getxControllerTemplate(String featureName, String pascalName) {
    return '''
import 'package:get/get.dart';

import '../../domain/entities/${featureName}_entity.dart';
import '../../domain/usecases/get_${featureName}_list.dart';

/// GetX controller for $pascalName feature.
///
/// Exposes reactive state via [RxList], [RxBool], and [RxString].
/// Observe state in widgets using [Obx] or [GetX].
class ${pascalName}Controller extends GetxController {
  ${pascalName}Controller(this._getList);

  final Get${pascalName}List _getList;

  // ── Reactive State ────────────────────────────────────────────
  final RxList<${pascalName}Entity> items = <${pascalName}Entity>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  // ── Lifecycle ─────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    loadItems();
  }

  // ── Methods ───────────────────────────────────────────────────

  /// Loads $featureName items from the use case.
  Future<void> loadItems() async {
    isLoading.value = true;
    error.value = '';

    try {
      final result = await _getList();
      items.assignAll(result);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
''';
  }

  static String _getxBindingTemplate(String featureName, String pascalName) {
    return '''
import 'package:get/get.dart';

import '../../domain/repositories/${featureName}_repository.dart';
import '../../domain/usecases/get_${featureName}_list.dart';
import '../controllers/${featureName}_controller.dart';

/// Binding for $pascalName feature.
///
/// Lazily registers [${pascalName}Controller] and its dependencies
/// before the page is shown. GetX auto-disposes them when the page is closed.
class ${pascalName}Binding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<${pascalName}Repository>()) {
      throw StateError(
        '${pascalName}Repository is not registered. '
        'Register it before navigating to ${pascalName}Page.',
      );
    }

    if (!Get.isRegistered<Get${pascalName}List>()) {
      Get.lazyPut<Get${pascalName}List>(
        () => Get${pascalName}List(Get.find<${pascalName}Repository>()),
        fenix: true,
      );
    }

    Get.lazyPut<${pascalName}Controller>(
      () => ${pascalName}Controller(Get.find<Get${pascalName}List>()),
      fenix: true,
    );
  }
}
''';
  }

  static String _providerPageBody(String featureName, String pascalName) {
    return '''    return Scaffold(
      appBar: AppBar(
        title: const Text('${featureName.toTitleCase()}'),
      ),
      body: _responsiveBody(
        child: Consumer<${pascalName}Provider>(
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
                    // Navigate to detail page
                    // Navigator.pushNamed(context, '/$featureName/detail', arguments: item);
                    // Or with MaterialPageRoute:
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => ${pascalName}DetailPage(item: item),
                    //   ),
                    // );
                  },
                );
              },
            );
          },
        ),
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
      body: _responsiveBody(
        child: ${camelName}State.when(
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
                    // Navigate to detail page
                    // Navigator.pushNamed(context, '/$featureName/detail', arguments: item);
                    // Or with MaterialPageRoute:
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => ${pascalName}DetailPage(item: item),
                    //   ),
                    // );
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
      body: _responsiveBody(
        child: BlocBuilder<${pascalName}Bloc, ${pascalName}State>(
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
                      // Navigate to detail page
                      // Navigator.pushNamed(context, '/$featureName/detail', arguments: item);
                      // Or with MaterialPageRoute:
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => ${pascalName}DetailPage(item: item),
                      //   ),
                      // );
                    },
                  );
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
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

/// List item widget for displaying $featureName entity.
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
import 'dart:collection';

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

  UnmodifiableListView<${pascalName}Entity> get items =>
      UnmodifiableListView(_items);
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Loads $featureName items.
  Future<void> loadItems() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _items = List<${pascalName}Entity>.unmodifiable(await _getList());
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
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/${featureName}_entity.dart';
import '../../domain/repositories/${featureName}_repository.dart';
import '../../domain/usecases/get_${featureName}_list.dart';

part '${featureName}_provider.freezed.dart';

/// State for $pascalName feature.
@freezed
sealed class ${pascalName}State with _\$${pascalName}State {
  const factory ${pascalName}State.initial() = ${pascalName}InitialState;
  const factory ${pascalName}State.loading() = ${pascalName}LoadingState;
  const factory ${pascalName}State.loaded(List<${pascalName}Entity> items) =
      ${pascalName}LoadedState;
  const factory ${pascalName}State.error(String message) =
      ${pascalName}ErrorState;
}

/// Notifier for managing $pascalName state.
class ${pascalName}Notifier extends StateNotifier<${pascalName}State> {
  ${pascalName}Notifier(this._getList)
      : super(const ${pascalName}State.initial());

  final Get${pascalName}List _getList;

  /// Loads $featureName items.
  Future<void> loadItems() async {
    state = const ${pascalName}State.loading();

    try {
      final items = await _getList();
      state = ${pascalName}State.loaded(items);
    } catch (e) {
      state = ${pascalName}State.error(e.toString());
    }
  }
}

/// Contract provider for injecting the repository implementation.
///
/// Override this in `ProviderScope` with your concrete repository.
final ${camelName}RepositoryProvider = Provider<${pascalName}Repository>((ref) {
  throw StateError(
    'No ${pascalName}Repository provided. '
    'Override ${camelName}RepositoryProvider in ProviderScope.',
  );
});

/// Use case provider wired through the repository provider.
final ${camelName}GetListUseCaseProvider = Provider<Get${pascalName}List>((ref) {
  final repository = ref.watch(${camelName}RepositoryProvider);
  return Get${pascalName}List(repository);
});

/// StateNotifier provider with constructor injection.
final ${camelName}Provider = StateNotifierProvider<${pascalName}Notifier, ${pascalName}State>((ref) {
  final getList = ref.watch(${camelName}GetListUseCaseProvider);
  return ${pascalName}Notifier(getList);
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
import 'package:freezed_annotation/freezed_annotation.dart';

part '${featureName}_event.freezed.dart';

/// Base event for $pascalName feature.
@freezed
sealed class ${pascalName}Event with _\$${pascalName}Event {
  /// Event to load $featureName items.
  const factory ${pascalName}Event.load() = Load${pascalName}Event;

  /// Event to refresh $featureName items.
  const factory ${pascalName}Event.refresh() = Refresh${pascalName}Event;
}
''';
  }

  static String _blocStateTemplate(String featureName, String pascalName) {
    return '''
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/${featureName}_entity.dart';

part '${featureName}_state.freezed.dart';

/// Base state for $pascalName feature.
@freezed
sealed class ${pascalName}State with _\$${pascalName}State {
  /// Initial state.
  const factory ${pascalName}State.initial() = ${pascalName}InitialState;

  /// Loading state.
  const factory ${pascalName}State.loading() = ${pascalName}LoadingState;

  /// Loaded state with items.
  const factory ${pascalName}State.loaded(List<${pascalName}Entity> items) =
      ${pascalName}LoadedState;

  /// Error state with message.
  const factory ${pascalName}State.error(String message) =
      ${pascalName}ErrorState;
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
  ${pascalName}Bloc(this._getList)
      : super(const ${pascalName}State.initial()) {
    on<Load${pascalName}Event>(_onLoad);
    on<Refresh${pascalName}Event>(_onRefresh);
  }

  final Get${pascalName}List _getList;

  Future<void> _onLoad(
    Load${pascalName}Event event,
    Emitter<${pascalName}State> emit,
  ) async {
    emit(const ${pascalName}State.loading());

    try {
      final items = await _getList();
      emit(${pascalName}State.loaded(items));
    } catch (e) {
      emit(${pascalName}State.error(e.toString()));
    }
  }

  Future<void> _onRefresh(
    Refresh${pascalName}Event event,
    Emitter<${pascalName}State> emit,
  ) async {
    // Same as load for now
    emit(const ${pascalName}State.loading());

    try {
      final items = await _getList();
      emit(${pascalName}State.loaded(items));
    } catch (e) {
      emit(${pascalName}State.error(e.toString()));
    }
  }
}
''';
  }
}

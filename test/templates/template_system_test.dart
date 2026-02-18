import 'package:test/test.dart';
import 'package:flutter_blueprint/src/config/blueprint_config.dart';
import 'package:flutter_blueprint/src/templates/core/template_interface.dart';
import 'package:flutter_blueprint/src/templates/core/template_engine.dart';
import 'package:flutter_blueprint/src/templates/template_bundle.dart';

/// Helper to create a minimal BlueprintConfig for testing.
BlueprintConfig _testConfig({
  String appName = 'test_app',
  List<TargetPlatform> platforms = const [TargetPlatform.mobile],
  StateManagement stateManagement = StateManagement.provider,
  bool includeApi = false,
}) {
  return BlueprintConfig(
    appName: appName,
    platforms: platforms,
    stateManagement: stateManagement,
    includeTheme: true,
    includeLocalization: false,
    includeEnv: false,
    includeApi: includeApi,
    includeTests: false,
  );
}

void main() {
  group('GeneratedFile', () {
    test('holds path and content', () {
      const file =
          GeneratedFile(path: 'lib/main.dart', content: 'void main(){}');
      expect(file.path, 'lib/main.dart');
      expect(file.content, 'void main(){}');
      expect(file.overwrite, isTrue);
    });

    test('toString includes path and char count', () {
      const file = GeneratedFile(path: 'lib/x.dart', content: 'abc');
      expect(file.toString(), contains('lib/x.dart'));
      expect(file.toString(), contains('3 chars'));
    });
  });

  group('TemplateContext', () {
    test('provides convenience getters', () {
      final config = _testConfig(
        appName: 'test_app',
        stateManagement: StateManagement.riverpod,
      );
      final ctx = TemplateContext(config: config);
      expect(ctx.appName, 'test_app');
      expect(ctx.stateManagement, StateManagement.riverpod);
    });
  });

  group('TemplateRegistry', () {
    test('registers and retrieves renderers', () {
      final registry = TemplateRegistry();
      final renderer = _MockRenderer('test', 'Test renderer');
      registry.register(renderer);
      expect(registry.get('test'), same(renderer));
    });

    test('names returns sorted list', () {
      final registry = TemplateRegistry();
      registry.registerAll([
        _MockRenderer('z', ''),
        _MockRenderer('a', ''),
        _MockRenderer('m', ''),
      ]);
      expect(registry.names, ['a', 'm', 'z']);
    });

    test('selectFor returns universal for multi-platform', () {
      final registry = TemplateRegistry();
      final universal = _MockRenderer('universal', 'Universal');
      registry.register(universal);

      final config = _testConfig(
        appName: 'test',
        platforms: [TargetPlatform.mobile, TargetPlatform.web],
      );
      expect(registry.selectFor(config), same(universal));
    });

    test('selectFor returns null when not found', () {
      final registry = TemplateRegistry();
      final config = _testConfig(appName: 'test');
      expect(registry.selectFor(config), isNull);
    });
  });

  group('TemplateBundleAdapter', () {
    test('adapts TemplateBundle to ITemplateRenderer', () {
      final adapter = TemplateBundleAdapter(
        templateName: 'test_adapter',
        templateDescription: 'Test adapter',
        builder: (config) => TemplateBundle(
          files: [
            TemplateFile(
              path: 'lib/test.dart',
              build: (c) => '// ${c.appName}',
            ),
          ],
        ),
      );

      expect(adapter.name, 'test_adapter');
      expect(adapter.description, 'Test adapter');

      final config = _testConfig(
        appName: 'demo',
        stateManagement: StateManagement.bloc,
      );
      final files = adapter.render(TemplateContext(config: config));
      expect(files, hasLength(1));
      expect(files[0].path, 'lib/test.dart');
      expect(files[0].content, '// demo');
    });

    test('respects shouldGenerate predicate', () {
      final adapter = TemplateBundleAdapter(
        templateName: 'filtered',
        templateDescription: 'Filtered adapter',
        builder: (config) => TemplateBundle(
          files: [
            TemplateFile(
              path: 'lib/a.dart',
              build: (c) => 'a',
            ),
            TemplateFile(
              path: 'lib/b.dart',
              build: (c) => 'b',
              shouldGenerate: (c) => false, // Should be excluded
            ),
          ],
        ),
      );

      final config = _testConfig(appName: 'x');
      final files = adapter.render(TemplateContext(config: config));
      expect(files, hasLength(1));
      expect(files[0].path, 'lib/a.dart');
    });
  });

  group('SimpleTemplateBundleAdapter', () {
    test('adapts no-arg builder to ITemplateRenderer', () {
      final adapter = SimpleTemplateBundleAdapter(
        templateName: 'simple',
        templateDescription: 'Simple adapter',
        builder: () => TemplateBundle(
          files: [
            TemplateFile(
              path: 'lib/simple.dart',
              build: (c) => 'simple: ${c.appName}',
            ),
          ],
        ),
      );

      final config = _testConfig(
        appName: 'myapp',
        platforms: [TargetPlatform.web],
        stateManagement: StateManagement.riverpod,
      );
      final files = adapter.render(TemplateContext(config: config));
      expect(files, hasLength(1));
      expect(files[0].content, 'simple: myapp');
    });
  });

  group('SharedComponents', () {
    test('apiService generates Dio client code', () {
      final config = _testConfig(
        appName: 'api_test',
        includeApi: true,
      );
      final code = SharedComponents.apiService(config);
      expect(code, contains('ApiClient'));
      expect(code, contains('Dio'));
      expect(code, contains('get<T>'));
      expect(code, contains('post<T>'));
    });

    test('envConfig generates environment class', () {
      final config = _testConfig(appName: 'env_test');
      final code = SharedComponents.envConfig(config);
      expect(code, contains('EnvConfig'));
      expect(code, contains('env_test'));
    });

    test('modelBase generates abstract Model class', () {
      final code = SharedComponents.modelBase();
      expect(code, contains('abstract class Model'));
      expect(code, contains('toJson'));
    });
  });
}

class _MockRenderer implements ITemplateRenderer {
  _MockRenderer(this.name, this.description);

  @override
  final String name;

  @override
  final String description;

  @override
  List<GeneratedFile> render(TemplateContext context) => [];
}

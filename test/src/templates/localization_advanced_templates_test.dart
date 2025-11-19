import 'package:flutter_blueprint/src/templates/localization_advanced_templates.dart';
import 'package:test/test.dart';

void main() {
  group('LocalizationAdvancedTemplates', () {
    group('generateAdvancedLocaleManager', () {
      test('generates valid Dart code', () {
        final result = generateAdvancedLocaleManager();
        expect(result, isNotEmpty);
        expect(result, contains('class LocaleManager'));
      });

      test('includes SharedPreferences import', () {
        final result = generateAdvancedLocaleManager();
        expect(
            result,
            contains(
                'import \'package:shared_preferences/shared_preferences.dart\''));
      });

      test('includes locale persistence logic', () {
        final result = generateAdvancedLocaleManager();
        expect(result, contains('_saveLocale'));
        expect(result, contains('_loadLocale'));
        expect(result, contains('_prefs'));
      });

      test('includes RTL detection', () {
        final result = generateAdvancedLocaleManager();
        expect(result, contains('isRTL'));
        expect(result, contains('rtlLanguages'));
      });

      test('includes supported locales list', () {
        final result = generateAdvancedLocaleManager();
        expect(result, contains('supportedLocales'));
        expect(result, contains('Locale('));
      });

      test('includes setLocale method', () {
        final result = generateAdvancedLocaleManager();
        expect(result, contains('Future<void> setLocale'));
        expect(result, contains('notifyListeners()'));
      });

      test('includes currentLocale getter', () {
        final result = generateAdvancedLocaleManager();
        expect(result, contains('Locale get currentLocale'));
      });

      test('includes ChangeNotifier', () {
        final result = generateAdvancedLocaleManager();
        expect(result, contains('extends ChangeNotifier'));
      });

      test('includes initialization method', () {
        final result = generateAdvancedLocaleManager();
        expect(result, contains('Future<void> initialize'));
      });

      test('includes proper documentation', () {
        final result = generateAdvancedLocaleManager();
        expect(result, contains('///'));
        expect(result, contains('Advanced locale manager'));
      });
    });

    group('generateARBGenerator', () {
      test('generates valid Dart code', () {
        final result = generateARBGenerator();
        expect(result, isNotEmpty);
        expect(result, contains('class ARBGenerator'));
      });

      test('includes dart:convert import', () {
        final result = generateARBGenerator();
        expect(result, contains('import \'dart:convert\''));
      });

      test('includes dart:io import', () {
        final result = generateARBGenerator();
        expect(result, contains('import \'dart:io\''));
      });

      test('includes ARB file generation method', () {
        final result = generateARBGenerator();
        expect(result, contains('Future<void> generateARB'));
      });

      test('includes pluralization support', () {
        final result = generateARBGenerator();
        expect(result, contains('plural'));
        expect(result, contains('zero'));
        expect(result, contains('one'));
        expect(result, contains('other'));
      });

      test('includes gender support', () {
        final result = generateARBGenerator();
        expect(result, contains('gender'));
        expect(result, contains('male'));
        expect(result, contains('female'));
      });

      test('includes validation method', () {
        final result = generateARBGenerator();
        expect(result, contains('validateARB'));
      });

      test('includes proper JSON encoding', () {
        final result = generateARBGenerator();
        expect(result, contains('JsonEncoder.withIndent'));
        expect(result, contains('json.encode'));
      });

      test('includes @@locale metadata', () {
        final result = generateARBGenerator();
        expect(result, contains('@@locale'));
      });

      test('includes usage examples in comments', () {
        final result = generateARBGenerator();
        expect(result, contains('Usage:'));
        expect(result, contains('```dart'));
      });
    });

    group('generateRTLSupport', () {
      test('generates valid Dart code', () {
        final result = generateRTLSupport();
        expect(result, isNotEmpty);
        expect(result, contains('class RTL'));
      });

      test('includes Flutter imports', () {
        final result = generateRTLSupport();
        expect(result, contains('import \'package:flutter/material.dart\''));
      });

      test('includes RTL-aware padding widget', () {
        final result = generateRTLSupport();
        expect(result, contains('class RTLPadding'));
        expect(result, contains('EdgeInsetsDirectional'));
      });

      test('includes directional icon widget', () {
        final result = generateRTLSupport();
        expect(result, contains('class DirectionalIcon'));
        expect(result, contains('isRTL'));
      });

      test('includes RTL utility methods', () {
        final result = generateRTLSupport();
        expect(result, contains('static bool isRTL'));
        expect(result, contains('Directionality.of'));
      });

      test('includes getDirectionalPadding helper', () {
        final result = generateRTLSupport();
        expect(result, contains('getDirectionalPadding'));
      });

      test('includes icon mirroring logic', () {
        final result = generateRTLSupport();
        expect(result, contains('Transform.flip'));
        expect(result, contains('flipX'));
      });

      test('includes proper StatelessWidget inheritance', () {
        final result = generateRTLSupport();
        expect(result, contains('extends StatelessWidget'));
      });

      test('includes documentation', () {
        final result = generateRTLSupport();
        expect(result, contains('///'));
        expect(result, contains('RTL'));
      });

      test('includes usage examples', () {
        final result = generateRTLSupport();
        expect(result, contains('Usage:'));
      });
    });

    group('generateDynamicLocaleLoader', () {
      test('generates valid Dart code', () {
        final result = generateDynamicLocaleLoader();
        expect(result, isNotEmpty);
        expect(result, contains('class DynamicLocaleLoader'));
      });

      test('includes dart:async import', () {
        final result = generateDynamicLocaleLoader();
        expect(result, contains('import \'dart:async\''));
      });

      test('includes lazy loading logic', () {
        final result = generateDynamicLocaleLoader();
        expect(result, contains('Future<Map<String, String>> loadLocale'));
      });

      test('includes caching mechanism', () {
        final result = generateDynamicLocaleLoader();
        expect(result, contains('_cache'));
        expect(result, contains('Map<String, Map<String, String>>'));
      });

      test('includes fallback handling', () {
        final result = generateDynamicLocaleLoader();
        expect(result, contains('fallback'));
        expect(result, contains('en'));
      });

      test('includes preload method', () {
        final result = generateDynamicLocaleLoader();
        expect(result, contains('Future<void> preloadLocales'));
      });

      test('includes cache clearing', () {
        final result = generateDynamicLocaleLoader();
        expect(result, contains('clearCache'));
      });

      test('includes remote loading simulation', () {
        final result = generateDynamicLocaleLoader();
        expect(result, contains('_loadFromRemote'));
      });

      test('includes error handling', () {
        final result = generateDynamicLocaleLoader();
        expect(result, contains('try'));
        expect(result, contains('catch'));
      });

      test('includes proper documentation', () {
        final result = generateDynamicLocaleLoader();
        expect(result, contains('///'));
        expect(result, contains('Dynamic locale loader'));
      });
    });

    group('generateLocalizationExamples', () {
      test('generates valid Dart code', () {
        final result = generateLocalizationExamples();
        expect(result, isNotEmpty);
        expect(result, contains('class LocalizationExamples'));
      });

      test('includes complete setup example', () {
        final result = generateLocalizationExamples();
        expect(result, contains('Complete Localization Setup'));
      });

      test('includes MaterialApp configuration', () {
        final result = generateLocalizationExamples();
        expect(result, contains('MaterialApp'));
        expect(result, contains('localizationsDelegates'));
        expect(result, contains('supportedLocales'));
      });

      test('includes flutter_localizations import', () {
        final result = generateLocalizationExamples();
        expect(result, contains('flutter_localizations'));
      });

      test('includes usage examples', () {
        final result = generateLocalizationExamples();
        expect(result, contains('Usage Examples'));
      });

      test('includes best practices section', () {
        final result = generateLocalizationExamples();
        expect(result, contains('Best Practices'));
      });

      test('includes common pitfalls', () {
        final result = generateLocalizationExamples();
        expect(result, contains('Common Pitfalls'));
      });

      test('includes ARB file examples', () {
        final result = generateLocalizationExamples();
        expect(result, contains('.arb'));
      });

      test('includes locale switching example', () {
        final result = generateLocalizationExamples();
        expect(result, contains('setLocale'));
      });

      test('includes comprehensive documentation', () {
        final result = generateLocalizationExamples();
        expect(result, contains('///'));
        expect(result.split('///').length, greaterThan(10));
      });
    });

    group('Code Quality', () {
      test('all generators return non-empty strings', () {
        expect(generateAdvancedLocaleManager(), isNotEmpty);
        expect(generateARBGenerator(), isNotEmpty);
        expect(generateRTLSupport(), isNotEmpty);
        expect(generateDynamicLocaleLoader(), isNotEmpty);
        expect(generateLocalizationExamples(), isNotEmpty);
      });

      test('all generators include proper imports', () {
        final localeManager = generateAdvancedLocaleManager();
        final arbGenerator = generateARBGenerator();
        final rtlSupport = generateRTLSupport();
        final localeLoader = generateDynamicLocaleLoader();

        expect(localeManager, contains('import '));
        expect(arbGenerator, contains('import '));
        expect(rtlSupport, contains('import '));
        expect(localeLoader, contains('import '));
      });

      test('all generators include class definitions', () {
        expect(generateAdvancedLocaleManager(), contains('class '));
        expect(generateARBGenerator(), contains('class '));
        expect(generateRTLSupport(), contains('class '));
        expect(generateDynamicLocaleLoader(), contains('class '));
      });

      test('all generators include documentation comments', () {
        expect(generateAdvancedLocaleManager(), contains('///'));
        expect(generateARBGenerator(), contains('///'));
        expect(generateRTLSupport(), contains('///'));
        expect(generateDynamicLocaleLoader(), contains('///'));
        expect(generateLocalizationExamples(), contains('///'));
      });

      test('no generators contain placeholder text', () {
        final generators = [
          generateAdvancedLocaleManager(),
          generateARBGenerator(),
          generateRTLSupport(),
          generateDynamicLocaleLoader(),
          generateLocalizationExamples(),
        ];

        for (final code in generators) {
          expect(code, isNot(contains('TODO')));
          expect(code, isNot(contains('FIXME')));
          expect(code, isNot(contains('XXX')));
        }
      });
    });

    group('Integration Tests', () {
      test('LocaleManager integrates with SharedPreferences', () {
        final result = generateAdvancedLocaleManager();
        expect(result, contains('SharedPreferences'));
        expect(result, contains('getInstance'));
      });

      test('ARBGenerator creates valid JSON structure', () {
        final result = generateARBGenerator();
        expect(result, contains('JsonEncoder'));
        expect(result, contains('@@locale'));
        expect(result, contains('@@last_modified'));
      });

      test('RTLSupport uses Flutter directionality', () {
        final result = generateRTLSupport();
        expect(result, contains('Directionality.of'));
        expect(result, contains('TextDirection'));
      });

      test('DynamicLocaleLoader handles async operations', () {
        final result = generateDynamicLocaleLoader();
        expect(result, contains('Future<'));
        expect(result, contains('async'));
        expect(result, contains('await'));
      });

      test('LocalizationExamples includes practical code', () {
        final result = generateLocalizationExamples();
        expect(result, contains('```dart'));
        expect(result, contains('```'));
      });
    });

    group('Feature Coverage', () {
      test('supports multiple locales', () {
        final result = generateAdvancedLocaleManager();
        expect(result, contains('Locale('));
        expect(result.split('Locale(').length, greaterThan(5));
      });

      test('supports RTL languages', () {
        final result = generateAdvancedLocaleManager();
        expect(result, contains('ar'));
        expect(result, contains('he'));
        expect(result, contains('fa'));
      });

      test('supports pluralization', () {
        final result = generateARBGenerator();
        expect(result, contains('zero'));
        expect(result, contains('one'));
        expect(result, contains('two'));
        expect(result, contains('few'));
        expect(result, contains('many'));
        expect(result, contains('other'));
      });

      test('supports gender-based translations', () {
        final result = generateARBGenerator();
        expect(result, contains('male'));
        expect(result, contains('female'));
        expect(result, contains('other'));
      });

      test('supports locale caching', () {
        final result = generateDynamicLocaleLoader();
        expect(result, contains('_cache'));
        expect(result, contains('containsKey'));
      });
    });

    group('Best Practices', () {
      test('uses async/await pattern correctly', () {
        final localeManager = generateAdvancedLocaleManager();
        final arbGenerator = generateARBGenerator();
        final localeLoader = generateDynamicLocaleLoader();

        expect(localeManager, contains('Future<'));
        expect(arbGenerator, contains('Future<'));
        expect(localeLoader, contains('Future<'));
      });

      test('includes error handling', () {
        final arbGenerator = generateARBGenerator();
        final localeLoader = generateDynamicLocaleLoader();

        expect(arbGenerator, contains('try'));
        expect(localeLoader, contains('catch'));
      });

      test('uses proper naming conventions', () {
        final all = [
          generateAdvancedLocaleManager(),
          generateARBGenerator(),
          generateRTLSupport(),
          generateDynamicLocaleLoader(),
        ];

        for (final code in all) {
          // Should use camelCase for methods
          expect(code, contains(RegExp(r'[a-z][a-zA-Z0-9]*\(')));
          // Should use PascalCase for classes
          expect(code, contains(RegExp(r'class [A-Z][a-zA-Z0-9]*')));
        }
      });

      test('includes proper const constructors where applicable', () {
        final rtlSupport = generateRTLSupport();
        expect(rtlSupport, contains('const '));
      });

      test('uses private members appropriately', () {
        final localeManager = generateAdvancedLocaleManager();
        final localeLoader = generateDynamicLocaleLoader();

        expect(localeManager, contains('_'));
        expect(localeLoader, contains('_'));
      });
    });
  });
}

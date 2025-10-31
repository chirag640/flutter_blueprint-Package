import 'package:flutter_blueprint/src/templates/template_library.dart';
import 'package:flutter_blueprint/src/config/blueprint_config.dart';
import 'package:test/test.dart';

void main() {
  group('ProjectTemplate', () {
    test('parses template names correctly', () {
      expect(ProjectTemplate.parse('blank'), ProjectTemplate.blank);
      expect(ProjectTemplate.parse('ecommerce'), ProjectTemplate.ecommerce);
      expect(
          ProjectTemplate.parse('social-media'), ProjectTemplate.socialMedia);
      expect(ProjectTemplate.parse('fitness-tracker'),
          ProjectTemplate.fitnessTracker);
      expect(ProjectTemplate.parse('finance-app'), ProjectTemplate.financeApp);
      expect(
          ProjectTemplate.parse('food-delivery'), ProjectTemplate.foodDelivery);
      expect(ProjectTemplate.parse('chat-app'), ProjectTemplate.chatApp);
    });

    test('throws on unknown template', () {
      expect(
        () => ProjectTemplate.parse('unknown'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('has correct labels', () {
      expect(ProjectTemplate.blank.label, 'Blank Project');
      expect(ProjectTemplate.ecommerce.label, 'E-Commerce App');
      expect(ProjectTemplate.socialMedia.label, 'Social Media App');
    });

    test('has descriptions for all templates', () {
      for (final template in ProjectTemplate.values) {
        expect(template.description.isNotEmpty, true);
      }
    });

    test('has features for all templates', () {
      for (final template in ProjectTemplate.values) {
        expect(template.features.isNotEmpty, true);
      }
    });
  });

  group('TemplateLibrary', () {
    late BlueprintConfig config;

    setUp(() {
      config = const BlueprintConfig(
        appName: 'test_app',
        platforms: [TargetPlatform.mobile],
        stateManagement: StateManagement.provider,
        includeTheme: true,
        includeLocalization: false,
        includeEnv: true,
        includeApi: true,
        includeTests: true,
      );
    });

    test('returns blank template', () {
      final bundle = TemplateLibrary.getTemplate(ProjectTemplate.blank, config);

      expect(bundle.files, isEmpty);
      expect(bundle.additionalDependencies, isEmpty);
      expect(bundle.requiredFeatures, contains('home'));
    });

    test('returns ecommerce template with correct dependencies', () {
      final bundle =
          TemplateLibrary.getTemplate(ProjectTemplate.ecommerce, config);

      expect(bundle.additionalDependencies.containsKey('cached_network_image'),
          true);
      expect(bundle.additionalDependencies.containsKey('shimmer'), true);
      expect(bundle.additionalDependencies.containsKey('badges'), true);
      expect(bundle.requiredFeatures, contains('products'));
      expect(bundle.requiredFeatures, contains('cart'));
      expect(bundle.requiredFeatures, contains('checkout'));
    });

    test('returns social media template with correct dependencies', () {
      final bundle =
          TemplateLibrary.getTemplate(ProjectTemplate.socialMedia, config);

      expect(bundle.additionalDependencies.containsKey('cached_network_image'),
          true);
      expect(bundle.additionalDependencies.containsKey('image_picker'), true);
      expect(bundle.additionalDependencies.containsKey('timeago'), true);
      expect(bundle.requiredFeatures, contains('posts'));
      expect(bundle.requiredFeatures, contains('comments'));
    });

    test('returns fitness tracker template with correct dependencies', () {
      final bundle =
          TemplateLibrary.getTemplate(ProjectTemplate.fitnessTracker, config);

      expect(bundle.additionalDependencies.containsKey('fl_chart'), true);
      expect(bundle.additionalDependencies.containsKey('table_calendar'), true);
      expect(bundle.requiredFeatures, contains('workouts'));
      expect(bundle.requiredFeatures, contains('progress'));
    });

    test('returns finance app template with correct dependencies', () {
      final bundle =
          TemplateLibrary.getTemplate(ProjectTemplate.financeApp, config);

      expect(bundle.additionalDependencies.containsKey('fl_chart'), true);
      expect(bundle.additionalDependencies.containsKey('currency_formatter'),
          true);
      expect(bundle.requiredFeatures, contains('transactions'));
      expect(bundle.requiredFeatures, contains('budgets'));
    });

    test('returns food delivery template with correct dependencies', () {
      final bundle =
          TemplateLibrary.getTemplate(ProjectTemplate.foodDelivery, config);

      expect(bundle.additionalDependencies.containsKey('cached_network_image'),
          true);
      expect(bundle.additionalDependencies.containsKey('flutter_rating_bar'),
          true);
      expect(bundle.requiredFeatures, contains('restaurants'));
      expect(bundle.requiredFeatures, contains('menu'));
    });

    test('returns chat app template with correct dependencies', () {
      final bundle =
          TemplateLibrary.getTemplate(ProjectTemplate.chatApp, config);

      expect(bundle.additionalDependencies.containsKey('image_picker'), true);
      expect(bundle.additionalDependencies.containsKey('file_picker'), true);
      expect(bundle.requiredFeatures, contains('chats'));
      expect(bundle.requiredFeatures, contains('messages'));
    });

    test('all templates return valid bundles', () {
      for (final template in ProjectTemplate.values) {
        final bundle = TemplateLibrary.getTemplate(template, config);

        expect(bundle, isNotNull);
        expect(bundle.files, isNotNull);
        expect(bundle.additionalDependencies, isNotNull);
        expect(bundle.requiredFeatures, isNotNull);
      }
    });
  });
}

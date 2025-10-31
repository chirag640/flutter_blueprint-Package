import '../config/blueprint_config.dart';
import 'template_bundle.dart';

/// Pre-built project templates for common use cases.
///
/// This library provides ready-to-use templates that scaffold complete
/// applications with domain-specific features, saving developers time
/// and providing best-practice examples.
enum ProjectTemplate {
  /// Blank project with just the basic architecture
  blank,

  /// E-commerce app with product catalog, cart, checkout, and payments
  ecommerce,

  /// Social media app with posts, comments, likes, and user profiles
  socialMedia,

  /// Fitness tracker with workouts, progress tracking, and charts
  fitnessTracker,

  /// Finance app with transactions, budgets, and analytics
  financeApp,

  /// Food delivery app with restaurant browsing, orders, and delivery tracking
  foodDelivery,

  /// Chat app with real-time messaging, notifications, and media sharing
  chatApp;

  String get label => switch (this) {
        ProjectTemplate.blank => 'Blank Project',
        ProjectTemplate.ecommerce => 'E-Commerce App',
        ProjectTemplate.socialMedia => 'Social Media App',
        ProjectTemplate.fitnessTracker => 'Fitness Tracker',
        ProjectTemplate.financeApp => 'Finance App',
        ProjectTemplate.foodDelivery => 'Food Delivery App',
        ProjectTemplate.chatApp => 'Chat App',
      };

  String get description => switch (this) {
        ProjectTemplate.blank =>
          'Basic architecture with a single home feature',
        ProjectTemplate.ecommerce =>
          'Product catalog, shopping cart, checkout, and payment integration',
        ProjectTemplate.socialMedia =>
          'User profiles, posts feed, comments, likes, and social interactions',
        ProjectTemplate.fitnessTracker =>
          'Workout tracking, progress charts, goal setting, and statistics',
        ProjectTemplate.financeApp =>
          'Transaction management, budgets, spending analytics, and reports',
        ProjectTemplate.foodDelivery =>
          'Restaurant browsing, menu ordering, cart, and delivery tracking',
        ProjectTemplate.chatApp =>
          'Real-time messaging, user presence, media sharing, and notifications',
      };

  /// Gets the list of features included in this template
  List<String> get features => switch (this) {
        ProjectTemplate.blank => ['Home screen', 'Basic navigation'],
        ProjectTemplate.ecommerce => [
            'Product listing',
            'Product details',
            'Shopping cart',
            'Checkout flow',
            'Order history',
            'User authentication',
            'Payment integration (mock)',
            'Search and filters',
          ],
        ProjectTemplate.socialMedia => [
            'User profiles',
            'Posts feed',
            'Create post',
            'Comments',
            'Likes system',
            'User authentication',
            'Image uploads',
            'Follow/Unfollow',
          ],
        ProjectTemplate.fitnessTracker => [
            'Workout logging',
            'Exercise library',
            'Progress charts',
            'Goal setting',
            'Statistics dashboard',
            'Calendar view',
            'Personal records',
            'Body measurements',
          ],
        ProjectTemplate.financeApp => [
            'Transaction list',
            'Add transaction',
            'Categories',
            'Budget management',
            'Spending analytics',
            'Monthly reports',
            'Recurring transactions',
            'Currency support',
          ],
        ProjectTemplate.foodDelivery => [
            'Restaurant list',
            'Restaurant details',
            'Menu browsing',
            'Shopping cart',
            'Order placement',
            'Order tracking',
            'User authentication',
            'Favorites',
          ],
        ProjectTemplate.chatApp => [
            'Chat list',
            'Chat room',
            'Send messages',
            'Media sharing',
            'User presence',
            'Push notifications',
            'User profiles',
            'Search contacts',
          ],
      };

  static ProjectTemplate parse(String value) {
    final normalized = value.trim().toLowerCase().replaceAll('-', '');
    for (final template in ProjectTemplate.values) {
      if (template.name.toLowerCase() == normalized ||
          template.label
                  .toLowerCase()
                  .replaceAll('-', '')
                  .replaceAll(' ', '') ==
              normalized) {
        return template;
      }
    }
    throw ArgumentError('Unknown template: $value');
  }
}

/// Factory for creating template bundles based on project template type.
class TemplateLibrary {
  /// Gets the template bundle for the specified template type.
  ///
  /// The bundle includes all necessary files and configurations for
  /// the selected template, customized for the provided configuration.
  static TemplateBundle getTemplate(
    ProjectTemplate template,
    BlueprintConfig config,
  ) {
    return switch (template) {
      ProjectTemplate.blank => _buildBlankTemplate(config),
      ProjectTemplate.ecommerce => _buildEcommerceTemplate(config),
      ProjectTemplate.socialMedia => _buildSocialMediaTemplate(config),
      ProjectTemplate.fitnessTracker => _buildFitnessTrackerTemplate(config),
      ProjectTemplate.financeApp => _buildFinanceAppTemplate(config),
      ProjectTemplate.foodDelivery => _buildFoodDeliveryTemplate(config),
      ProjectTemplate.chatApp => _buildChatAppTemplate(config),
    };
  }

  /// Builds a blank template with just the basic architecture.
  static TemplateBundle _buildBlankTemplate(BlueprintConfig config) {
    // This is the default template - no additional features
    return TemplateBundle(
      files: [],
      additionalDependencies: {},
      additionalDevDependencies: {},
      requiredFeatures: ['home'],
    );
  }

  /// Builds an e-commerce template with product catalog and checkout.
  static TemplateBundle _buildEcommerceTemplate(BlueprintConfig config) {
    return TemplateBundle(
      files: [],
      additionalDependencies: {
        'cached_network_image': '^3.3.0',
        'shimmer': '^3.0.0',
        'badges': '^3.1.0',
      },
      additionalDevDependencies: {},
      requiredFeatures: [
        'products',
        'cart',
        'checkout',
        'orders',
        'auth',
        'search',
      ],
    );
  }

  /// Builds a social media template with posts and interactions.
  static TemplateBundle _buildSocialMediaTemplate(BlueprintConfig config) {
    return TemplateBundle(
      files: [],
      additionalDependencies: {
        'cached_network_image': '^3.3.0',
        'image_picker': '^1.0.0',
        'timeago': '^3.5.0',
      },
      additionalDevDependencies: {},
      requiredFeatures: [
        'auth',
        'profile',
        'posts',
        'comments',
        'likes',
        'feed',
      ],
    );
  }

  /// Builds a fitness tracker template with workout logging.
  static TemplateBundle _buildFitnessTrackerTemplate(BlueprintConfig config) {
    return TemplateBundle(
      files: [],
      additionalDependencies: {
        'fl_chart': '^0.65.0',
        'table_calendar': '^3.0.9',
        'intl': '^0.18.0',
      },
      additionalDevDependencies: {},
      requiredFeatures: [
        'workouts',
        'exercises',
        'progress',
        'goals',
        'statistics',
        'calendar',
      ],
    );
  }

  /// Builds a finance app template with transaction management.
  static TemplateBundle _buildFinanceAppTemplate(BlueprintConfig config) {
    return TemplateBundle(
      files: [],
      additionalDependencies: {
        'fl_chart': '^0.65.0',
        'intl': '^0.18.0',
        'currency_formatter': '^2.2.0',
      },
      additionalDevDependencies: {},
      requiredFeatures: [
        'transactions',
        'categories',
        'budgets',
        'analytics',
        'reports',
      ],
    );
  }

  /// Builds a food delivery template with restaurant browsing.
  static TemplateBundle _buildFoodDeliveryTemplate(BlueprintConfig config) {
    return TemplateBundle(
      files: [],
      additionalDependencies: {
        'cached_network_image': '^3.3.0',
        'badges': '^3.1.0',
        'flutter_rating_bar': '^4.0.1',
      },
      additionalDevDependencies: {},
      requiredFeatures: [
        'restaurants',
        'menu',
        'cart',
        'orders',
        'tracking',
        'auth',
      ],
    );
  }

  /// Builds a chat app template with real-time messaging.
  static TemplateBundle _buildChatAppTemplate(BlueprintConfig config) {
    return TemplateBundle(
      files: [],
      additionalDependencies: {
        'image_picker': '^1.0.0',
        'file_picker': '^6.0.0',
        'timeago': '^3.5.0',
        'badges': '^3.1.0',
      },
      additionalDevDependencies: {},
      requiredFeatures: [
        'auth',
        'chats',
        'messages',
        'contacts',
        'media',
        'notifications',
      ],
    );
  }
}

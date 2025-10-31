# Developer Experience (DX) Features

This document describes the Developer Experience improvements implemented in flutter_blueprint v0.1.0.

## Table of Contents

1. [Interactive Preview Mode](#interactive-preview-mode)
2. [Smart Dependency Version Management](#smart-dependency-version-management)
3. [Project Templates Library](#project-templates-library)

---

## Interactive Preview Mode

### Overview

Show the complete project structure before generation, helping developers understand exactly what will be created.

### Usage

#### Command Line

```bash
# Show preview before generating
flutter_blueprint init my_app --preview

# Preview with specific configuration
flutter_blueprint init my_app --state bloc --platforms mobile,web --preview

# Preview with template
flutter_blueprint init my_store --template ecommerce --preview
```

#### Interactive Wizard

When using the interactive wizard mode, you'll be prompted:

```
👁️  Show project structure preview? (Y/n)
```

### What You'll See

The preview displays:

1. **Complete Directory Tree**

   - All folders and files that will be created
   - Emoji indicators for file types (📁 folders, 📄 files)
   - State management-specific files highlighted

2. **Project Statistics**

   - Total number of files
   - Breakdown by type (Dart files, config files, test files)
   - Estimated project size
   - Estimated generation time

3. **Configuration Summary**

   - App name
   - Target platforms
   - State management choice
   - CI/CD provider
   - Enabled features

4. **Platform-Specific Notes**
   - Web-specific features
   - Desktop integration details
   - Mobile-specific configurations

### Example Output

```
📋 Project Structure Preview
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📁 my_app/
├── 📁 lib/
│   ├── 📄 main.dart
│   ├── 📁 features/
│   │   └── 📁 home/
│   │       ├── 📁 data/
│   │       │   ├── 📄 home_repository.dart
│   │       │   └── 📄 home_model.dart
│   │       ├── 📁 domain/
│   │       │   ├── 📄 home_entity.dart
│   │       │   └── 📄 home_usecase.dart
│   │       └── 📁 presentation/
│   │           ├── 📄 home_page.dart
│   │           └── 📄 home_bloc.dart
│   ├── 📁 core/
│   │   ├── 📁 routing/
│   │   │   └── 📄 app_router.dart
│   │   ├── 📁 theme/
│   │   │   ├── 📄 app_theme.dart
│   │   │   └── 📄 color_schemes.dart
│   │   └── 📁 network/
│   │       └── 📄 api_client.dart
├── 📁 test/
│   └── 📁 features/
├── 📄 pubspec.yaml
└── 📄 README.md

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 Project Statistics:
   • Total files: 47
   • Dart files: 32
   • Config files: 8
   • Test files: 7
   • Estimated size: ~2.5 MB
   • Generation time: ~8s

⚙️  Configuration:
   • App name: my_app
   • Platforms: mobile
   • State management: bloc
   • CI/CD: github

✨ Features included:
   ✅ Theme system (Light/Dark modes)
   ✅ API client (Dio + interceptors)
   ✅ Test scaffolding
```

### Benefits

- **Clarity**: See exactly what you're getting before generation
- **Learning**: Understand Flutter project architecture
- **Confidence**: No surprises after generation
- **Planning**: Estimate project size and complexity

---

## Smart Dependency Version Management

### Overview

Automatically fetch the latest compatible versions of dependencies from pub.dev, ensuring your project starts with up-to-date, secure packages.

### Usage

#### Command Line

```bash
# Fetch latest versions during generation
flutter_blueprint init my_app --latest-deps

# Combine with other flags
flutter_blueprint init my_app --state riverpod --latest-deps

# Works with templates
flutter_blueprint init my_store --template ecommerce --latest-deps
```

#### Interactive Wizard

You'll be prompted:

```
🔍 Fetch latest dependency versions from pub.dev? (y/N)
```

### What Happens

1. **Parallel Fetching**: All package versions are fetched simultaneously for speed
2. **Smart Timeout**: 10-second timeout per package prevents hanging
3. **Graceful Fallback**: If a version can't be fetched, uses 'latest' placeholder
4. **Real-time Feedback**: Shows progress as versions are retrieved

### Example Output

```
🔍 Fetching latest dependency versions from pub.dev...

✓ provider: ^6.1.1
✓ dio: ^5.4.0
✓ flutter_bloc: ^8.1.3
✓ go_router: ^13.0.0
✓ flutter_lints: ^3.0.1

✅ Successfully fetched 5 package versions
```

### Supported Packages

The system automatically fetches versions for:

**Core Dependencies:**

- `flutter_lints`
- `go_router`

**State Management:**

- `provider` (for Provider projects)
- `flutter_riverpod`, `riverpod_annotation` (for Riverpod projects)
- `flutter_bloc`, `bloc`, `equatable` (for Bloc projects)

**Optional Packages:**

- `dio`, `pretty_dio_logger` (when API is enabled)
- `intl` (when localization is enabled)

### API Usage (Programmatic)

```dart
import 'package:flutter_blueprint/flutter_blueprint.dart';

final depManager = DependencyManager();

// Fetch specific packages
final versions = await depManager.getLatestVersions([
  'provider',
  'dio',
  'flutter_bloc',
]);

// Get recommended dependencies for a configuration
final recommended = await depManager.getRecommendedDependencies(
  stateManagement: 'riverpod',
  includeApi: true,
  includeLocalization: true,
);

// Check for updates in existing project
final currentDeps = {
  'provider': '^6.0.0',
  'dio': '^5.3.0',
};

final updates = await depManager.checkForUpdates(currentDeps);

for (final update in updates.values) {
  print(update); // provider: 6.0.0 → 6.1.1 ⚠️ Update available
}

// Clean up
depManager.close();
```

### Benefits

- **Security**: Start with the latest security patches
- **Compatibility**: Avoid version conflicts from outdated packages
- **Convenience**: No manual pub.dev browsing required
- **Best Practices**: Always use recommended versions

### Implementation Details

- Uses pub.dev's public API (`https://pub.dev/api/packages/{package}`)
- Implements proper User-Agent header
- Respects API rate limits
- Handles network errors gracefully
- Uses HttpClient for efficient connection pooling

---

## Project Templates Library

### Overview

Pre-built templates for common application types, providing complete feature sets and domain-specific architecture.

### Available Templates

| Template            | Description              | Features                                  |
| ------------------- | ------------------------ | ----------------------------------------- |
| **Blank**           | Basic architecture only  | Home screen, navigation                   |
| **E-Commerce**      | Online store application | Products, cart, checkout, orders, auth    |
| **Social Media**    | Social networking app    | Posts, comments, likes, profiles, feed    |
| **Fitness Tracker** | Workout logging app      | Workouts, exercises, progress, goals      |
| **Finance App**     | Personal finance manager | Transactions, budgets, analytics, reports |
| **Food Delivery**   | Restaurant ordering app  | Restaurants, menu, cart, tracking         |
| **Chat App**        | Messaging application    | Chats, messages, media, notifications     |

### Usage

#### Command Line

```bash
# E-Commerce template
flutter_blueprint init my_store --template ecommerce

# Social Media template
flutter_blueprint init my_social --template social-media

# Fitness Tracker template
flutter_blueprint init my_fitness --template fitness-tracker

# Finance App template
flutter_blueprint init my_budget --template finance-app

# Food Delivery template
flutter_blueprint init my_food --template food-delivery

# Chat App template
flutter_blueprint init my_chat --template chat-app

# Combine with other flags
flutter_blueprint init my_store --template ecommerce --state bloc --preview
```

#### Interactive Wizard

Choose from the template list during setup:

```
📦 Choose a project template
  > Blank - Basic architecture
    E-Commerce - Product catalog & checkout
    Social Media - Posts, comments & likes
    Fitness Tracker - Workout logging & progress
    Finance App - Transaction management
    Food Delivery - Restaurant & order tracking
    Chat App - Real-time messaging
```

### Template Details

#### 🛒 E-Commerce Template

**Features:**

- Product listing with search and filters
- Product details with images
- Shopping cart with quantity management
- Checkout flow with payment integration (mock)
- Order history and tracking
- User authentication
- Favorites/wishlist

**Additional Dependencies:**

- `cached_network_image` - Image caching
- `shimmer` - Loading placeholders
- `badges` - Cart badge indicators

**Generated Features:**

- `products` - Product catalog
- `cart` - Shopping cart
- `checkout` - Payment flow
- `orders` - Order management
- `auth` - User authentication
- `search` - Product search

---

#### 📱 Social Media Template

**Features:**

- User profiles with bio and avatar
- Posts feed (timeline)
- Create/edit/delete posts
- Comments and replies
- Like system
- Image uploads
- Follow/unfollow users

**Additional Dependencies:**

- `cached_network_image` - Image caching
- `image_picker` - Camera/gallery access
- `timeago` - Relative timestamps

**Generated Features:**

- `auth` - User authentication
- `profile` - User profiles
- `posts` - Post management
- `comments` - Comment system
- `likes` - Like functionality
- `feed` - Timeline/feed

---

#### 💪 Fitness Tracker Template

**Features:**

- Workout logging
- Exercise library with instructions
- Progress charts (weight, reps, etc.)
- Goal setting and tracking
- Statistics dashboard
- Calendar view of workouts
- Personal records
- Body measurements tracking

**Additional Dependencies:**

- `fl_chart` - Charts and graphs
- `table_calendar` - Calendar widget
- `intl` - Date formatting

**Generated Features:**

- `workouts` - Workout management
- `exercises` - Exercise library
- `progress` - Progress tracking
- `goals` - Goal setting
- `statistics` - Stats dashboard
- `calendar` - Workout calendar

---

#### 💰 Finance App Template

**Features:**

- Transaction list and details
- Add/edit transactions
- Category management
- Budget creation and tracking
- Spending analytics
- Monthly/yearly reports
- Recurring transactions
- Multiple currency support

**Additional Dependencies:**

- `fl_chart` - Spending charts
- `intl` - Number/date formatting
- `currency_formatter` - Currency display

**Generated Features:**

- `transactions` - Transaction management
- `categories` - Category system
- `budgets` - Budget tracking
- `analytics` - Spending analysis
- `reports` - Financial reports

---

#### 🍕 Food Delivery Template

**Features:**

- Restaurant browsing with filters
- Restaurant details and ratings
- Menu browsing with categories
- Shopping cart
- Order placement and tracking
- Delivery address management
- Favorites/saved restaurants
- Order history

**Additional Dependencies:**

- `cached_network_image` - Food images
- `badges` - Cart indicator
- `flutter_rating_bar` - Restaurant ratings

**Generated Features:**

- `restaurants` - Restaurant listing
- `menu` - Menu browsing
- `cart` - Order cart
- `orders` - Order management
- `tracking` - Delivery tracking
- `auth` - User authentication

---

#### 💬 Chat App Template

**Features:**

- Chat list with previews
- One-on-one chat rooms
- Send/receive messages
- Media sharing (images, files)
- User online/offline status
- Push notifications
- User profiles
- Contact search

**Additional Dependencies:**

- `image_picker` - Media sharing
- `file_picker` - File attachments
- `timeago` - Message timestamps
- `badges` - Unread indicators

**Generated Features:**

- `auth` - User authentication
- `chats` - Chat list
- `messages` - Messaging
- `contacts` - Contact management
- `media` - Media handling
- `notifications` - Push notifications

### Programmatic API

```dart
import 'package:flutter_blueprint/flutter_blueprint.dart';

// Get template information
final template = ProjectTemplate.ecommerce;
print(template.label);        // "E-Commerce App"
print(template.description);  // "Product catalog, shopping cart..."
print(template.features);     // List of features

// Get template bundle
final config = BlueprintConfig(
  appName: 'my_store',
  // ... other config
);

final bundle = TemplateLibrary.getTemplate(template, config);

// Access template data
final dependencies = bundle.additionalDependencies;
final features = bundle.requiredFeatures;

// Parse template from string
final parsed = ProjectTemplate.parse('ecommerce');
```

### Benefits

- **Time Saving**: Get a complete app structure in minutes
- **Best Practices**: Learn from well-architected examples
- **Domain Knowledge**: Pre-configured features for specific domains
- **Customizable**: Generated code is fully modifiable
- **Learning Tool**: Study how features are implemented

### Future Enhancements

Templates will be enhanced in future versions to include:

- Actual feature code generation (currently shows note)
- Pre-configured API endpoints
- Sample data and mocks
- Advanced state management patterns
- Integration tests
- Documentation

---

## Integration Examples

### Complete Workflow Example

```bash
# Create an e-commerce app with all DX features
flutter_blueprint init my_store \
  --template ecommerce \
  --state bloc \
  --platforms mobile,web \
  --preview \
  --latest-deps \
  --ci github

# This will:
# 1. Select the e-commerce template
# 2. Show project structure preview
# 3. Fetch latest dependency versions
# 4. Generate the project
# 5. Add GitHub Actions CI/CD
```

### Interactive Wizard with All Features

```bash
flutter_blueprint init

# Wizard will guide you through:
# 1. Template selection (with descriptions)
# 2. App name validation
# 3. Platform selection
# 4. State management choice
# 5. CI/CD provider
# 6. Feature toggles
# 7. Preview option
# 8. Latest dependencies option
# 9. Final confirmation
# 10. Generation with progress
```

---

## Testing

All DX features include comprehensive test coverage:

```bash
# Run all DX feature tests
dart test test/src/utils/project_preview_test.dart
dart test test/src/templates/template_library_test.dart

# Run all tests
dart test
```

Test Coverage:

- ✅ Project preview generation
- ✅ Multi-platform previews
- ✅ State management variants
- ✅ Template parsing
- ✅ Template bundles
- ✅ Dependency structures

---

## Troubleshooting

### Preview Not Showing

**Issue**: Preview flag doesn't show anything

**Solution**:

```bash
# Make sure flag is spelled correctly
flutter_blueprint init my_app --preview  # ✅ Correct
flutter_blueprint init my_app --preveiw  # ❌ Typo
```

### Dependency Fetch Timeout

**Issue**: Dependency fetching takes too long or hangs

**Solution**:

- Check internet connection
- Pub.dev might be temporarily down
- Proceed without `--latest-deps` and run `flutter pub upgrade` later

### Template Not Found

**Issue**: `Unknown template: xyz`

**Solution**:

```bash
# Use correct template names (with hyphens)
flutter_blueprint init my_app --template social-media  # ✅
flutter_blueprint init my_app --template socialmedia   # ❌
```

**Valid template names:**

- `blank`
- `ecommerce`
- `social-media`
- `fitness-tracker`
- `finance-app`
- `food-delivery`
- `chat-app`

---

## API Reference

### ProjectPreview

```dart
class ProjectPreview {
  ProjectPreview({Logger? logger});

  void show(BlueprintConfig config);
}
```

### DependencyManager

```dart
class DependencyManager {
  DependencyManager({Logger? logger, HttpClient? httpClient});

  Future<Map<String, String>> getLatestVersions(List<String> packages);
  Future<Map<String, String>> getRecommendedDependencies({
    required String stateManagement,
    required bool includeApi,
    required bool includeLocalization,
  });
  Future<Map<String, DependencyUpdate>> checkForUpdates(
    Map<String, String> currentDependencies,
  );

  void close();
}
```

### TemplateLibrary

```dart
enum ProjectTemplate {
  blank, ecommerce, socialMedia, fitnessTracker,
  financeApp, foodDelivery, chatApp;

  String get label;
  String get description;
  List<String> get features;

  static ProjectTemplate parse(String value);
}

class TemplateLibrary {
  static TemplateBundle getTemplate(
    ProjectTemplate template,
    BlueprintConfig config,
  );
}
```

---

## See Also

- [Main README](../README.md)
- [CONTRIBUTING.md](../CONTRIBUTING.md)
- [EXAMPLES.md](../EXAMPLES.md)
- [Security Audit Report](SECURITY_AUDIT_REPORT.md)
- [Enhancement Suggestions](ENHANCEMENT_SUGGESTIONS.md)

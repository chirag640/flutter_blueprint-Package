# flutter_blueprint Example

This example demonstrates how to use the `flutter_blueprint` CLI tool to generate a production-ready Flutter project.

## Basic Usage

### Installation

First, activate the package globally:

```bash
dart pub global activate flutter_blueprint
```

### Create a Simple Project

Generate a basic Flutter project with Provider state management:

```bash
flutter_blueprint init my_app
```

This launches an interactive wizard that guides you through the configuration.

### Create a Multi-Platform Project

Generate a project that supports mobile, web, and desktop:

```bash
flutter_blueprint init my_awesome_app \
  --state provider \
  --platforms all \
  --theme \
  --localization \
  --env \
  --api \
  --tests \
  --ci github
```

### Create with Riverpod State Management

```bash
flutter_blueprint init my_riverpod_app \
  --state riverpod \
  --platforms mobile,web \
  --theme \
  --api \
  --tests
```

### Add a New Feature

After creating a project, add new features incrementally:

```bash
cd my_app
flutter_blueprint add feature authentication --api
```

## Generated Project Structure

```
my_app/
├── lib/
│   ├── main.dart
│   ├── app/
│   │   └── app.dart
│   ├── core/
│   │   ├── api/
│   │   ├── config/
│   │   ├── routing/
│   │   ├── theme/
│   │   └── utils/
│   └── features/
│       └── home/
├── test/
├── assets/
└── pubspec.yaml
```

## Running the Generated Project

```bash
cd my_app
flutter pub get
flutter run
```

For web:

```bash
flutter run -d chrome
```

For desktop:

```bash
flutter run -d windows  # or macos, linux
```

## Running Tests

```bash
cd my_app
flutter test
```

## Team Collaboration Examples

### Using Shared Configurations

Flutter Blueprint includes powerful team collaboration features through shared configurations.

#### List Available Configurations

```bash
flutter_blueprint share list
```

**Output:**

```
Available shared configurations:

1. company_standard (v1.0.0)
   State: bloc | Platforms: android, ios, web, windows, macos, linux | CI/CD: github
   Description: Enterprise-grade company-wide Flutter project standards with comprehensive testing
   Author: Engineering Team | Updated: 2025-11-01

2. startup_template (v1.0.0)
   State: provider | Platforms: android, ios, web | CI/CD: github
   Description: Lightweight MVP configuration for rapid prototyping and quick iterations
   Author: Startup Team | Updated: 2025-11-01

3. enterprise_template (v1.0.0)
   State: riverpod | Platforms: android, ios, web, windows, macos, linux | CI/CD: azure
   Description: Full-featured configuration for large-scale applications with strict code standards
   Author: Enterprise Team | Updated: 2025-11-01
```

#### Create Project from Shared Configuration

Use a team-standard configuration to create a new project:

```bash
flutter_blueprint init my_new_app --from-config company_standard
```

This creates a project with all settings from the shared configuration:

- ✅ Bloc state management pre-configured
- ✅ All platforms enabled
- ✅ GitHub Actions CI/CD configured
- ✅ Clean architecture enforced
- ✅ Required packages included

#### Import a Configuration

Import a configuration file from your team repository:

```bash
# Import with default name (from file)
flutter_blueprint share import ./configs/company_standard.yaml

# Import with custom name
flutter_blueprint share import ./configs/mobile_only.yaml --name mobile_config
```

#### Export a Configuration

Export a configuration to share with team members:

```bash
# Export to a file
flutter_blueprint share export company_standard ./shared_config.yaml

# Share the file with your team (commit to repo, send via email, etc.)
```

#### Validate Configuration Before Use

Always validate configurations before importing:

```bash
flutter_blueprint share validate ./new_config.yaml
```

**Output:**

```
✅ Configuration is valid!

Configuration details:
- Name: company_standard
- Version: 1.0.0
- State Management: bloc
- Platforms: android, ios, web, windows, macos, linux
- CI/CD: github
- Required Packages: 5
- Line Length: 120

Ready to import!
```

### Team Workflow Example

#### Scenario: New Team Member Onboarding

**Step 1: Clone team repository**

```bash
git clone https://github.com/company/mobile-configs.git
cd mobile-configs
```

**Step 2: Import shared configurations**

```bash
# Import the main company standard
flutter_blueprint share import ./company_standard.yaml

# Import specialized configs if needed
flutter_blueprint share import ./mobile_only.yaml
flutter_blueprint share import ./web_app.yaml
```

**Step 3: Create new project using shared config**

```bash
# Create a new feature with company standards
flutter_blueprint init user_authentication --from-config company_standard

# Project is instantly configured with all team standards! ✨
```

**Result:**

- New developer is productive in **5 minutes** instead of 4 hours
- No manual setup or configuration needed
- Guaranteed consistency with team standards

#### Scenario: Updating Team Standards

**Step 1: Engineering lead updates configuration**

```bash
# Export current config
flutter_blueprint share export company_standard ./company_standard.yaml

# Edit the YAML file to update standards
# (e.g., change line_length from 80 to 120)

# Validate changes
flutter_blueprint share validate ./company_standard.yaml

# Re-import updated config
flutter_blueprint share import ./company_standard.yaml
```

**Step 2: Commit and push to team repo**

```bash
git add company_standard.yaml
git commit -m "Update line length standard to 120"
git push
```

**Step 3: Team members update their configs**

```bash
# Pull latest changes
git pull

# Re-import updated config
flutter_blueprint share import ./company_standard.yaml

# New projects use updated standards automatically
```

### Configuration Customization Examples

#### Example 1: Mobile-Only Configuration

```yaml
name: mobile_only
description: Lightweight configuration for mobile-first apps
version: 1.0.0
author: Mobile Team

state_management: provider
platforms:
  - android
  - ios

cicd_provider: github

code_style:
  line_length: 100
  prefer_single_quotes: true

required_packages:
  - dio
  - provider

metadata:
  team: mobile_team
  focus: rapid_prototyping
```

**Usage:**

```bash
flutter_blueprint share import ./mobile_only.yaml
flutter_blueprint init my_mobile_app --from-config mobile_only
```

#### Example 2: Enterprise Full-Stack Configuration

```yaml
name: enterprise_fullstack
description: Enterprise-grade full-stack Flutter application
version: 2.0.0
author: Enterprise Architecture Team

state_management: riverpod
platforms:
  - android
  - ios
  - web
  - windows
  - macos
  - linux

cicd_provider: azure

code_style:
  line_length: 120
  prefer_single_quotes: true
  use_trailing_commas: true

architecture:
  enforce_clean_architecture: true
  feature_structure: domain_driven
  use_dependency_injection: true

required_packages:
  - flutter_riverpod
  - freezed
  - dio
  - get_it
  - injectable
  - go_router
  - hive
  - firebase_core

testing:
  require_unit_tests: true
  require_widget_tests: true
  require_integration_tests: true
  min_coverage: 85

metadata:
  team: enterprise_engineering
  compliance: iso27001
  security_level: high
```

**Usage:**

```bash
flutter_blueprint share import ./enterprise_fullstack.yaml
flutter_blueprint init banking_app --from-config enterprise_fullstack
```

#### Example 3: Startup MVP Configuration

```yaml
name: startup_mvp
description: Fast MVP development for startups
version: 1.0.0
author: Startup Team

state_management: provider # Simple and fast
platforms:
  - android
  - ios
  - web # Quick web demo

cicd_provider: github

code_style:
  line_length: 100
  prefer_single_quotes: true

required_packages:
  - provider
  - dio
  - shared_preferences

testing:
  require_unit_tests: false # Speed over coverage for MVP
  require_widget_tests: false

metadata:
  team: startup
  stage: mvp
  priority: speed
```

**Usage:**

```bash
flutter_blueprint share import ./startup_mvp.yaml
flutter_blueprint init quick_prototype --from-config startup_mvp
```

### Benefits Summary

| Task              | Without Shared Config | With Shared Config   |
| ----------------- | --------------------- | -------------------- |
| **Project Setup** | 2-4 hours             | 5 minutes ⚡         |
| **Consistency**   | Manual enforcement    | Automatic ✅         |
| **Onboarding**    | 1-2 days              | 30 minutes 🚀        |
| **Updates**       | Email all devs        | One git pull 📦      |
| **Standards**     | Wiki documentation    | Executable config 💪 |

## More Examples

See [EXAMPLES.md](../EXAMPLES.md) for comprehensive examples including:

- E-commerce mobile apps
- Multi-platform SaaS applications
- Desktop dashboards
- Progressive Web Apps (PWA)
- CI/CD integration examples

See [COLLABORATION_FEATURES.md](../COLLABORATION_FEATURES.md) for complete collaboration documentation including:

- Advanced configuration options
- Version control best practices
- Multi-team workflows
- Configuration validation
- Security considerations

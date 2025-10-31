# Collaboration & Team Features

This document describes flutter_blueprint's powerful collaboration features that enable teams to share configurations, maintain consistency across projects, and standardize development practices.

## Table of Contents

- [Overview](#overview)
- [Shared Blueprint Configurations](#shared-blueprint-configurations)
- [Getting Started](#getting-started)
- [Managing Configurations](#managing-configurations)
- [Using Shared Configurations](#using-shared-configurations)
- [Configuration Structure](#configuration-structure)
- [Best Practices](#best-practices)
- [Examples](#examples)
- [API Reference](#api-reference)

---

## Overview

Collaboration features in flutter_blueprint allow teams to:

- **Standardize project structure** across the organization
- **Share best practices** through configuration templates
- **Maintain consistency** in code style and architecture
- **Accelerate onboarding** with pre-configured templates
- **Enforce standards** at project creation time
- **Version control** configuration changes

---

## Shared Blueprint Configurations

Shared configurations are YAML files that define team-wide defaults for:

- State management solution
- Target platforms
- CI/CD provider
- Feature inclusion (theme, localization, API, tests, etc.)
- Required packages
- Code style preferences
- Architecture patterns
- Custom metadata

### Key Benefits

1. **Consistency**: All projects start with the same foundation
2. **Speed**: Skip the configuration phase, start coding immediately
3. **Quality**: Enforce best practices from day one
4. **Collaboration**: Share knowledge through configuration
5. **Flexibility**: Different configs for different project types

---

## Getting Started

### Installation

flutter_blueprint includes collaboration features out of the box. No additional installation required.

### Quick Start

#### 1. List Available Configurations

```bash
flutter_blueprint share list
```

#### 2. Create a Project from a Shared Configuration

```bash
flutter_blueprint init my_app --from-config company_standard
```

#### 3. Create Your Own Configuration

```bash
# Navigate to an existing project
cd my_existing_project

# Create a configuration from it
flutter_blueprint share config my_team_standard
```

---

## Managing Configurations

### Listing Configurations

View all available shared configurations:

```bash
flutter_blueprint share list
```

Output example:

```
📋 Available configurations:

  • company_standard
    Version: 1.0.0
    Author: Engineering Team
    Description: Standard configuration for enterprise Flutter projects
    Path: ~/.flutter_blueprint/configs/company_standard.yaml

  • startup_template
    Version: 1.0.0
    Author: Startup Team
    Description: Lightweight configuration for rapid MVP development
    Path: ~/.flutter_blueprint/configs/startup_template.yaml

Use with: flutter_blueprint init my_app --from-config <name>
```

### Creating Configurations

#### From an Existing Project

The easiest way to create a configuration is from a project you've already set up:

```bash
cd my_existing_project
flutter_blueprint share config my_custom_config
```

You'll be prompted for:

- Version number (default: 1.0.0)
- Author name
- Description

#### Manually Creating a Configuration File

Create a YAML file with the required structure:

```yaml
name: my_config
version: 1.0.0
author: Your Name
description: My custom configuration

defaults:
  state_management: riverpod
  platforms:
    - mobile
    - web
  ci_provider: github
  include_theme: true
  include_localization: true
  include_env: true
  include_api: true
  include_tests: true

required_packages:
  - dio
  - shared_preferences
  - go_router

code_style:
  line_length: 80
  prefer_const: true

architecture:
  naming_convention: snake_case
```

Then import it:

```bash
flutter_blueprint share import ./my_config.yaml
```

### Exporting Configurations

Export a configuration to share with your team:

```bash
flutter_blueprint share export company_standard ./team/configs/standard.yaml
```

This creates a copy of the configuration at the specified path, which can be:

- Committed to version control
- Shared via email or chat
- Stored on a shared drive
- Used directly with `--from-config`

### Importing Configurations

Import a configuration from a file:

```bash
# Import with automatic name detection
flutter_blueprint share import ./configs/standard.yaml

# Import with custom name
flutter_blueprint share import ./configs/standard.yaml my_standard
```

### Validating Configurations

Before using or sharing a configuration, validate it:

```bash
flutter_blueprint share validate company_standard.yaml
```

Output example:

```
🔍 Validating configuration...

✅ Configuration is valid

Warnings:
  ⚠️  Missing recommended field: version
```

### Deleting Configurations

Remove a configuration you no longer need:

```bash
flutter_blueprint share delete old_config
```

You'll be prompted for confirmation:

```
Delete configuration "old_config"? (y/N):
```

---

## Using Shared Configurations

### Basic Usage

Create a new project using a shared configuration:

```bash
flutter_blueprint init my_app --from-config company_standard
```

### With Additional Options

Combine `--from-config` with other flags:

```bash
# With preview
flutter_blueprint init my_app --from-config company_standard --preview

# With latest dependencies
flutter_blueprint init my_app --from-config startup_template --latest-deps

# With template
flutter_blueprint init my_shop --from-config enterprise_template --template ecommerce
```

### Direct Path Usage

Use a configuration file directly without importing:

```bash
flutter_blueprint init my_app --from-config ./configs/custom.yaml
```

### From Version Control

Teams can commit configurations to their repository:

```bash
# Clone repo with configuration
git clone https://github.com/company/configs.git

# Use the configuration
flutter_blueprint init my_app --from-config ./configs/company_standard.yaml
```

---

## Configuration Structure

### Complete YAML Structure

```yaml
# Required fields
name: my_configuration
version: 1.0.0
author: Team Name
description: Description of this configuration

# Project defaults
defaults:
  # State management: provider, riverpod, or bloc
  state_management: riverpod

  # Target platforms: mobile, web, desktop
  platforms:
    - mobile
    - web
    - desktop

  # CI/CD provider: github, gitlab, azure, or none
  ci_provider: github

  # Feature flags
  include_theme: true
  include_localization: true
  include_env: true
  include_api: true
  include_tests: true

# Optional: Required packages
required_packages:
  - dio
  - shared_preferences
  - flutter_secure_storage
  - cached_network_image
  - intl
  - go_router

# Optional: Code style preferences
code_style:
  line_length: 80
  prefer_const: true

# Optional: Architecture preferences
architecture:
  # Naming convention: snake_case, camelCase, or PascalCase
  naming_convention: snake_case

# Optional: Custom metadata
metadata:
  organization: "Company Name"
  team: "Mobile Team"
  support_email: "support@example.com"
  documentation_url: "https://wiki.example.com/mobile"
```

### Field Descriptions

#### Required Fields

- **name**: Unique identifier for the configuration
- **version**: Semantic version (e.g., "1.0.0")
- **author**: Person or team who created the configuration
- **description**: Brief explanation of the configuration's purpose

#### Defaults Section

- **state_management**: State solution (`provider`, `riverpod`, `bloc`)
- **platforms**: List of platforms (`mobile`, `web`, `desktop`)
- **ci_provider**: CI/CD system (`github`, `gitlab`, `azure`, `none`)
- **include_theme**: Whether to include theme scaffolding
- **include_localization**: Whether to include i18n setup
- **include_env**: Whether to include environment configuration
- **include_api**: Whether to include API client setup
- **include_tests**: Whether to include test scaffolding

#### Optional Sections

- **required_packages**: List of packages that must be included
- **code_style**: Formatting preferences
- **architecture**: Structural preferences
- **metadata**: Any custom key-value pairs

---

## Best Practices

### For Individual Developers

1. **Start with Examples**: Use provided templates as a starting point
2. **Document Decisions**: Add metadata explaining your choices
3. **Version Control**: Store configs in your project repository
4. **Validate Before Use**: Always run `validate` before using a config

### For Teams

1. **Central Repository**: Maintain configs in a shared location
2. **Naming Convention**: Use clear, descriptive names (e.g., `mobile_standard_v2`)
3. **Version Regularly**: Update version numbers when changing configs
4. **Multiple Configs**: Create different configs for different project types
5. **Review Process**: Require review before updating shared configs
6. **Documentation**: Maintain a README explaining when to use each config

### For Organizations

1. **Governance**: Define who can modify standard configurations
2. **Training**: Document usage patterns and provide examples
3. **Regular Updates**: Review and update configs quarterly
4. **Compliance**: Include compliance requirements in metadata
5. **Monitoring**: Track which configs are being used
6. **Support**: Provide a support channel for configuration questions

### Configuration Versioning Strategy

```yaml
# Good: Semantic versioning
version: 1.0.0  # Major.Minor.Patch

# Update major for breaking changes (e.g., state management switch)
version: 2.0.0

# Update minor for new features (e.g., new required packages)
version: 1.1.0

# Update patch for fixes (e.g., correcting package names)
version: 1.0.1
```

---

## Examples

### Example 1: Company Standard Configuration

**Use case**: Enterprise projects with full feature set

```yaml
name: company_standard
version: 1.0.0
author: Engineering Team
description: Standard configuration for enterprise Flutter projects

defaults:
  state_management: riverpod
  platforms:
    - mobile
    - web
  ci_provider: github
  include_theme: true
  include_localization: true
  include_env: true
  include_api: true
  include_tests: true

required_packages:
  - dio
  - shared_preferences
  - flutter_secure_storage
  - cached_network_image
  - intl
  - go_router

code_style:
  line_length: 80
  prefer_const: true

architecture:
  naming_convention: snake_case

metadata:
  organization: "My Company Inc"
  team: "Mobile Development"
  support_email: "mobile-dev@company.com"
```

**Usage**:

```bash
flutter_blueprint init corporate_app --from-config company_standard
```

### Example 2: Startup Template

**Use case**: MVP development, rapid iteration

```yaml
name: startup_template
version: 1.0.0
author: Startup Team
description: Lightweight configuration for rapid MVP development

defaults:
  state_management: provider
  platforms:
    - mobile
  ci_provider: github
  include_theme: true
  include_localization: false
  include_env: true
  include_api: true
  include_tests: true

required_packages:
  - http
  - shared_preferences
  - flutter_svg

code_style:
  line_length: 100
  prefer_const: true

architecture:
  naming_convention: camelCase

metadata:
  philosophy: "Move fast, iterate quickly"
  focus: "MVP features first, optimization later"
```

**Usage**:

```bash
flutter_blueprint init mvp_app --from-config startup_template
```

### Example 3: Mobile-Only Configuration

**Use case**: Mobile-first apps with no web/desktop requirements

```yaml
name: mobile_only
version: 1.0.0
author: Mobile Team
description: Optimized for mobile-only applications

defaults:
  state_management: bloc
  platforms:
    - mobile
  ci_provider: github
  include_theme: true
  include_localization: true
  include_env: true
  include_api: true
  include_tests: true

required_packages:
  - dio
  - shared_preferences
  - flutter_secure_storage
  - cached_network_image
  - permission_handler
  - geolocator
  - camera

code_style:
  line_length: 80
  prefer_const: true

architecture:
  naming_convention: snake_case

metadata:
  target_audience: "Mobile users only"
  minimum_sdk: "Android 21, iOS 12"
```

**Usage**:

```bash
flutter_blueprint init mobile_app --from-config mobile_only
```

---

## API Reference

### Command Line Interface

#### `flutter_blueprint share list`

Lists all available shared configurations.

**Options**: None

**Example**:

```bash
flutter_blueprint share list
```

---

#### `flutter_blueprint share config <name>`

Creates a shared configuration from the current project.

**Arguments**:

- `name`: Name for the new configuration

**Example**:

```bash
cd my_project
flutter_blueprint share config my_standard
```

---

#### `flutter_blueprint share export <config-name> <output-path>`

Exports a configuration to a file.

**Arguments**:

- `config-name`: Name of the configuration to export
- `output-path`: Destination file path

**Example**:

```bash
flutter_blueprint share export company_standard ./configs/standard.yaml
```

---

#### `flutter_blueprint share import <file-path> [config-name]`

Imports a configuration from a file.

**Arguments**:

- `file-path`: Path to the YAML configuration file
- `config-name`: (Optional) Name to give the imported configuration

**Example**:

```bash
# Auto-detect name from file
flutter_blueprint share import ./standard.yaml

# Specify custom name
flutter_blueprint share import ./standard.yaml my_config
```

---

#### `flutter_blueprint share delete <config-name>`

Deletes a configuration.

**Arguments**:

- `config-name`: Name of the configuration to delete

**Example**:

```bash
flutter_blueprint share delete old_config
```

---

#### `flutter_blueprint share validate <file-path>`

Validates a configuration file.

**Arguments**:

- `file-path`: Path to the YAML configuration file

**Example**:

```bash
flutter_blueprint share validate company_standard.yaml
```

---

#### `flutter_blueprint init <app-name> --from-config <config-name>`

Creates a new project using a shared configuration.

**Arguments**:

- `app-name`: Name of the new application
- `--from-config`: Name or path of the configuration to use

**Example**:

```bash
flutter_blueprint init my_app --from-config company_standard
flutter_blueprint init my_app --from-config ./configs/custom.yaml
```

---

### Programmatic API

```dart
import 'package:flutter_blueprint/flutter_blueprint.dart';

// Load a configuration
final repository = ConfigRepository();
final config = await repository.load('company_standard');

// List all configurations
final configs = await repository.listConfigs();
for (final info in configs) {
  print('${info.name}: ${info.config.description}');
}

// Save a configuration
final sharedConfig = SharedBlueprintConfig(
  name: 'my_config',
  version: '1.0.0',
  author: 'Me',
  description: 'My custom config',
  defaults: SharedConfigDefaults(
    stateManagement: StateManagement.riverpod,
    platforms: [TargetPlatform.mobile],
    ciProvider: CIProvider.github,
    includeTheme: true,
    includeLocalization: true,
    includeEnv: true,
    includeApi: true,
    includeTests: true,
  ),
  codeStyle: CodeStyleConfig(
    lineLength: 80,
    preferConst: true,
  ),
  architecture: ArchitectureConfig(
    namingConvention: NamingConvention.snakeCase,
  ),
);
await repository.save(sharedConfig, 'my_config');

// Validate a configuration
final validation = await repository.validate('./config.yaml');
if (!validation.isValid) {
  print('Errors: ${validation.errors}');
}
if (validation.hasWarnings) {
  print('Warnings: ${validation.warnings}');
}

// Convert to BlueprintConfig
final blueprintConfig = sharedConfig.toBlueprintConfig('my_app');
```

---

## Troubleshooting

### Configuration Not Found

**Problem**: `flutter_blueprint share list` shows no configurations

**Solution**:

```bash
# Check the config directory exists
# Windows: C:\Users\<username>\.flutter_blueprint\configs
# macOS/Linux: ~/.flutter_blueprint/configs

# Import or create a configuration
flutter_blueprint share import ./example/configs/company_standard.yaml
```

### Invalid YAML Syntax

**Problem**: Configuration fails to parse

**Solution**:

```bash
# Validate the YAML file
flutter_blueprint share validate my_config.yaml

# Common issues:
# - Missing required fields (name, version, author, description)
# - Incorrect indentation
# - Invalid enum values for state_management, ci_provider, etc.
```

### Package Not Found

**Problem**: Warning about unknown packages in `required_packages`

**Solution**:

- These are warnings only, not errors
- Update package names if they've changed on pub.dev
- Remove packages that are no longer available
- Use `--latest-deps` when creating projects to fetch current versions

### Configuration Conflicts

**Problem**: Two configurations with the same name

**Solution**:

```bash
# Rename the duplicate
flutter_blueprint share export old_config ./backup.yaml
flutter_blueprint share delete old_config
flutter_blueprint share import ./backup.yaml old_config_v1
```

---

## See Also

- [README.md](README.md) - Main flutter_blueprint documentation
- [EXAMPLES.md](EXAMPLES.md) - More usage examples
- [example/configs/README.md](example/configs/README.md) - Example configuration templates
- [DX_FEATURES.md](DX_FEATURES.md) - Developer experience features
- [PERFORMANCE_OPTIMIZATION.md](PERFORMANCE_OPTIMIZATION.md) - Performance features

---

## Support

For questions, issues, or feature requests related to collaboration features:

- **Issues**: [GitHub Issues](https://github.com/your-repo/flutter_blueprint/issues)
- **Discussions**: [GitHub Discussions](https://github.com/your-repo/flutter_blueprint/discussions)
- **Documentation**: This file and other `.md` files in the project

---

**Last Updated**: 2024
**Version**: 1.0.0

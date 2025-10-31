# Example Shared Configurations

This directory contains example shared configuration templates that demonstrate the power of team-wide project standardization with flutter_blueprint.

## Available Templates

### 1. Company Standard (`company_standard.yaml`)

**Purpose:** Enterprise-grade standard configuration
**Best for:** Established companies with defined engineering practices
**Features:**

- Riverpod state management
- Multi-platform support (mobile + web)
- GitHub Actions CI/CD
- Complete feature set (theme, localization, env, API, tests)
- Essential enterprise packages included
- 80-character line length
- Snake case naming convention

**Usage:**

```bash
flutter_blueprint init my_app --from-config company_standard
```

---

### 2. Startup Template (`startup_template.yaml`)

**Purpose:** Lean and fast MVP development
**Best for:** Startups and small teams prioritizing speed
**Features:**

- Provider state management (simpler, faster to learn)
- Mobile-only focus
- GitHub Actions CI/CD
- Minimal but essential features
- Lightweight package set
- 100-character line length (faster coding)
- Camel case naming convention

**Usage:**

```bash
flutter_blueprint init my_mvp --from-config startup_template
```

---

### 3. Enterprise Template (`enterprise_template.yaml`)

**Purpose:** Comprehensive enterprise applications
**Best for:** Large organizations with strict compliance requirements
**Features:**

- BLoC state management (maximum scalability)
- Full multi-platform support (mobile + web + desktop)
- Azure Pipelines CI/CD
- All features enabled
- Extensive package ecosystem (DI, networking, storage, monitoring)
- 80-character line length
- Snake case naming convention
- Compliance metadata (SOC 2, GDPR, HIPAA)

**Usage:**

```bash
flutter_blueprint init enterprise_app --from-config enterprise_template
```

---

## How to Use These Templates

### Quick Start

1. **List available configurations:**

   ```bash
   flutter_blueprint share list
   ```

2. **Create a project using a template:**

   ```bash
   flutter_blueprint init my_app --from-config company_standard
   ```

3. **View template details:**
   Open the YAML file to see all settings

### Customization

#### Option 1: Import and Modify

```bash
# Import template
flutter_blueprint share import ./example/configs/company_standard.yaml my_custom

# Generate project from it
flutter_blueprint init my_app --from-config my_custom
```

#### Option 2: Create from Existing Project

```bash
# Navigate to your project
cd my_existing_project

# Create configuration from current project
flutter_blueprint share config my_team_standard

# Use it for new projects
flutter_blueprint init new_project --from-config my_team_standard
```

#### Option 3: Manual Creation

Create your own YAML file with this structure:

```yaml
name: my_config
version: 1.0.0
author: Your Name
description: My custom configuration

defaults:
  state_management: provider|riverpod|bloc
  platforms:
    - mobile
    - web
    - desktop
  ci_provider: github|gitlab|azure|none
  include_theme: true|false
  include_localization: true|false
  include_env: true|false
  include_api: true|false
  include_tests: true|false

required_packages:
  - package_name_1
  - package_name_2

code_style:
  line_length: 80
  prefer_const: true

architecture:
  naming_convention: snake_case|camelCase|PascalCase

metadata:
  # Any custom metadata
  key: value
```

---

## Sharing Configurations

### Within Your Organization

1. **Export to a shared location:**

   ```bash
   flutter_blueprint share export company_standard /shared/configs/standard.yaml
   ```

2. **Team members import:**
   ```bash
   flutter_blueprint share import /shared/configs/standard.yaml
   ```

### Via Version Control

1. **Commit the configuration file:**

   ```bash
   git add .flutter_blueprint_config.yaml
   git commit -m "Add team standard configuration"
   git push
   ```

2. **Team members use directly:**
   ```bash
   flutter_blueprint init my_app --from-config ./.flutter_blueprint_config.yaml
   ```

---

## Validation

Before using a configuration, validate it:

```bash
flutter_blueprint share validate company_standard.yaml
```

This checks:

- Required fields are present
- YAML structure is correct
- Values are valid
- Packages exist (warnings only)

---

## Best Practices

### For Teams

1. **Version your configurations** - Update the `version` field when making changes
2. **Document your decisions** - Use the `description` and `metadata` fields
3. **Start simple** - Begin with startup_template and add complexity as needed
4. **Regular reviews** - Update configurations quarterly based on team feedback

### For Organizations

1. **Maintain multiple configs** - Different templates for different project types
2. **Central repository** - Store configs in a shared location
3. **Training materials** - Document when to use which configuration
4. **Governance** - Define who can modify standard configurations

---

## Troubleshooting

**Configuration not found:**

```bash
# List all available configs
flutter_blueprint share list

# Check the config directory
ls ~/.flutter_blueprint/configs/
```

**Invalid configuration:**

```bash
# Validate the YAML file
flutter_blueprint share validate my_config.yaml

# Check for syntax errors
cat my_config.yaml
```

**Package version conflicts:**

- Update the `required_packages` list
- Remove version constraints to use latest
- Run with `--latest-deps` to fetch current versions

---

## Examples in Action

### Creating a New E-Commerce App

```bash
# Using enterprise template for scalability
flutter_blueprint init my_shop --from-config enterprise_template --template ecommerce
```

### Rapid MVP Development

```bash
# Using startup template for speed
flutter_blueprint init quick_mvp --from-config startup_template --preview
```

### Corporate Standard Project

```bash
# Using company standard with CI/CD
flutter_blueprint init corp_project --from-config company_standard --ci github
```

---

## See Also

- [COLLABORATION_FEATURES.md](../../COLLABORATION_FEATURES.md) - Full collaboration features documentation
- [README.md](../../README.md) - Main flutter_blueprint documentation
- [EXAMPLES.md](../../EXAMPLES.md) - More usage examples

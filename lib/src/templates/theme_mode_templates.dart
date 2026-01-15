import 'package:path/path.dart' as p;
import '../config/blueprint_config.dart';

/// Generates Dark/Light Mode detection and switching templates.
class ThemeModeTemplates {
  /// Generates all theme mode-related files
  static Map<String, String> generate(BlueprintConfig config) {
    final files = <String, String>{};
    final appName = config.appName;

    files[p.join('lib', 'core', 'theme', 'theme_mode_service.dart')] =
        _themeModeService(appName);
    files[p.join('lib', 'core', 'theme', 'theme_provider.dart')] =
        _themeProvider(appName);
    files[p.join('lib', 'core', 'theme', 'theme_persistence.dart')] =
        _themePersistence(appName);
    files[p.join('lib', 'core', 'theme', 'theme_switcher.dart')] =
        _themeSwitcher(appName);

    return files;
  }

  /// Returns the dependencies required for theme mode
  /// (Uses existing shared_preferences, no additional deps needed)
  static Map<String, String> getDependencies() {
    return {
      'shared_preferences': '^2.2.3',
    };
  }

  static String _themeModeService(String appName) => '''
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'theme_persistence.dart';

/// Service for handling dark/light mode detection and switching.
class ThemeModeService extends ChangeNotifier {
  ThemeModeService({
    ThemePersistence? persistence,
  }) : _persistence = persistence ?? ThemePersistence();

  final ThemePersistence _persistence;

  ThemeMode _themeMode = ThemeMode.system;
  bool _isInitialized = false;

  /// Current theme mode
  ThemeMode get themeMode => _themeMode;

  /// Whether the service is initialized
  bool get isInitialized => _isInitialized;

  /// Whether dark mode is currently active
  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      return _getSystemBrightness() == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  /// Whether light mode is currently active
  bool get isLightMode => !isDarkMode;

  /// Whether using system theme
  bool get isSystemMode => _themeMode == ThemeMode.system;

  /// Get the current brightness
  Brightness get currentBrightness {
    return isDarkMode ? Brightness.dark : Brightness.light;
  }

  /// Initialize the service and load saved preference
  Future<void> initialize() async {
    if (_isInitialized) return;

    final savedMode = await _persistence.loadThemeMode();
    if (savedMode != null) {
      _themeMode = savedMode;
    }
    _isInitialized = true;
    notifyListeners();
  }

  /// Set theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    await _persistence.saveThemeMode(mode);
    notifyListeners();
  }

  /// Toggle between light and dark mode
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.light) {
      await setThemeMode(ThemeMode.dark);
    } else {
      await setThemeMode(ThemeMode.light);
    }
  }

  /// Set to light mode
  Future<void> setLight() async {
    await setThemeMode(ThemeMode.light);
  }

  /// Set to dark mode
  Future<void> setDark() async {
    await setThemeMode(ThemeMode.dark);
  }

  /// Set to system mode
  Future<void> setSystem() async {
    await setThemeMode(ThemeMode.system);
  }

  /// Get system brightness
  Brightness _getSystemBrightness() {
    return SchedulerBinding.instance.platformDispatcher.platformBrightness;
  }
}
''';

  static String _themeProvider(String appName) => '''
import 'package:flutter/material.dart';
import 'theme_mode_service.dart';

/// Inherited widget for providing theme mode throughout the app.
class ThemeProvider extends InheritedNotifier<ThemeModeService> {
  const ThemeProvider({
    super.key,
    required ThemeModeService service,
    required super.child,
  }) : super(notifier: service);

  /// Get the theme mode service from context
  static ThemeModeService of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<ThemeProvider>();
    if (provider == null) {
      throw FlutterError(
        'ThemeProvider.of() called with a context that does not contain a ThemeProvider.',
      );
    }
    return provider.notifier!;
  }

  /// Get the theme mode service from context (nullable)
  static ThemeModeService? maybeOf(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<ThemeProvider>();
    return provider?.notifier;
  }

  /// Check if dark mode is active
  static bool isDarkMode(BuildContext context) {
    return of(context).isDarkMode;
  }

  /// Get current theme mode
  static ThemeMode themeMode(BuildContext context) {
    return of(context).themeMode;
  }
}

/// Extension for easy access to theme mode
extension ThemeProviderExtension on BuildContext {
  /// Get the theme mode service
  ThemeModeService get themeService => ThemeProvider.of(this);

  /// Check if dark mode is active
  bool get isDarkMode => themeService.isDarkMode;

  /// Check if light mode is active
  bool get isLightMode => themeService.isLightMode;

  /// Get current theme mode
  ThemeMode get themeMode => themeService.themeMode;

  /// Toggle theme
  Future<void> toggleTheme() => themeService.toggleTheme();
}
''';

  static String _themePersistence(String appName) => '''
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Handles persistence of theme mode preference.
class ThemePersistence {
  static const String _key = 'app_theme_mode';

  /// Save theme mode to storage
  Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.name);
  }

  /// Load theme mode from storage
  Future<ThemeMode?> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key);
    
    if (value == null) return null;
    
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return null;
    }
  }

  /// Clear saved theme mode
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
''';

  static String _themeSwitcher(String appName) => '''
import 'package:flutter/material.dart';
import 'theme_provider.dart';

/// A widget for switching between themes.
class ThemeSwitcher extends StatelessWidget {
  const ThemeSwitcher({
    super.key,
    this.showSystemOption = true,
    this.iconSize = 24.0,
  });

  /// Whether to show the system theme option
  final bool showSystemOption;

  /// Size of the theme icon
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final service = ThemeProvider.of(context);

    if (showSystemOption) {
      return PopupMenuButton<ThemeMode>(
        icon: Icon(_getIcon(service.themeMode), size: iconSize),
        onSelected: service.setThemeMode,
        itemBuilder: (context) => [
          PopupMenuItem(
            value: ThemeMode.light,
            child: Row(
              children: [
                Icon(Icons.light_mode, size: iconSize),
                const SizedBox(width: 12),
                const Text('Light'),
                if (service.themeMode == ThemeMode.light)
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(Icons.check, size: 18),
                  ),
              ],
            ),
          ),
          PopupMenuItem(
            value: ThemeMode.dark,
            child: Row(
              children: [
                Icon(Icons.dark_mode, size: iconSize),
                const SizedBox(width: 12),
                const Text('Dark'),
                if (service.themeMode == ThemeMode.dark)
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(Icons.check, size: 18),
                  ),
              ],
            ),
          ),
          PopupMenuItem(
            value: ThemeMode.system,
            child: Row(
              children: [
                Icon(Icons.settings_brightness, size: iconSize),
                const SizedBox(width: 12),
                const Text('System'),
                if (service.themeMode == ThemeMode.system)
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(Icons.check, size: 18),
                  ),
              ],
            ),
          ),
        ],
      );
    }

    return IconButton(
      icon: Icon(
        service.isDarkMode ? Icons.light_mode : Icons.dark_mode,
        size: iconSize,
      ),
      onPressed: service.toggleTheme,
      tooltip: service.isDarkMode ? 'Switch to light mode' : 'Switch to dark mode',
    );
  }

  IconData _getIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.settings_brightness;
    }
  }
}

/// Animated theme switcher with smooth transition
class AnimatedThemeSwitcher extends StatelessWidget {
  const AnimatedThemeSwitcher({
    super.key,
    this.duration = const Duration(milliseconds: 300),
    this.iconSize = 24.0,
  });

  final Duration duration;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final service = ThemeProvider.of(context);

    return IconButton(
      icon: AnimatedSwitcher(
        duration: duration,
        transitionBuilder: (child, animation) {
          return RotationTransition(
            turns: animation,
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        child: Icon(
          service.isDarkMode ? Icons.light_mode : Icons.dark_mode,
          key: ValueKey(service.isDarkMode),
          size: iconSize,
        ),
      ),
      onPressed: service.toggleTheme,
      tooltip: service.isDarkMode ? 'Switch to light mode' : 'Switch to dark mode',
    );
  }
}

/// Theme mode toggle switch
class ThemeModeSwitch extends StatelessWidget {
  const ThemeModeSwitch({
    super.key,
    this.showLabels = true,
  });

  final bool showLabels;

  @override
  Widget build(BuildContext context) {
    final service = ThemeProvider.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLabels)
          Icon(
            Icons.light_mode,
            color: service.isLightMode
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
        Switch(
          value: service.isDarkMode,
          onChanged: (_) => service.toggleTheme(),
        ),
        if (showLabels)
          Icon(
            Icons.dark_mode,
            color: service.isDarkMode
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
      ],
    );
  }
}
''';
}

/// Advanced localization template generators
///
/// This file contains template generators for advanced localization patterns including:
/// - ARB file management and generation
/// - Locale switching and persistence
/// - RTL (Right-to-Left) support
/// - Pluralization and gender handling
/// - Dynamic locale loading
library;

/// Generates advanced locale manager for runtime locale switching.
///
/// Includes:
/// - Locale persistence with SharedPreferences
/// - Supported locale validation
/// - RTL detection
/// - Locale change notifications
String generateAdvancedLocaleManager() {
  return r'''
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Advanced locale manager with persistence and RTL support.
///
/// Usage:
/// ```dart
/// final manager = LocaleManager();
/// await manager.initialize();
/// 
/// // Change locale
/// await manager.setLocale(Locale('ar'));
/// 
/// // Check RTL
/// if (manager.isRTL) {
///   // Apply RTL layout
/// }
/// ```
class LocaleManager extends ChangeNotifier {
  LocaleManager._();
  
  static final LocaleManager _instance = LocaleManager._();
  static LocaleManager get instance => _instance;
  
  static const String _localeKey = 'selected_locale';
  
  Locale _currentLocale = const Locale('en');
  SharedPreferences? _prefs;
  
  /// Currently selected locale
  Locale get currentLocale => _currentLocale;
  
  /// Check if current locale is RTL
  bool get isRTL => _rtlLanguages.contains(_currentLocale.languageCode);
  
  /// List of RTL language codes
  static const List<String> _rtlLanguages = [
    'ar', // Arabic
    'he', // Hebrew
    'fa', // Persian
    'ur', // Urdu
  ];
  
  /// List of supported locales
  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('es'), // Spanish
    Locale('fr'), // French
    Locale('de'), // German
    Locale('it'), // Italian
    Locale('pt'), // Portuguese
    Locale('ru'), // Russian
    Locale('zh'), // Chinese
    Locale('ja'), // Japanese
    Locale('ko'), // Korean
    Locale('ar'), // Arabic
    Locale('hi'), // Hindi
  ];
  
  /// Initialize locale manager and load saved locale
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadSavedLocale();
  }
  
  /// Load locale from persistent storage
  Future<void> _loadSavedLocale() async {
    final languageCode = _prefs?.getString(_localeKey);
    if (languageCode != null) {
      final locale = Locale(languageCode);
      if (_isSupported(locale)) {
        _currentLocale = locale;
        notifyListeners();
      }
    }
  }
  
  /// Change current locale and persist
  Future<void> setLocale(Locale locale) async {
    if (!_isSupported(locale)) {
      throw UnsupportedError('Locale \${locale.languageCode} is not supported');
    }
    
    if (_currentLocale == locale) return;
    
    _currentLocale = locale;
    await _prefs?.setString(_localeKey, locale.languageCode);
    notifyListeners();
  }
  
  /// Check if locale is supported
  bool _isSupported(Locale locale) {
    return supportedLocales.any(
      (l) => l.languageCode == locale.languageCode,
    );
  }
  
  /// Get text direction for current locale
  TextDirection get textDirection {
    return isRTL ? TextDirection.rtl : TextDirection.ltr;
  }
  
  /// Clear saved locale preference
  Future<void> clearLocale() async {
    await _prefs?.remove(_localeKey);
    _currentLocale = const Locale('en');
    notifyListeners();
  }
  
  /// Get locale display name
  String getLocaleDisplayName(Locale locale) {
    final names = {
      'en': 'English',
      'es': 'Español',
      'fr': 'Français',
      'de': 'Deutsch',
      'it': 'Italiano',
      'pt': 'Português',
      'ru': 'Русский',
      'zh': '中文',
      'ja': '日本語',
      'ko': '한국어',
      'ar': 'العربية',
      'hi': 'हिन्दी',
    };
    return names[locale.languageCode] ?? locale.languageCode;
  }
}
''';
}

/// Generates ARB file generator utility for creating translation files.
///
/// Includes:
/// - ARB file generation from template
/// - Pluralization support
/// - Gender support
/// - Context and description metadata
String generateARBGenerator() {
  return r'''
import 'dart:convert';
import 'dart:io';

/// Utility for generating and managing ARB (Application Resource Bundle) files.
///
/// Usage:
/// ```dart
/// final generator = ARBGenerator();
/// await generator.createARBFile('es', {
///   'appTitle': 'Mi Aplicación',
///   'welcome': 'Bienvenido',
/// });
/// ```
class ARBGenerator {
  final String outputDirectory;
  
  ARBGenerator({this.outputDirectory = 'lib/l10n'});
  
  /// Create a new ARB file for a specific locale
  Future<void> createARBFile(
    String locale,
    Map<String, String> translations, {
    Map<String, ARBMetadata>? metadata,
  }) async {
    final fileName = 'app_\$locale.arb';
    final filePath = '\$outputDirectory/\$fileName';
    
    final arbContent = <String, dynamic>{
      '@@locale': locale,
    };
    
    // Add translations with metadata
    for (final entry in translations.entries) {
      arbContent[entry.key] = entry.value;
      
      // Add metadata if provided
      if (metadata?.containsKey(entry.key) ?? false) {
        final meta = metadata![entry.key]!;
        arbContent['@\${entry.key}'] = {
          if (meta.description != null) 'description': meta.description,
          if (meta.placeholders != null) 'placeholders': meta.placeholders,
          if (meta.context != null) 'context': meta.context,
        };
      }
    }
    
    // Write to file
    final file = File(filePath);
    await file.parent.create(recursive: true);
    await file.writeAsString(
      JsonEncoder.withIndent('  ').convert(arbContent),
    );
  }
  
  /// Generate ARB file with pluralization
  Future<void> createPluralARBFile(
    String locale,
    Map<String, PluralTranslation> plurals,
  ) async {
    final fileName = 'app_\$locale.arb';
    final filePath = '\$outputDirectory/\$fileName';
    
    final arbContent = <String, dynamic>{
      '@@locale': locale,
    };
    
    for (final entry in plurals.entries) {
      final key = entry.key;
      final plural = entry.value;
      
      arbContent[key] = '{count, plural, '
          '=0{\${plural.zero ?? plural.other}} '
          '=1{\${plural.one ?? plural.other}} '
          'other{\${plural.other}}}';
      
      arbContent['@\$key'] = {
        'description': plural.description,
        'placeholders': {
          'count': {'type': 'int'}
        }
      };
    }
    
    final file = File(filePath);
    await file.parent.create(recursive: true);
    await file.writeAsString(
      JsonEncoder.withIndent('  ').convert(arbContent),
    );
  }
  
  /// Generate ARB file with gender support
  Future<void> createGenderARBFile(
    String locale,
    Map<String, GenderTranslation> genders,
  ) async {
    final fileName = 'app_\$locale.arb';
    final filePath = '\$outputDirectory/\$fileName';
    
    final arbContent = <String, dynamic>{
      '@@locale': locale,
    };
    
    for (final entry in genders.entries) {
      final key = entry.key;
      final gender = entry.value;
      
      arbContent[key] = '{gender, select, '
          'male{\${gender.male}} '
          'female{\${gender.female}} '
          'other{\${gender.other}}}';
      
      arbContent['@\$key'] = {
        'description': gender.description,
        'placeholders': {
          'gender': {'type': 'String'}
        }
      };
    }
    
    final file = File(filePath);
    await file.parent.create(recursive: true);
    await file.writeAsString(
      JsonEncoder.withIndent('  ').convert(arbContent),
    );
  }
  
  /// Validate ARB file structure
  Future<bool> validateARBFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return false;
      
      final content = await file.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;
      
      // Check for locale
      if (!json.containsKey('@@locale')) return false;
      
      // Validate structure
      for (final entry in json.entries) {
        if (entry.key.startsWith('@') && entry.key != '@@locale') {
          // Metadata entry - should be an object
          if (entry.value is! Map) return false;
        }
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }
}

/// Metadata for ARB entries
class ARBMetadata {
  final String? description;
  final Map<String, dynamic>? placeholders;
  final String? context;
  
  ARBMetadata({
    this.description,
    this.placeholders,
    this.context,
  });
}

/// Plural translation structure
class PluralTranslation {
  final String other;
  final String? zero;
  final String? one;
  final String? two;
  final String? few;
  final String? many;
  final String description;
  
  PluralTranslation({
    required this.other,
    this.zero,
    this.one,
    this.two,
    this.few,
    this.many,
    required this.description,
  });
}

/// Gender translation structure
class GenderTranslation {
  final String male;
  final String female;
  final String other;
  final String description;
  
  GenderTranslation({
    required this.male,
    required this.female,
    required this.other,
    required this.description,
  });
}
''';
}

/// Generates RTL support utilities.
///
/// Includes:
/// - RTL-aware widget wrappers
/// - Directional padding/margin helpers
/// - Icon mirroring utilities
String generateRTLSupport() {
  return r'''
import 'package:flutter/material.dart';

/// Utilities for RTL (Right-to-Left) language support.
///
/// Usage:
/// ```dart
/// // Directional padding
/// Container(
///   padding: RTLSupport.symmetricHorizontal(context, start: 16, end: 8),
///   child: Text('Content'),
/// );
/// 
/// // Directional alignment
/// Align(
///   alignment: RTLSupport.alignmentStart(context),
///   child: Text('Aligned text'),
/// );
/// ```
class RTLSupport {
  /// Check if current locale is RTL
  static bool isRTL(BuildContext context) {
    return Directionality.of(context) == TextDirection.rtl;
  }
  
  /// Get start alignment based on text direction
  static Alignment alignmentStart(BuildContext context) {
    return isRTL(context) ? Alignment.centerRight : Alignment.centerLeft;
  }
  
  /// Get end alignment based on text direction
  static Alignment alignmentEnd(BuildContext context) {
    return isRTL(context) ? Alignment.centerLeft : Alignment.centerRight;
  }
  
  /// Create directional padding (start/end instead of left/right)
  static EdgeInsets symmetricHorizontal(
    BuildContext context, {
    double start = 0.0,
    double end = 0.0,
  }) {
    final rtl = isRTL(context);
    return EdgeInsets.only(
      left: rtl ? end : start,
      right: rtl ? start : end,
    );
  }
  
  /// Create directional padding for all sides
  static EdgeInsets only(
    BuildContext context, {
    double start = 0.0,
    double end = 0.0,
    double top = 0.0,
    double bottom = 0.0,
  }) {
    final rtl = isRTL(context);
    return EdgeInsets.only(
      left: rtl ? end : start,
      right: rtl ? start : end,
      top: top,
      bottom: bottom,
    );
  }
  
  /// Get border radius with start/end awareness
  static BorderRadius borderRadiusDirectional(
    BuildContext context, {
    double topStart = 0.0,
    double topEnd = 0.0,
    double bottomStart = 0.0,
    double bottomEnd = 0.0,
  }) {
    final rtl = isRTL(context);
    return BorderRadius.only(
      topLeft: Radius.circular(rtl ? topEnd : topStart),
      topRight: Radius.circular(rtl ? topStart : topEnd),
      bottomLeft: Radius.circular(rtl ? bottomEnd : bottomStart),
      bottomRight: Radius.circular(rtl ? bottomStart : bottomEnd),
    );
  }
  
  /// Mirror icon for RTL if needed
  static Widget mirrorIcon(
    BuildContext context,
    IconData icon, {
    double? size,
    Color? color,
  }) {
    final widget = Icon(icon, size: size, color: color);
    
    if (isRTL(context)) {
      return Transform.flip(
        flipX: true,
        child: widget,
      );
    }
    
    return widget;
  }
  
  /// Directional Row (reverses children in RTL)
  static Widget row(
    BuildContext context, {
    Key? key,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    MainAxisSize mainAxisSize = MainAxisSize.max,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    required List<Widget> children,
  }) {
    final rtl = isRTL(context);
    
    return Row(
      key: key,
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: crossAxisAlignment,
      children: rtl ? children.reversed.toList() : children,
    );
  }
  
  /// Get text align start based on direction
  static TextAlign textAlignStart(BuildContext context) {
    return isRTL(context) ? TextAlign.right : TextAlign.left;
  }
  
  /// Get text align end based on direction
  static TextAlign textAlignEnd(BuildContext context) {
    return isRTL(context) ? TextAlign.left : TextAlign.right;
  }
}

/// RTL-aware positioned widget
class DirectionalPositioned extends StatelessWidget {
  const DirectionalPositioned({
    super.key,
    this.start,
    this.end,
    this.top,
    this.bottom,
    this.width,
    this.height,
    required this.child,
  });
  
  final double? start;
  final double? end;
  final double? top;
  final double? bottom;
  final double? width;
  final double? height;
  final Widget child;
  
  @override
  Widget build(BuildContext context) {
    final rtl = RTLSupport.isRTL(context);
    
    return Positioned(
      left: rtl ? end : start,
      right: rtl ? start : end,
      top: top,
      bottom: bottom,
      width: width,
      height: height,
      child: child,
    );
  }
}
''';
}

/// Generates dynamic locale loading utilities.
///
/// Includes:
/// - Lazy loading of locale files
/// - Fallback locale handling
/// - Translation caching
String generateDynamicLocaleLoader() {
  return r'''
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

/// Dynamic locale loader with caching and fallback support.
///
/// Usage:
/// ```dart
/// final loader = DynamicLocaleLoader();
/// final translations = await loader.loadLocale(Locale('es'));
/// final text = translations['welcome'] ?? 'Welcome';
/// ```
class DynamicLocaleLoader {
  static final Map<String, Map<String, String>> _cache = {};
  static const Locale _fallbackLocale = Locale('en');
  
  /// Load translations for a specific locale
  Future<Map<String, String>> loadLocale(Locale locale) async {
    // Check cache first
    final cacheKey = locale.languageCode;
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }
    
    try {
      // Load from assets
      final translations = await _loadFromAssets(locale);
      _cache[cacheKey] = translations;
      return translations;
    } catch (e) {
      // Try fallback locale
      if (locale != _fallbackLocale) {
        return await loadLocale(_fallbackLocale);
      }
      rethrow;
    }
  }
  
  /// Load translations from asset file
  Future<Map<String, String>> _loadFromAssets(Locale locale) async {
    final fileName = 'assets/l10n/\${locale.languageCode}.json';
    
    try {
      final jsonString = await rootBundle.loadString(fileName);
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      
      return jsonMap.map((key, value) => MapEntry(key, value.toString()));
    } catch (e) {
      throw Exception('Failed to load locale \${locale.languageCode}: \$e');
    }
  }
  
  /// Preload multiple locales
  Future<void> preloadLocales(List<Locale> locales) async {
    await Future.wait(
      locales.map((locale) => loadLocale(locale)),
    );
  }
  
  /// Clear cache for a specific locale
  void clearCache([Locale? locale]) {
    if (locale != null) {
      _cache.remove(locale.languageCode);
    } else {
      _cache.clear();
    }
  }
  
  /// Get translation with fallback
  Future<String> getTranslation(
    Locale locale,
    String key, {
    String? fallback,
  }) async {
    final translations = await loadLocale(locale);
    return translations[key] ?? fallback ?? key;
  }
  
  /// Check if locale is cached
  bool isCached(Locale locale) {
    return _cache.containsKey(locale.languageCode);
  }
  
  /// Get all cached locales
  List<String> getCachedLocales() {
    return _cache.keys.toList();
  }
}

/// Translation interpolation helper
class TranslationHelper {
  /// Replace placeholders in translation string
  /// Example: "Hello {name}" with {name: "John"} => "Hello John"
  static String interpolate(String template, Map<String, dynamic> params) {
    var result = template;
    
    for (final entry in params.entries) {
      result = result.replaceAll(
        '{\${entry.key}}',
        entry.value.toString(),
      );
    }
    
    return result;
  }
  
  /// Handle plural forms
  static String plural(int count, Map<String, String> forms) {
    if (count == 0 && forms.containsKey('zero')) {
      return forms['zero']!;
    } else if (count == 1 && forms.containsKey('one')) {
      return forms['one']!;
    } else if (count == 2 && forms.containsKey('two')) {
      return forms['two']!;
    } else if (forms.containsKey('other')) {
      return forms['other']!;
    }
    return '';
  }
  
  /// Handle gender forms
  static String gender(String genderValue, Map<String, String> forms) {
    return forms[genderValue.toLowerCase()] ?? forms['other'] ?? '';
  }
}
''';
}

/// Generates localization examples and best practices.
///
/// Includes:
/// - Complete localization setup example
/// - Best practices for translation management
/// - Common patterns and pitfalls
String generateLocalizationExamples() {
  return r'''
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Example: Complete app setup with localization
///
/// ```dart
/// class MyApp extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return MaterialApp(
///       localizationsDelegates: const [
///         GlobalMaterialLocalizations.delegate,
///         GlobalWidgetsLocalizations.delegate,
///         GlobalCupertinoLocalizations.delegate,
///         AppLocalizations.delegate,
///       ],
///       supportedLocales: LocaleManager.supportedLocales,
///       localeResolutionCallback: (locale, supportedLocales) {
///         // Check if locale is supported
///         if (locale != null) {
///           for (final supportedLocale in supportedLocales) {
///             if (supportedLocale.languageCode == locale.languageCode) {
///               return supportedLocale;
///             }
///           }
///         }
///         return supportedLocales.first;
///       },
///       home: HomePage(),
///     );
///   }
/// }
/// ```

/// Example: Locale switcher widget
class LocaleSwitcher extends StatelessWidget {
  const LocaleSwitcher({super.key});
  
  @override
  Widget build(BuildContext context) {
    return DropdownButton<Locale>(
      value: Localizations.localeOf(context),
      items: LocaleManager.supportedLocales.map((locale) {
        return DropdownMenuItem(
          value: locale,
          child: Text(
            LocaleManager.instance.getLocaleDisplayName(locale),
          ),
        );
      }).toList(),
      onChanged: (locale) async {
        if (locale != null) {
          await LocaleManager.instance.setLocale(locale);
        }
      },
    );
  }
}

/// Example: Using pluralization
class PluralExample extends StatelessWidget {
  const PluralExample({super.key, required this.itemCount});
  
  final int itemCount;
  
  @override
  Widget build(BuildContext context) {
    // Assuming you have a localized string like:
    // "items": "{count, plural, =0{No items} =1{One item} other{{count} items}}"
    
    final text = TranslationHelper.plural(
      itemCount,
      {
        'zero': 'No items',
        'one': 'One item',
        'other': '\$itemCount items',
      },
    );
    
    return Text(text);
  }
}

/// Example: RTL-aware layout
class RTLAwareLayout extends StatelessWidget {
  const RTLAwareLayout({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: RTLSupport.symmetricHorizontal(
        context,
        start: 16.0,
        end: 8.0,
      ),
      child: Row(
        children: [
          RTLSupport.mirrorIcon(context, Icons.arrow_forward),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Directional content',
              textAlign: RTLSupport.textAlignStart(context),
            ),
          ),
        ],
      ),
    );
  }
}

/// Best Practices:
///
/// 1. Always use locale manager for consistency
/// 2. Never hardcode strings in UI
/// 3. Use ARB files for translation management
/// 4. Test with RTL locales (Arabic, Hebrew)
/// 5. Handle pluralization correctly
/// 6. Provide context in translation keys
/// 7. Use interpolation for dynamic values
/// 8. Cache loaded translations
/// 9. Provide fallback locale
/// 10. Test locale switching without restart

/// Common Pitfalls:
///
/// 1. Not handling RTL layouts
/// 2. Hardcoding left/right instead of start/end
/// 3. Forgetting to mirror icons in RTL
/// 4. Not providing plural forms
/// 5. Missing fallback translations
/// 6. Not testing with actual translators
/// 7. Using concatenation instead of interpolation
/// 8. Not handling missing translations gracefully
/// 9. Forgetting to update all locale files
/// 10. Not considering text length differences
''';
}

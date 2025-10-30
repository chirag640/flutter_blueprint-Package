/// Convenient string manipulation extensions for code generation.
extension StringExtensions on String {
  /// Converts snake_case to PascalCase.
  /// Example: user_profile -> UserProfile
  String toPascalCase() {
    if (isEmpty) return this;

    return split('_')
        .map((word) =>
            word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join();
  }

  /// Converts snake_case to camelCase.
  /// Example: user_profile -> userProfile
  String toCamelCase() {
    if (isEmpty) return this;

    final words = split('_');
    if (words.isEmpty) return this;

    final first = words.first;
    final rest = words.skip(1).map((word) =>
        word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1));

    return first + rest.join();
  }

  /// Converts to Title Case with spaces.
  /// Example: user_profile -> User Profile
  String toTitleCase() {
    if (isEmpty) return this;

    return split('_')
        .map((word) =>
            word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  /// Capitalizes first letter.
  /// Example: hello -> Hello
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}

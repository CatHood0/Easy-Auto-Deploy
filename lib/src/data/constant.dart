class Constant {
  const Constant._();

  // DATABASE CONSTANTS
  // NO MODIFY THEM WHEN NOT REQUIRED
  static const int dbVersion = 1;
  static const String databaseKeyName = "auto-database";

  /// The name of the application
  static const String appName = "Auto-Deploy";

  /// The current version of the app
  static const String version = "v1.0";

  /// The current version and the old ones
  static final List<String> versions = List.unmodifiable(
    <String>[
      version,
    ],
  );
}

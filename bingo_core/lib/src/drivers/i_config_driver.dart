/// Defines the contract for a remote configuration driver.
/// This is used to fetch feature flags from a service like Firebase Remote Config.
abstract class IConfigDriver {
  /// Fetches and activates the latest remote configuration.
  Future<void> fetchAndActivate();

  /// Returns the boolean value for a given [key].
  bool getBool(String key);

  /// Returns the integer value for a given [key].
  int getInt(String key);
  
  String getString(String key);
}

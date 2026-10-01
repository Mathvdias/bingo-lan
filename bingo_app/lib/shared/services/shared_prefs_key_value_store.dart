import 'package:bingo_core/bingo_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// [IKeyValueStore] sobre `shared_preferences`, com um prefixo próprio para
/// não misturar com as outras preferências do app (tour, etc.).
///
/// Usado só para os overrides locais de feature flags (dev/alpha).
class SharedPrefsKeyValueStore implements IKeyValueStore {
  static const String defaultPrefix = 'debug_flag_override.';

  final SharedPreferences _prefs;
  final String prefix;

  SharedPrefsKeyValueStore(this._prefs, {this.prefix = defaultPrefix});

  String _full(String key) => '$prefix$key';

  @override
  Future<Object?> get(String key) async => _prefs.get(_full(key));

  @override
  Future<void> set(String key, Object value) async {
    final full = _full(key);
    switch (value) {
      case bool v:
        await _prefs.setBool(full, v);
      case int v:
        await _prefs.setInt(full, v);
      case String v:
        await _prefs.setString(full, v);
      default:
        throw ArgumentError.value(value, 'value', 'Tipo não suportado');
    }
  }

  @override
  Future<void> remove(String key) async {
    await _prefs.remove(_full(key));
  }

  @override
  Future<Set<String>> keys() async => _prefs
      .getKeys()
      .where((k) => k.startsWith(prefix))
      .map((k) => k.substring(prefix.length))
      .toSet();
}

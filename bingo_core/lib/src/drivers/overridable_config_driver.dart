import 'package:flutter/foundation.dart';

import 'i_config_driver.dart';
import 'i_key_value_store.dart';

/// Tipo do valor de uma flag, para [OverridableConfigDriver.effective].
enum ConfigValueType { boolean, integer, string }

/// De onde vem o valor efetivo de uma flag.
enum ConfigSource {
  /// Remote Config (ou o default dele).
  remote,

  /// Override local gravado pelo desenvolvedor.
  override,
}

/// [IConfigDriver] que envolve outro driver (o Remote Config) e deixa o
/// desenvolvedor sobrescrever flags localmente, ao vivo.
///
/// `getBool`/`getInt`/`getString` devolvem o override quando existe e do tipo
/// certo; senão delegam ao [inner]. Os overrides ficam em um [IKeyValueStore]
/// e voltam em [load]. É um [ChangeNotifier]: notifica a cada mudança de
/// override e depois de cada [fetchAndActivate], para a UI reconstruir sem
/// reiniciar o app.
///
/// Só é registrado quando o app pede (flavors com ferramentas de depuração);
/// a prod usa o driver remoto puro.
class OverridableConfigDriver extends ChangeNotifier implements IConfigDriver {
  /// Driver real (Remote Config).
  final IConfigDriver inner;
  final IKeyValueStore _store;
  final Map<String, Object> _overrides = {};

  OverridableConfigDriver(this.inner, IKeyValueStore store) : _store = store;

  /// Overrides ativos (cópia somente leitura).
  Map<String, Object> get overrides => Map.unmodifiable(_overrides);

  bool hasOverride(String key) => _overrides.containsKey(key);

  /// Override de [key], ou `null` se não há.
  Object? overrideOf(String key) => _overrides[key];

  ConfigSource sourceOf(String key) =>
      hasOverride(key) ? ConfigSource.override : ConfigSource.remote;

  /// Valor efetivo de [key] lido como [type]: override se houver, senão o
  /// valor remoto.
  Object effective(String key, ConfigValueType type) {
    return switch (type) {
      ConfigValueType.boolean => getBool(key),
      ConfigValueType.integer => getInt(key),
      ConfigValueType.string => getString(key),
    };
  }

  /// Carrega os overrides persistidos. Valores de tipo inesperado são
  /// ignorados (e removidos do store).
  Future<void> load() async {
    final keys = await _store.keys();
    _overrides.clear();
    for (final key in keys) {
      final value = await _store.get(key);
      if (_isSupported(value)) {
        _overrides[key] = value!;
      } else {
        await _store.remove(key);
      }
    }
    notifyListeners();
  }

  /// Define o override de [key]. [value] precisa ser `bool`, `int` ou
  /// `String`.
  Future<void> setOverride(String key, Object value) async {
    if (!_isSupported(value)) {
      throw ArgumentError.value(
        value,
        'value',
        'Override precisa ser bool, int ou String',
      );
    }
    _overrides[key] = value;
    notifyListeners();
    await _store.set(key, value);
  }

  Future<void> clearOverride(String key) async {
    if (_overrides.remove(key) == null) return;
    notifyListeners();
    await _store.remove(key);
  }

  Future<void> clearAll() async {
    if (_overrides.isEmpty) return;
    final keys = _overrides.keys.toList();
    _overrides.clear();
    notifyListeners();
    for (final key in keys) {
      await _store.remove(key);
    }
  }

  @override
  Future<void> fetchAndActivate() async {
    await inner.fetchAndActivate();
    // Valores remotos podem ter mudado: quem mostra flags reconstrói.
    notifyListeners();
  }

  @override
  bool getBool(String key) {
    final value = _overrides[key];
    return value is bool ? value : inner.getBool(key);
  }

  @override
  int getInt(String key) {
    final value = _overrides[key];
    return value is int ? value : inner.getInt(key);
  }

  @override
  String getString(String key) {
    final value = _overrides[key];
    return value is String ? value : inner.getString(key);
  }

  static bool _isSupported(Object? value) =>
      value is bool || value is int || value is String;
}

/// Armazenamento chave-valor simples e assíncrono.
///
/// O core só define o contrato; o app implementa com `shared_preferences`
/// (ou o que preferir). Os valores são `bool`, `int` ou `String`.
abstract class IKeyValueStore {
  /// Valor guardado em [key], ou `null` se não existe.
  Future<Object?> get(String key);

  /// Guarda [value] (`bool`, `int` ou `String`) em [key].
  Future<void> set(String key, Object value);

  /// Remove [key]; não falha se ela não existe.
  Future<void> remove(String key);

  /// Todas as chaves guardadas.
  Future<Set<String>> keys();
}

/// Implementação em memória: para testes e para quando não há persistência.
class MemoryKeyValueStore implements IKeyValueStore {
  final Map<String, Object> _values;

  MemoryKeyValueStore([Map<String, Object>? initial])
    : _values = {...?initial};

  /// Cópia do conteúdo atual.
  Map<String, Object> get values => Map.unmodifiable(_values);

  @override
  Future<Object?> get(String key) async => _values[key];

  @override
  Future<void> set(String key, Object value) async => _values[key] = value;

  @override
  Future<void> remove(String key) async => _values.remove(key);

  @override
  Future<Set<String>> keys() async => _values.keys.toSet();
}

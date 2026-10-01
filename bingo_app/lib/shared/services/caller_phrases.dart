import 'dart:math';

/// Gera a frase de "cantador" para cada número sorteado.
///
/// Tudo é local e síncrono: não há chamada de rede nem chave de API no app.
/// Uma versão com modelo generativo só deve existir atrás de um proxy no
/// servidor, nunca com a chave compilada no cliente.
class CallerPhrases {
  static final Random _random = Random();

  static final Map<int, List<String>> _jokes = {
    1: ['Começou o jogo!', 'O número um, o começo de tudo.'],
    7: ['Sete mentiras!', 'Número da perfeição.'],
    11: ['Um atrás do outro!', 'As pernas da cadeira.'],
    13: ['Galo cantou!', 'Número da sorte ou azar?'],
    22: ['Dois patinhos na lagoa!', 'Vinte e dois, patinhos.'],
    33: ['Idade de Cristo.', 'Trinta e três, tudo ok.'],
    44: ['Quarenta e quatro, o calibre.', 'Cadeira virada.'],
    55: ['Dois cachorros do padre.', 'Cinquenta e cinco.'],
    66: ['Meia meia!', 'Um par de seis.'],
    69: ['Um pra cima, um pra baixo.', 'Olha o equilíbrio.'],
  };

  /// Frase para [number]. [locale] fica reservado para quando as frases
  /// forem movidas para o ARB por idioma.
  static String getJokeForNumber(int number, {String? locale}) {
    final list = _jokes[number];
    if (list != null && list.isNotEmpty) {
      return list[_random.nextInt(list.length)];
    }
    return 'Número $number!';
  }
}

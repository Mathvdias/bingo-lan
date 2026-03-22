import 'dart:math' hide log;
import 'dart:developer';
import 'package:bingo_app/core/config/env.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

/// Service responsible for generating AI jokes and commentary for Bingo numbers
class AiService {
  static final Random _random = Random();
  static GenerativeModel? _model;

  // Mock database as fallback
  static final Map<int, List<String>> _fallbackJokes = {
    1: ['Começou o jogo!', 'O número um, o começo de tudo.'],
    11: ['Um atrás do outro!', 'As pernas da cadeira.'],
    22: ['Dois patinhos na lagoa!', 'Vinte e dois, patinhos.'],
    33: ['Idade de Cristo.', 'Trinta e três, tudo ok.'],
    44: ['Quarenta e quatro, o calibre.', 'Cadeira virada.'],
    55: ['Dois cachorros do padre.', 'Cinqüenta e cinco.'],
    66: ['Meia meia!', 'Um par de seis.'],
    69: ['Um pra cima, um pra baixo.', 'Olha o equilíbrio.'],
    13: ['Galo cantou!', 'Número da sorte ou azar?'],
    7: ['Sete mentiras!', 'Número da perfeição.'],
  };

  static void _init() {
    if (_model != null) return;
    if (Env.geminiApiKey.isEmpty) {
      log('Gemini API Key is missing. Using fallback jokes.');
      return;
    }

    try {
      _model = GenerativeModel(model: 'gemini-pro', apiKey: Env.geminiApiKey);
    } catch (e) {
      log('Error initializing Gemini: $e');
    }
  }

  /// Get a joke or commentary for a number (Async now)
  static Future<String> getJokeForNumber(int number, {String? locale}) async {
    _init();

    final lang = locale?.split('_').first ?? 'pt'; // Default to pt if null

    // Use Gemini if available
    if (_model != null) {
      try {
        String prompt;
        switch (lang) {
          case 'en':
            prompt =
                'Generate a short, funny, and slightly sarcastic bingo joke or nickname for the number "$number". Max 10 words. Reply with the phrase only.';
            break;
          case 'es':
            prompt =
                'Genera una frase corta, divertida y ligeramente sarcástica sobre el número de bingo "$number". Máximo 10 palabras. Responde solo la frase.';
            break;
          case 'fr':
            prompt =
                'Générez une phrase courte, drôle et légèrement sarcastique sur le numéro de bingo "$number". Max 10 mots. Répondez uniquement par la phrase.';
            break;
          case 'ja':
            prompt =
                'ビンゴ番号「$number」について、短くて面白い、少し皮肉なフレーズを作成してください。最大20文字。フレーズのみを返信してください。';
            break;
          case 'pt':
          default:
            prompt =
                'Gere uma frase curta, engraçada e levemente sarcástica (estilo bingo brasileiro) sobre o número de bingo "$number". Máximo 10 palavras. Responda apenas a frase.';
            break;
        }

        final content = [Content.text(prompt)];
        final response = await _model!.generateContent(content);

        if (response.text != null && response.text!.isNotEmpty) {
          return response.text!;
        }
      } catch (e) {
        log('Gemini generation error: $e');
        // Fallback to local
      }
    }

    // Fallback
    if (_fallbackJokes.containsKey(number)) {
      final list = _fallbackJokes[number]!;
      return list[_random.nextInt(list.length)];
    }

    return 'Número $number!';
  }

  /// Future expansion: stream jokes from LLM
  static Stream<String> streamAiCommentary(int number) async* {
    yield 'Pensando...';
    // Could eventually stream tokens from Gemini here
    final joke = await getJokeForNumber(number);
    yield joke;
  }
}

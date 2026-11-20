/// Flavors do app. `alpha` é a trilha de teste fechado da Play: mesmo pacote,
/// Firebase e chaves da prod, mas com as ferramentas de depuração ligadas.
enum Flavor { dev, alpha, prod }

class AppConfig {
  final Flavor flavor;
  final String appTitle;
  final String apiBaseUrl;

  // Firebase Options can be passed here if different per flavor
  // final FirebaseOptions firebaseOptions;

  AppConfig({
    required this.flavor,
    required this.appTitle,
    required this.apiBaseUrl,
  });

  bool get isDev => flavor == Flavor.dev;
  bool get isAlpha => flavor == Flavor.alpha;
  bool get isProd => flavor == Flavor.prod;

  /// Ferramentas de depuração (tela de flags, entrada escondida no "Sobre").
  /// Ligadas em dev e alpha; nunca em prod.
  bool get hasDebugTools => isDev || isAlpha;
}

enum Flavor { dev, prod }

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
  bool get isProd => flavor == Flavor.prod;
}

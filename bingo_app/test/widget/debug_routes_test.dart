import 'package:bingo_app/core/config/debug_tools.dart';
import 'package:bingo_app/flavors/app_config.dart';
import 'package:bingo_app/shared/router.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

List<String> _paths(Iterable<RouteBase> routes) =>
    routes.whereType<GoRoute>().map((r) => r.path).toList();

AppConfig _config(Flavor flavor) =>
    AppConfig(flavor: flavor, appTitle: 'Bingo', apiBaseUrl: '');

void main() {
  tearDown(() async {
    if (GetIt.I.isRegistered<AppConfig>()) {
      await GetIt.I.unregister<AppConfig>();
    }
  });

  group('rota /debug/flags', () {
    test('não existe sem ferramentas de depuração (prod)', () {
      expect(
        _paths(buildAppRoutes(debugTools: false)),
        isNot(contains(debugFlagsPath)),
      );
    });

    test('existe com ferramentas de depuração (dev/alpha)', () {
      expect(
        _paths(buildAppRoutes(debugTools: true)),
        contains(debugFlagsPath),
      );
    });

    test('appRoutes do app não tem a rota sem AppConfig registrada', () {
      // Sem AppConfig no GetIt (testes) o padrão é o comportamento de prod.
      expect(debugToolsEnabled, isFalse);
      expect(_paths(appRoutes), isNot(contains(debugFlagsPath)));
    });
  });

  group('debugToolsEnabled', () {
    test('segue AppConfig.hasDebugTools do flavor registrado', () async {
      GetIt.I.registerSingleton<AppConfig>(_config(Flavor.prod));
      expect(debugToolsEnabled, isFalse);
      await GetIt.I.unregister<AppConfig>();

      GetIt.I.registerSingleton<AppConfig>(_config(Flavor.alpha));
      expect(debugToolsEnabled, isTrue);
      await GetIt.I.unregister<AppConfig>();

      GetIt.I.registerSingleton<AppConfig>(_config(Flavor.dev));
      expect(debugToolsEnabled, isTrue);
    });
  });
}

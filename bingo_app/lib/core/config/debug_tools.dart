import 'package:bingo_app/flavors/app_config.dart';
import 'package:get_it/get_it.dart';

/// `true` quando as ferramentas de depuração (tela `/debug/flags`, entrada
/// escondida no "Sobre") devem existir: flavors dev e alpha.
///
/// Lê a [AppConfig] registrada no GetIt pelo entrypoint. Sem ela (testes que
/// não registram nada) devolve `false`, o mesmo comportamento da prod.
bool get debugToolsEnabled =>
    GetIt.I.isRegistered<AppConfig>() && GetIt.I<AppConfig>().hasDebugTools;

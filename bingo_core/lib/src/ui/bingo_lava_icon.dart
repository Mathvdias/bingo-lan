import 'package:flutter/widgets.dart';
import 'package:lava_flutter/lava_flutter.dart';

/// Ícones 3D animados ("Lava") empacotados no SDK, um bundle OpenLava por
/// ícone em `assets/lava/<nome>/`.
enum BingoLavaIcon {
  /// Bola azul com o 7 (herói do lobby).
  ball('bingo_ball'),

  /// Globo de bingo amarelo girando no eixo, com bolas dentro (sala do host
  /// sem sorteio).
  cage('bingo_cage'),

  /// Roseta amarela com estrela preta (paywall).
  premiumBadge('premium_badge'),

  /// Taça com confete (BINGO validado).
  trophy('trophy'),

  /// Celular lendo um QR (leitor sem câmera).
  cameraScan('camera_scan'),

  /// Balão de informação (tela Sobre).
  infoBubble('info_bubble'),

  /// Placa de aviso amarela com "!" (título "Importante" do Sobre).
  warning('warning_sign'),

  /// Livro aberto com uma página virando (título "Como jogar" do Sobre).
  book('open_book'),

  /// Globo terrestre de mesa que balança de leve (seletor de idioma do Sobre).
  globe('globe'),

  /// Roteador Wi-Fi com bolas de bingo (cartão da criação de sala).
  wifiRouter('wifi_table'),

  /// Dois jogadores, um acenando (contador de jogadores e paywall).
  players('players'),

  /// Dado que rola e cai noutra face; toca uma vez (aba "Virtual").
  dice('dice'),

  /// Lápis que escreve um traço; toca uma vez (aba "Manual").
  pencil('pencil');

  const BingoLavaIcon(this.directory);

  /// Nome do diretório do bundle dentro de `assets/lava/`.
  final String directory;

  /// Chave de asset vista pelo app hospedeiro (assets de pacote levam o
  /// prefixo `packages/<pacote>/`).
  String get assetPath => 'packages/bingo_core/assets/lava/$directory';
}

/// Carrega o bundle de um [BingoLavaIcon] e avisa [onChanged] quando ele
/// chega ou falha. Um bundle ausente ou corrompido vai para o console
/// ([FlutterError.reportError]) em vez de sumir.
class BingoLavaBundleLoader {
  BingoLavaBundleLoader(this.icon, {required this.onChanged});

  final BingoLavaIcon icon;
  final VoidCallback onChanged;

  LavaBundle? _bundle;
  bool _failed = false;
  bool _disposed = false;

  /// O bundle decodificado, ou `null` enquanto carrega ou se falhou.
  LavaBundle? get bundle {
    final bundle = _bundle;
    if (bundle == null || bundle.isDisposed) return null;
    return bundle;
  }

  /// Verdadeiro quando o carregamento falhou: fica o fallback.
  bool get failed => _failed;

  Future<void> load() async {
    try {
      final bundle = await LavaBundle.openLavaAsset(assetPath: icon.assetPath);
      if (_disposed) return;
      _bundle = bundle;
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'bingo_core',
          context: ErrorDescription(
            'while loading the ${icon.name} Lava icon',
          ),
        ),
      );
      if (_disposed) return;
      _failed = true;
    }
    onChanged();
  }

  /// Depois disto o resultado de [load] é ignorado.
  void dispose() {
    _disposed = true;
  }
}

/// Mostra um [BingoLavaIcon] animado, com [fallback] no lugar enquanto o
/// bundle decodifica ou se ele falhar: o espaço nunca fica em branco.
///
/// A caixa tem sempre [size] x [size], nos dois estados, para o layout não
/// pular na troca. Com `MediaQuery.disableAnimations` a animação fica parada
/// no primeiro quadro.
class BingoLavaIconView extends StatefulWidget {
  const BingoLavaIconView({
    super.key,
    required this.icon,
    required this.size,
    required this.fallback,
    this.interactive = false,
    this.semanticLabel,
  });

  final BingoLavaIcon icon;

  /// Lado da caixa quadrada, em pixels lógicos.
  final double size;

  /// O que aparece antes do bundle carregar ou se o carregamento falhar
  /// (normalmente o ícone Material que ocupava o lugar).
  final Widget fallback;

  /// Inclinação 3D e mola ao toque (ver [LavaIcon.interactive]).
  final bool interactive;

  /// Rótulo para leitores de tela; sem ele o ícone é decorativo.
  final String? semanticLabel;

  @override
  State<BingoLavaIconView> createState() => _BingoLavaIconViewState();
}

class _BingoLavaIconViewState extends State<BingoLavaIconView> {
  late BingoLavaBundleLoader _loader;

  @override
  void initState() {
    super.initState();
    _loader = BingoLavaBundleLoader(widget.icon, onChanged: _onLoaderChanged)
      ..load();
  }

  @override
  void didUpdateWidget(covariant BingoLavaIconView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.icon != oldWidget.icon) {
      _loader.dispose();
      _loader = BingoLavaBundleLoader(widget.icon, onChanged: _onLoaderChanged)
        ..load();
    }
  }

  void _onLoaderChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _loader.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bundle = _loader.bundle;
    final Widget child;
    if (bundle == null || _loader.failed) {
      child = KeyedSubtree(
        key: const ValueKey<String>('bingo_lava_fallback'),
        child: widget.fallback,
      );
    } else {
      final animate = !MediaQuery.disableAnimationsOf(context);
      child = LavaIcon(
        key: const ValueKey<String>('bingo_lava_animation'),
        bundle: bundle,
        size: widget.size,
        interactive: widget.interactive,
        autoPlay: animate,
      );
    }
    Widget box = SizedBox.square(
      dimension: widget.size,
      child: Center(child: child),
    );
    final label = widget.semanticLabel;
    box = label == null
        ? ExcludeSemantics(child: box)
        : Semantics(label: label, image: true, child: box);
    return box;
  }
}

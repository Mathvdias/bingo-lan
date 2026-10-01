import 'package:flutter/widgets.dart';
import 'package:lava_flutter/lava_flutter.dart';

/// Ícones 3D animados ("Lava") empacotados no SDK, um bundle OpenLava por
/// ícone em `assets/lava/<nome>/`.
enum BingoLavaIcon {
  /// Bola azul com o 7 (herói do lobby).
  ball('bingo_ball'),

  /// Globo amarelo com bolas (sala do host sem sorteio).
  cage('bingo_cage'),

  /// Roseta amarela com estrela preta (paywall).
  premiumBadge('premium_badge'),

  /// Taça com confete (BINGO validado).
  trophy('trophy'),

  /// Celular lendo um QR (leitor sem câmera).
  cameraScan('camera_scan'),

  /// Balão de informação (tela Sobre).
  infoBubble('info_bubble');

  const BingoLavaIcon(this.directory);

  /// Nome do diretório do bundle dentro de `assets/lava/`.
  final String directory;

  /// Chave de asset vista pelo app hospedeiro (assets de pacote levam o
  /// prefixo `packages/<pacote>/`).
  String get assetPath => 'packages/bingo_core/assets/lava/$directory';
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
  LavaBundle? _bundle;
  bool _failed = false;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant BingoLavaIconView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.icon != oldWidget.icon) {
      _bundle = null;
      _failed = false;
      _load();
    }
  }

  Future<void> _load() async {
    final generation = ++_generation;
    try {
      final bundle = await LavaBundle.openLavaAsset(
        assetPath: widget.icon.assetPath,
      );
      if (!mounted || generation != _generation) return;
      setState(() => _bundle = bundle);
    } catch (error, stackTrace) {
      // Bundle ausente ou corrompido: fica o fallback, mas o erro aparece no
      // console em vez de sumir.
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'bingo_core',
          context: ErrorDescription(
            'while loading the ${widget.icon.name} Lava icon',
          ),
        ),
      );
      if (!mounted || generation != _generation) return;
      setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bundle = _bundle;
    final Widget child;
    if (bundle == null || bundle.isDisposed || _failed) {
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

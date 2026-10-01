import 'package:flutter/widgets.dart';
import 'package:lava_flutter/lava_flutter.dart';

import 'bingo_lava_icon.dart';

/// Ícone de aba no estilo Airbnb: o bundle é tocado UMA vez quando a aba
/// passa a [selected] (do quadro 0 ao último, onde fica), e volta ao quadro 0
/// quando a aba deixa de estar selecionada. Começa parado no último quadro se
/// já nasce selecionado.
///
/// Sem seleção o ícone fica acinzentado e com [unselectedOpacity], sem
/// recolorir o asset. Com `MediaQuery.disableAnimations` a seleção pula para
/// o último quadro em vez de tocar. [fallback] ocupa o lugar até o bundle
/// decodificar ou se ele falhar.
class BingoLavaTabIcon extends StatefulWidget {
  const BingoLavaTabIcon({
    super.key,
    required this.icon,
    required this.selected,
    required this.size,
    required this.fallback,
    this.unselectedOpacity = 0.55,
    this.semanticLabel,
  });

  final BingoLavaIcon icon;

  /// Verdadeiro para a aba ativa.
  final bool selected;

  /// Lado da caixa quadrada, em pixels lógicos.
  final double size;

  /// Ícone Material (ou outro widget) para antes do bundle carregar.
  final Widget fallback;

  /// Opacidade do ícone quando a aba não está selecionada.
  final double unselectedOpacity;

  /// Rótulo para leitores de tela; sem ele o ícone é decorativo.
  final String? semanticLabel;

  @override
  State<BingoLavaTabIcon> createState() => _BingoLavaTabIconState();
}

class _BingoLavaTabIconState extends State<BingoLavaTabIcon>
    with SingleTickerProviderStateMixin {
  late BingoLavaBundleLoader _loader;
  LavaController? _controller;

  // Dessatura sem mudar a luminância (pesos Rec. 601), como um ícone Material
  // desabilitado; a opacidade vem por cima.
  static const List<double> _greyMatrix = <double>[
    0.299, 0.587, 0.114, 0, 0, //
    0.299, 0.587, 0.114, 0, 0, //
    0.299, 0.587, 0.114, 0, 0, //
    0, 0, 0, 1, 0, //
  ];

  @override
  void initState() {
    super.initState();
    _loader = BingoLavaBundleLoader(widget.icon, onChanged: _onLoaderChanged)
      ..load();
  }

  @override
  void didUpdateWidget(covariant BingoLavaTabIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.icon != oldWidget.icon) {
      _disposeController();
      _loader.dispose();
      _loader = BingoLavaBundleLoader(widget.icon, onChanged: _onLoaderChanged)
        ..load();
    } else if (widget.selected != oldWidget.selected) {
      _sync(play: widget.selected);
    }
  }

  void _onLoaderChanged() {
    if (!mounted) return;
    final bundle = _loader.bundle;
    if (bundle != null && _controller == null) {
      final controller = LavaController(
        totalFrames: bundle.manifest.totalFrames,
        fps: bundle.manifest.frameRate,
        loop: false,
        autoPlay: false,
        vsync: this,
      );
      controller.currentFrameNotifier.addListener(_onFrame);
      _controller = controller;
      // Aba já ativa ao nascer: pose final, sem tocar.
      _sync(play: false);
    }
    setState(() {});
  }

  /// Um bundle marcado como loop no manifest também para no último quadro.
  void _onFrame() {
    final controller = _controller;
    if (controller == null) return;
    if (controller.isPlaying &&
        controller.currentFrame >= controller.totalFrames - 1) {
      controller.pause();
    }
  }

  void _sync({required bool play}) {
    final controller = _controller;
    if (controller == null) return;
    final last = controller.totalFrames - 1;
    if (!widget.selected) {
      controller.pause();
      controller.seekToFrame(0);
      return;
    }
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (!play || reduceMotion || last <= 0) {
      controller.pause();
      controller.seekToFrame(last);
      return;
    }
    controller.pause();
    controller.seekToFrame(0);
    controller.play();
  }

  void _disposeController() {
    _controller?.currentFrameNotifier.removeListener(_onFrame);
    _controller?.dispose();
    _controller = null;
  }

  @override
  void dispose() {
    _disposeController();
    _loader.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bundle = _loader.bundle;
    final controller = _controller;
    Widget child;
    if (bundle == null || controller == null || _loader.failed) {
      child = KeyedSubtree(
        key: const ValueKey<String>('bingo_lava_fallback'),
        child: widget.fallback,
      );
    } else {
      child = LavaIcon(
        key: const ValueKey<String>('bingo_lava_animation'),
        bundle: bundle,
        controller: controller,
        size: widget.size,
        autoPlay: false,
      );
      if (!widget.selected) {
        child = ColorFiltered(
          colorFilter: const ColorFilter.matrix(_greyMatrix),
          child: child,
        );
      }
      child = AnimatedOpacity(
        opacity: widget.selected ? 1.0 : widget.unselectedOpacity,
        duration: const Duration(milliseconds: 150),
        child: child,
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

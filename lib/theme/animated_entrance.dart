import 'package:flutter/material.dart';

/// Anima a entrada de qualquer widget com fade + leve slide de baixo
/// para cima, em vez de aparecer instantaneamente. Usar `delay` para
/// escalonar itens de uma lista (ex: `delay: Duration(milliseconds: 40 * index)`)
/// e dar a sensação de que os itens "chegam" um após o outro.
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 350),
  });

  final Widget child;
  final Duration delay;
  final Duration duration;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn> {
  bool visible = false;

  @override
  void initState() {
    super.initState();

    if (widget.delay == Duration.zero) {

      visible = true;

    } else {

      Future.delayed(widget.delay, () {

        if (!mounted) return;

        setState(() {
          visible = true;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return AnimatedSlide(

      offset: visible
          ? Offset.zero
          : const Offset(0, 0.08),

      duration: widget.duration,

      curve: Curves.easeOutCubic,

      child: AnimatedOpacity(

        opacity: visible ? 1 : 0,

        duration: widget.duration,

        curve: Curves.easeOut,

        child: widget.child,
      ),
    );
  }
}

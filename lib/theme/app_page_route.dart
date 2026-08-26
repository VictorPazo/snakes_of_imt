import 'package:flutter/material.dart';

/// Estilos de transição de página disponíveis no app.
enum AppTransition { fade, slide }

/// Rota customizada usada em toda a navegação principal do app, no lugar
/// do `MaterialPageRoute` padrão. Suporta fade (para trocas de contexto,
/// como login → home) e slide (para navegação "para frente" dentro do
/// mesmo fluxo, como home → câmera/histórico/configurações).
class AppPageRoute<T> extends PageRouteBuilder<T> {
  AppPageRoute({
    required WidgetBuilder builder,
    this.transition = AppTransition.fade,
    super.settings,
  }) : super(
         pageBuilder: (context, animation, secondaryAnimation) =>
             builder(context),

         transitionDuration: const Duration(milliseconds: 300),
         reverseTransitionDuration: const Duration(milliseconds: 300),

         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           switch (transition) {
             case AppTransition.fade:
               return FadeTransition(opacity: animation, child: child);

             case AppTransition.slide:
               final curved = CurvedAnimation(
                 parent: animation,
                 curve: Curves.easeInOutCubic,
                 reverseCurve: Curves.easeInOutCubic,
               );

               return SlideTransition(
                 position: Tween<Offset>(
                   begin: const Offset(1, 0),
                   end: Offset.zero,
                 ).animate(curved),
                 child: child,
               );
           }
         },
       );

  final AppTransition transition;
}

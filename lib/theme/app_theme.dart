import 'package:flutter/material.dart';

/// Escala de espaçamento do app (múltiplos de 4). Usar sempre um destes
/// valores em `EdgeInsets`/`SizedBox`/gaps em vez de números soltos, para
/// manter paddings e margens consistentes entre telas parecidas (cards,
/// distância entre título e conteúdo, etc).
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

/// Paleta de cores do app. Só existem duas cores de marca — o verde escuro
/// de fundo e o verde intermediário de botões/destaques —, então o resto
/// da paleta é composto pelas cores neutras (branco/preto/cinza) e pelo
/// vermelho de ações destrutivas que já eram usadas espalhadas pelas
/// telas. Nenhuma cor nova além dessas duas foi introduzida.
class AppColors {
  AppColors._();

  /// Fundo principal das telas (Scaffold).
  static const Color background = Color(0xFF12352A);

  /// Botões, AppBar, barra de navegação inferior e outros destaques.
  static const Color accent = Color(0xFF14453A);

  static const Color surface = Colors.white;
  static const Color onSurface = Colors.black87;

  static const Color onBackground = Colors.white;
  static const Color onBackgroundMuted = Colors.white70;

  /// Ações destrutivas (excluir, sair) — já era usado assim em várias
  /// telas antes da centralização.
  static const Color danger = Colors.red;
}

/// Estilos de texto recorrentes nas telas do app, extraídos dos valores
/// que já apareciam repetidos (título de tela, título de seção, corpo).
class AppTextStyles {
  AppTextStyles._();

  static const TextStyle screenTitle = TextStyle(
    color: AppColors.onBackground,
    fontSize: 28,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle sectionTitle = TextStyle(
    color: AppColors.onBackground,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle subtitle = TextStyle(
    color: AppColors.onBackgroundMuted,
    fontSize: 16,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    color: AppColors.onSurface,
  );

  static const TextStyle bodyOnBackground = TextStyle(
    fontSize: 16,
    color: AppColors.onBackground,
  );

  static const TextStyle buttonLabel = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );
}

/// Tema central do app. Propositalmente NÃO usa `ColorScheme.fromSeed`
/// (nem qualquer outra geração automática de paleta): esses geradores
/// derivam dezenas de tons a partir da cor semente, o que introduziria
/// cores fora das duas verdes já existentes no projeto. Em vez disso,
/// o `ColorScheme` abaixo só preenche os campos obrigatórios com cores
/// já usadas no app, e cada componente visual (AppBar, botões, barra
/// inferior, switches, texto) recebe um tema explícito próprio — assim
/// nenhuma cor "de fallback" do Material passa a aparecer na UI.
class AppTheme {
  AppTheme._();

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,

      scaffoldBackgroundColor: AppColors.background,

      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: AppColors.background,
        onPrimary: AppColors.onBackground,
        secondary: AppColors.accent,
        onSecondary: AppColors.onBackground,
        error: AppColors.danger,
        onError: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
      ),

      textTheme: const TextTheme(
        headlineMedium: AppTextStyles.screenTitle,
        titleLarge: AppTextStyles.sectionTitle,
        bodyMedium: AppTextStyles.body,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.all(AppSpacing.md),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.background,
        ),
      ),

      iconTheme: const IconThemeData(
        color: AppColors.onBackground,
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.accent,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.accent;
          }
          return null;
        }),
      ),

      dialogTheme: const DialogThemeData(
        backgroundColor: Colors.white,
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: TextStyle(
          color: Colors.black87,
          fontSize: 16,
        ),
      ),
    );
  }
}

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/snake_model.dart';
import '../theme/app_theme.dart';
import '../theme/animated_entrance.dart';

class SnakeInformationScreen
    extends StatefulWidget {

  final SnakeModel snake;

  final double confidence;

  final String imageUrl;

  // Tag do Hero usado para animar continuidade entre a foto na tela
  // de confirmação da câmera e a imagem aqui. Nulo quando a tela é
  // aberta a partir do histórico, onde não há Hero de origem.
  final String? heroTag;

  const SnakeInformationScreen({

    super.key,

    required this.snake,

    required this.confidence,

    required this.imageUrl,

    this.heroTag,
  });

  @override
  State<SnakeInformationScreen> createState() =>
      _SnakeInformationScreenState();
}

class _SnakeInformationScreenState
    extends State<SnakeInformationScreen> {

  bool showConfidence = true;

  @override
  void initState() {
    super.initState();

    loadShowConfidenceSetting();
  }

  // ⚙️ CONFIGURAÇÃO
  Future<void> loadShowConfidenceSetting() async {

    final prefs =
    await SharedPreferences.getInstance();

    final value =
        prefs.getBool('showConfidence') ?? true;

    if (!mounted) return;

    setState(() {
      showConfidence = value;
    });
  }

  @override
  Widget build(BuildContext context) {

    final image =
    Supabase.instance.client.storage

        .from('snake-species')

        .getPublicUrl(widget.snake.imageName);

    final bool hasConfidence =
        widget.confidence > 0;

    Widget snakeImage = Image.network(

      image,

      height: 250,

      width: double.infinity,

      fit: BoxFit.cover,

      errorBuilder: (
          context,
          error,
          stackTrace,
          ) {

        return Container(

          height: 250,

          width: double.infinity,

          color: Colors.grey[300],

          child: const Center(

            child: Icon(

              Icons.image_not_supported,

              size: 50,
            ),
          ),
        );
      },
    );

    if (widget.heroTag != null) {

      snakeImage = Hero(
        tag: widget.heroTag!,
        child: snakeImage,
      );
    }

    return Scaffold(

      appBar: AppBar(

        elevation: 0,

        leading: IconButton(

          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.onBackground,
          ),

          onPressed: () {

            Navigator.pop(context);
          },
        ),

        title: Text(
          "snake_identified".tr(),
        ),
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(AppSpacing.lg),

        child: Column(

          children: [

            ClipRRect(

              borderRadius:
              BorderRadius.circular(20),

              child: snakeImage,
            ),

            const SizedBox(height: AppSpacing.lg),

            FadeSlideIn(

              child: Text(

                widget.snake.specie,

                textAlign: TextAlign.center,

                style: AppTextStyles.screenTitle,
              ),
            ),

            // 🎯 CONFIANÇA DA IA
            // Só mostra se o usuário mantiver o toggle "Mostrar confiança
            // da IA" ativo em Configurações e se houver um valor válido
            // (identificações abertas pelo histórico não guardam a
            // confiança original, então chegam aqui com confidence == 0).
            if (showConfidence && hasConfidence) ...[

              const SizedBox(height: AppSpacing.md),

              FadeSlideIn(

                delay:
                const Duration(milliseconds: 80),

                child: buildConfidenceBadge(),
              ),
            ],

            const SizedBox(height: AppSpacing.lg),

            // ⚠️ AVISO MÉDICO
            FadeSlideIn(

              delay:
              const Duration(milliseconds: 140),

              child: buildMedicalDisclaimer(),
            ),

            const SizedBox(height: AppSpacing.lg),

            FadeSlideIn(

              delay:
              const Duration(milliseconds: 200),

              child: Container(

              padding:
              const EdgeInsets.all(AppSpacing.lg),

              decoration: BoxDecoration(

                color: Colors.white,

                borderRadius:
                BorderRadius.circular(20),
              ),

              child: Column(

                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [

                  infoRow(
                    "family".tr(),
                    widget.snake.family,
                  ),

                  infoRow(
                    "genus".tr(),
                    widget.snake.genus,
                  ),

                  infoRow(
                    "poisonous".tr(),
                    widget.snake.poisonous
                        ? "yes".tr()
                        : "no".tr(),
                  ),

                  infoRow(
                    "dentition_type".tr(),
                    widget.snake.dentition_type
                        .toString(),
                  ),

                  infoRow(
                    "venom_type".tr(),
                    widget.snake.venomType,
                  ),

                  infoRow(
                    "antivenom".tr(),
                    widget.snake.effectiveAntivenom
                        ?? "not_informed".tr(),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  Text(

                    "description".tr(),

                    style: const TextStyle(

                      fontSize: 20,

                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  Text(

                    widget.snake.description
                        ?? "no_description".tr(),

                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            ),
          ],
        ),
      ),
    );
  }

  // 🎯 BADGE DE CONFIANÇA
  Widget buildConfidenceBadge() {

    return Container(

      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),

      decoration: BoxDecoration(

        color: AppColors.accent,

        borderRadius:
        BorderRadius.circular(20),
      ),

      child: Row(

        mainAxisSize: MainAxisSize.min,

        children: [

          const Icon(

            Icons.psychology_outlined,

            color: AppColors.onBackground,

            size: 18,
          ),

          const SizedBox(width: AppSpacing.sm),

          Text(

            "${"ai_confidence".tr()}: "
                "${widget.confidence.toStringAsFixed(1)}%",

            style: const TextStyle(

              color: AppColors.onBackground,

              fontWeight: FontWeight.w600,

              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // ⚠️ AVISO MÉDICO
  // Deixa explícito que o app não substitui avaliação profissional —
  // importante porque a tela também é usada para identificar serpentes
  // peçonhentas, onde uma leitura errada da IA pode ter consequências
  // graves se o usuário confiar cegamente no resultado.
  Widget buildMedicalDisclaimer() {

    return Container(

      padding: const EdgeInsets.all(AppSpacing.md),

      decoration: BoxDecoration(

        color: Colors.amber.shade50,

        borderRadius:
        BorderRadius.circular(16),

        border: Border.all(
          color: Colors.amber.shade700,
        ),
      ),

      child: Row(

        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          Icon(

            Icons.warning_amber_rounded,

            color: Colors.amber.shade800,
          ),

          const SizedBox(width: AppSpacing.sm),

          Expanded(

            child: Column(

              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                Text(

                  "medical_disclaimer_title".tr(),

                  style: TextStyle(

                    fontWeight: FontWeight.bold,

                    color: Colors.amber.shade900,
                  ),
                ),

                const SizedBox(height: AppSpacing.xs),

                Text(

                  "medical_disclaimer_text".tr(),

                  style: TextStyle(

                    color: Colors.amber.shade900,

                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget infoRow(
      String title,
      String value,
      ) {

    return Padding(

      padding:
      const EdgeInsets.only(bottom: AppSpacing.md),

      child: Row(

        children: [

          Text(

            '$title: ',

            style: const TextStyle(

              fontWeight: FontWeight.bold,

              fontSize: 16,
            ),
          ),

          Expanded(

            child: Text(

              value,

              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

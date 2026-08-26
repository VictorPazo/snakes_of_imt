import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'app_theme.dart';

/// Um bloco cinza com efeito de brilho (shimmer) — a peça básica para
/// montar telas de esqueleto, no lugar de um spinner genérico enquanto
/// dados da API carregam.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius =
    const BorderRadius.all(Radius.circular(8)),
  });

  final double? width;
  final double height;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {

    return Shimmer.fromColors(

      baseColor: Colors.grey.shade300,

      highlightColor: Colors.grey.shade100,

      child: Container(

        width: width,

        height: height,

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius,
        ),
      ),
    );
  }
}

/// Esqueleto de um card do histórico (foto + linhas de texto), no
/// mesmo formato do card real em history.dart.
class HistoryCardSkeleton extends StatelessWidget {
  const HistoryCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {

    return Container(

      margin: const EdgeInsets.only(
        bottom: AppSpacing.lg,
      ),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius: BorderRadius.circular(20),
      ),

      child: Column(

        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          const SkeletonBox(
            height: 220,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),

          Padding(

            padding:
            const EdgeInsets.all(AppSpacing.md),

            child: Column(

              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                const SkeletonBox(
                  width: 160,
                  height: 22,
                ),

                const SizedBox(height: AppSpacing.md),

                const SkeletonBox(
                  width: 120,
                  height: 17,
                ),

                const SizedBox(height: AppSpacing.md),

                const SkeletonBox(
                  width: 90,
                  height: 15,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Esqueleto para a área do mapa enquanto a posição do usuário e as
/// ocorrências ainda estão carregando.
class MapSkeleton extends StatelessWidget {
  const MapSkeleton({super.key});

  @override
  Widget build(BuildContext context) {

    return ClipRRect(

      borderRadius: BorderRadius.circular(20),

      child: const SkeletonBox(
        width: double.infinity,
        height: double.infinity,
        borderRadius: BorderRadius.zero,
      ),
    );
  }
}

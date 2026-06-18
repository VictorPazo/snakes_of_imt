import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/snake_model.dart';
import 'history.dart';

class SnakeInformationScreen
    extends StatelessWidget {

  final SnakeModel snake;

  final double confidence;

  final String imageUrl;

  const SnakeInformationScreen({

    super.key,

    required this.snake,

    required this.confidence,

    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {

    final image =
    Supabase.instance.client.storage

        .from('snake-species')

        .getPublicUrl(snake.imageName);

    return Scaffold(

      backgroundColor:
      const Color(0xFF115F15),

      appBar: AppBar(

        backgroundColor:
        const Color(0xFF115F15),

        elevation: 0,

        leading: IconButton(

          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),

          onPressed: () {

            Navigator.pushReplacement(

              context,

              MaterialPageRoute(
                builder: (_) =>
                const HistoryPage(),
              ),
            );
          },
        ),

        title: const Text(

          'Serpente identificada',

          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            ClipRRect(

              borderRadius:
              BorderRadius.circular(20),

              child: Image.network(

                image,

                height: 250,

                width: double.infinity,

                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 20),

            Text(

              snake.specie,

              textAlign: TextAlign.center,

              style: const TextStyle(

                color: Colors.white,

                fontSize: 28,

                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            Container(

              padding:
              const EdgeInsets.all(20),

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
                    'Família',
                    snake.family,
                  ),

                  infoRow(
                    'Gênero',
                    snake.genus,
                  ),

                  infoRow(
                    'Venenosa',
                    snake.poisonous
                        ? 'Sim'
                        : 'Não',
                  ),

                  infoRow(
                    'Tipo de dentição',
                    snake.dentition_type
                        .toString(),
                  ),

                  infoRow(
                    'Tipo de veneno',
                    snake.venomType,
                  ),

                  infoRow(
                    'Antiveneno',
                    snake.effectiveAntivenom
                        ?? 'Não informado',
                  ),

                  const SizedBox(height: 20),

                  const Text(

                    'Descrição',

                    style: TextStyle(

                      fontSize: 20,

                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(

                    snake.description
                        ?? 'Sem descrição',

                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget infoRow(
      String title,
      String value,
      ) {

    return Padding(

      padding:
      const EdgeInsets.only(bottom: 12),

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
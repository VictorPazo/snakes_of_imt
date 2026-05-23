import 'package:flutter/material.dart';

import '../models/snake_model.dart';

class SnakeInformationScreen extends StatelessWidget {

  final SnakeModel snake;

  final double confidence;

  const SnakeInformationScreen({

    super.key,

    required this.snake,

    required this.confidence,
  });

  @override
  Widget build(BuildContext context) {

    const String supabaseUrl =
        'https://onisczwmchpouqrkxhli.supabase.co';

    final snakeImageUrl =
        '$supabaseUrl/storage/v1/object/public/'
        'snake-species/${snake.imageName}';

    return Scaffold(

      backgroundColor: const Color(0xFF115F15),

      appBar: AppBar(

        backgroundColor: const Color(0xFF115F15),

        elevation: 0,

        title: const Text(
          'Snake Identified',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(20),

        child: Column(

          crossAxisAlignment:
          CrossAxisAlignment.center,

          children: [

            ClipRRect(

              borderRadius:
              BorderRadius.circular(20),

              child: Image.network(

                snakeImageUrl,

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

            const SizedBox(height: 10),

            Text(

              'Confidence: ${confidence.toStringAsFixed(1)}%',

              style: const TextStyle(

                color: Colors.white70,

                fontSize: 18,
              ),
            ),

            const SizedBox(height: 25),

            Container(

              padding: const EdgeInsets.all(20),

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
                    'Family',
                    snake.family,
                  ),

                  infoRow(
                    'Genus',
                    snake.genus,
                  ),

                  infoRow(
                    'Poisonous',
                    snake.poisonous
                        ? 'Yes'
                        : 'No',
                  ),

                  infoRow(
                    'Dangerousness',
                    snake.dangerousness
                        .toString(),
                  ),

                  infoRow(
                    'Venom Type',
                    snake.venomType,
                  ),

                  infoRow(
                    'Antivenom',
                    snake.effectiveAntivenom
                        ?? 'Not informed',
                  ),

                  const SizedBox(height: 20),

                  const Text(

                    'Description',

                    style: TextStyle(

                      fontSize: 20,

                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(

                    snake.description
                        ?? 'No description',

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

        crossAxisAlignment:
        CrossAxisAlignment.start,

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
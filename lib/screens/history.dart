import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/snake_model.dart';
import 'snake_information.dart';
import 'home.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() =>
      _HistoryPageState();
}

class _HistoryPageState
    extends State<HistoryPage> {

  final Color primaryGreen =
  const Color(0xFF12352A);

  final supabase =
      Supabase.instance.client;

  List<dynamic> historic = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();

    loadHistoric();
  }

  // 🔥 CARREGAR HISTÓRICO
  Future<void> loadHistoric() async {

    final user =
        supabase.auth.currentUser;

    if (user == null) return;

    try {

      final response =

      await supabase

          .from('snake_historic')

          .select('''
            *,
            snakes(*)
          ''')

          .eq(
        'profiles_id',
        user.id,
      )

          .order(
        'data_photo',
        ascending: false,
      );

      setState(() {

        historic = response;

        loading = false;
      });

    } catch (e) {

      debugPrint(
        "Erro histórico: $e",
      );
    }
  }

  // 🗑️ DELETAR
  Future<void> deleteHistoric(
      int id,
      ) async {

    try {

      await supabase

          .from('snake_historic')

          .delete()

          .eq('id', id);

      loadHistoric();

    } catch (e) {

      debugPrint(
        "Erro delete: $e",
      );
    }
  }

  // 📅 FORMATAR DATA
  String formatDate(String date) {

    final parsed =
    DateTime.parse(date);

    return
      "${parsed.day.toString().padLeft(2, '0')}/"
          "${parsed.month.toString().padLeft(2, '0')}/"
          "${parsed.year}";
  }

  // 🖼️ URL DA IMAGEM
  String getImageUrl(String path) {

    if (path.startsWith('http')) {
      return path;
    }

    return supabase.storage

        .from('user-history')

        .getPublicUrl(path);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: primaryGreen,

      appBar: AppBar(

        backgroundColor: Colors.transparent,

        elevation: 0,

        centerTitle: true,

        leading: IconButton(

          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),

          onPressed: () {

            Navigator.pushAndRemoveUntil(

              context,

              MaterialPageRoute(
                builder: (_) =>
                const HomePage(),
              ),

                  (route) => false,
            );
          },
        ),

        title: const Text(

          "Histórico",

          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),

      body: loading

          ? const Center(

        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      )

          : historic.isEmpty

          ? const Center(

        child: Text(

          "Nenhuma serpente identificada",

          style: TextStyle(

            color: Colors.white,

            fontSize: 18,
          ),
        ),
      )

          : ListView.builder(

        padding:
        const EdgeInsets.all(20),

        itemCount: historic.length,

        itemBuilder: (context, index) {

          final item = historic[index];

          final snake =
          item['snakes'];

          final imagePath =
          item['image_url'];

          final imageUrl =
          getImageUrl(imagePath);

          final date =
          item['data_photo'];

          return Dismissible(

            key: Key(
              item['id'].toString(),
            ),

            direction:
            DismissDirection.endToStart,

            confirmDismiss: (_) async {

              return await showDialog(

                context: context,

                builder: (_) {

                  return AlertDialog(

                    title: const Text(
                      "Excluir",
                    ),

                    content: const Text(
                      "Deseja excluir este histórico?",
                    ),

                    actions: [

                      TextButton(

                        onPressed: () {

                          Navigator.pop(
                            context,
                            false,
                          );
                        },

                        child: const Text(
                          "Cancelar",
                        ),
                      ),

                      ElevatedButton(

                        style:
                        ElevatedButton.styleFrom(

                          backgroundColor:
                          Colors.red,
                        ),

                        onPressed: () {

                          Navigator.pop(
                            context,
                            true,
                          );
                        },

                        child: const Text(
                          "Excluir",
                        ),
                      ),
                    ],
                  );
                },
              );
            },

            onDismissed: (_) {

              deleteHistoric(
                item['id'],
              );
            },

            background: Container(

              alignment:
              Alignment.centerRight,

              padding:
              const EdgeInsets.only(
                right: 25,
              ),

              margin:
              const EdgeInsets.only(
                bottom: 20,
              ),

              decoration: BoxDecoration(

                color: Colors.red,

                borderRadius:
                BorderRadius.circular(
                  20,
                ),
              ),

              child: const Icon(

                Icons.delete,

                color: Colors.white,

                size: 35,
              ),
            ),

            child: GestureDetector(

              onTap: () {

                final snakeModel =
                SnakeModel.fromMap(
                  snake,
                );

                Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder: (_) =>
                        SnakeInformationScreen(

                          snake: snakeModel,

                          confidence: 0,

                          imageUrl:
                          imagePath,
                        ),
                  ),
                );
              },

              child: Container(

                margin:
                const EdgeInsets.only(
                  bottom: 20,
                ),

                decoration: BoxDecoration(

                  color: Colors.white,

                  borderRadius:
                  BorderRadius.circular(
                    20,
                  ),

                  boxShadow: [

                    BoxShadow(

                      color:
                      Colors.black
                          .withOpacity(0.08),

                      blurRadius: 10,

                      offset:
                      const Offset(0, 5),
                    ),
                  ],
                ),

                child: Column(

                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [

                    // 🖼️ FOTO
                    ClipRRect(

                      borderRadius:
                      const BorderRadius.vertical(
                        top:
                        Radius.circular(
                          20,
                        ),
                      ),

                      child: Image.network(

                        imageUrl,

                        height: 220,

                        width: double.infinity,

                        fit: BoxFit.cover,

                        errorBuilder: (
                            context,
                            error,
                            stackTrace,
                            ) {

                          return Container(

                            height: 220,

                            color:
                            Colors.grey[300],

                            child: const Center(

                              child: Icon(

                                Icons.image_not_supported,

                                size: 50,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    Padding(

                      padding:
                      const EdgeInsets.all(
                        18,
                      ),

                      child: Column(

                        crossAxisAlignment:
                        CrossAxisAlignment.start,

                        children: [

                          // 🐍 NOME
                          Text(

                            snake['specie']
                                ?? "Unknown",

                            style:
                            const TextStyle(

                              fontSize: 24,

                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),

                          const SizedBox(
                            height: 15,
                          ),

                          // ☠️ VENENOSA
                          Row(

                            children: [

                              Icon(

                                snake['poisonous']
                                    == true

                                    ? Icons.warning
                                    : Icons.check_circle,

                                color:
                                snake['poisonous']
                                    == true

                                    ? Colors.red
                                    : Colors.green,
                              ),

                              const SizedBox(
                                width: 10,
                              ),

                              Text(

                                snake['poisonous']
                                    == true

                                    ? "Venenosa"
                                    : "Não venenosa",

                                style:
                                const TextStyle(
                                  fontSize: 17,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(
                            height: 15,
                          ),

                          // 📅 DATA
                          Text(

                            formatDate(date),

                            style:
                            const TextStyle(

                              fontSize: 15,

                              color:
                              Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
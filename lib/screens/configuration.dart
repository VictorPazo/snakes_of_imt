import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:easy_localization/easy_localization.dart';

import 'login.dart';

class ConfigurationPage extends StatefulWidget {
  const ConfigurationPage({super.key});

  @override
  State<ConfigurationPage> createState() =>
      _ConfigurationPageState();
}

class _ConfigurationPageState
    extends State<ConfigurationPage> {

  // 🔥 USUÁRIO SUPABASE
  final user =
      Supabase.instance.client.auth.currentUser;

  final Color primaryGreen =
  const Color(0x99115F15);

  bool notificationsEnabled = true;
  bool showConfidence = true;
  bool autoFlash = false;

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  // 🔥 CARREGAR CONFIGURAÇÕES
  Future<void> loadSettings() async {

    final prefs =
    await SharedPreferences.getInstance();

    setState(() {

      notificationsEnabled =
          prefs.getBool(
            'notificationsEnabled',
          ) ??
              true;

      showConfidence =
          prefs.getBool(
            'showConfidence',
          ) ??
              true;

      autoFlash =
          prefs.getBool(
            'autoFlash',
          ) ??
              false;
    });
  }

  // 💾 SALVAR CONFIGURAÇÕES
  Future<void> saveSetting(
      String key,
      bool value,
      ) async {

    final prefs =
    await SharedPreferences.getInstance();

    await prefs.setBool(key, value);
  }

  // 🔄 RESETAR TUTORIAL
  Future<void> resetTutorial() async {

    final prefs =
    await SharedPreferences.getInstance();

    await prefs.setBool(
      'naoMostrarTutorial',
      false,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "tutorial_reset".tr(),
        ),
      ),
    );
  }

  // 🚪 LOGOUT
  Future<void> logout() async {

    await Supabase.instance.client.auth
        .signOut();

    Navigator.pushAndRemoveUntil(
      context,

      MaterialPageRoute(
        builder: (_) => LoginPage(),
      ),

          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: primaryGreen,

      appBar: AppBar(

        backgroundColor: Colors.transparent,

        elevation: 0,

        centerTitle: true,

        title: Text(
          "settings".tr(),

          style: const TextStyle(
            color: Colors.white,
          ),
        ),

        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(20),

        child: Column(

          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            // 👤 CONTA
            buildSectionTitle(
              "account".tr(),
            ),

            buildCard(

              child: Column(

                children: [

                  ListTile(

                    leading:
                    const Icon(Icons.person),

                    title: Text(
                      user?.userMetadata?['nome']
                          ??
                          "user".tr(),
                    ),

                    subtitle: Text(
                      user?.email ??
                          "no_email".tr(),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ⚙️ PREFERÊNCIAS
            buildSectionTitle(
              "preferences".tr(),
            ),

            buildCard(

              child: Column(

                children: [

                  SwitchListTile(

                    value:
                    notificationsEnabled,

                    activeColor:
                    const Color(0xFF115F15),

                    title: Text(
                      "enable_notifications"
                          .tr(),
                    ),

                    onChanged: (value) {

                      setState(() {
                        notificationsEnabled =
                            value;
                      });

                      saveSetting(
                        'notificationsEnabled',
                        value,
                      );
                    },
                  ),

                  const Divider(),

                  ListTile(

                    leading:
                    const Icon(Icons.refresh),

                    title: Text(
                      "show_tutorial_again"
                          .tr(),
                    ),

                    onTap: resetTutorial,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🧠 IA
            buildSectionTitle(
              "ai".tr(),
            ),

            buildCard(

              child: Column(

                children: [

                  SwitchListTile(

                    value: showConfidence,

                    activeColor:
                    const Color(0xFF115F15),

                    title: Text(
                      "show_ai_confidence"
                          .tr(),
                    ),

                    subtitle: Text(
                      "show_accuracy_percentage"
                          .tr(),
                    ),

                    onChanged: (value) {

                      setState(() {
                        showConfidence = value;
                      });

                      saveSetting(
                        'showConfidence',
                        value,
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 📸 CÂMERA
            buildSectionTitle(
              "camera".tr(),
            ),

            buildCard(

              child: Column(

                children: [

                  SwitchListTile(

                    value: autoFlash,

                    activeColor:
                    const Color(0xFF115F15),

                    title: Text(
                      "automatic_flash".tr(),
                    ),

                    onChanged: (value) {

                      setState(() {
                        autoFlash = value;
                      });

                      saveSetting(
                        'autoFlash',
                        value,
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🌍 IDIOMA
            buildSectionTitle(
              "language".tr(),
            ),

            buildCard(

              child: Column(

                children: [

                  // 🇧🇷 PORTUGUÊS
                  ListTile(

                    leading: const Text(
                      '🇧🇷',

                      style: TextStyle(
                        fontSize: 24,
                      ),
                    ),

                    title: const Text(
                      'Português',
                    ),

                    onTap: () async {

                      await context.setLocale(
                        const Locale(
                          'pt',
                          'BR',
                        ),
                      );

                      ScaffoldMessenger.of(context)
                          .showSnackBar(

                        SnackBar(
                          content: Text(
                            "language_changed_pt"
                                .tr(),
                          ),
                        ),
                      );
                    },
                  ),

                  const Divider(),

                  // 🇺🇸 ENGLISH
                  ListTile(

                    leading: const Text(
                      '🇺🇸',

                      style: TextStyle(
                        fontSize: 24,
                      ),
                    ),

                    title: const Text(
                      'Inglês',
                    ),

                    onTap: () async {

                      await context.setLocale(
                        const Locale(
                          'en',
                          'US',
                        ),
                      );

                      ScaffoldMessenger.of(context)
                          .showSnackBar(

                        SnackBar(
                          content: Text(
                            "language_changed_en"
                                .tr(),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ℹ️ SOBRE
            buildSectionTitle(
              "about".tr(),
            ),

            buildCard(

              child: Column(

                children: const [

                  ListTile(

                    leading:
                    Icon(Icons.info_outline),

                    title:
                    Text('Snakes of IMT'),

                    subtitle:
                    Text('Version 1.0.0'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 🚪 LOGOUT
            SizedBox(

              width: double.infinity,

              child: ElevatedButton.icon(

                style:
                ElevatedButton.styleFrom(

                  backgroundColor:
                  Colors.red,

                  padding:
                  const EdgeInsets.all(15),
                ),

                onPressed: logout,

                icon: const Icon(
                  Icons.logout,
                  color: Colors.white,
                ),

                label: Text(

                  "logout".tr(),

                  style: const TextStyle(

                    color: Colors.white,

                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 COMPONENTES REUTILIZÁVEIS

  Widget buildSectionTitle(String title) {

    return Padding(

      padding:
      const EdgeInsets.only(bottom: 10),

      child: Text(

        title,

        style: const TextStyle(

          color: Colors.white,

          fontSize: 20,

          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget buildCard({
    required Widget child,
  }) {

    return Container(

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius:
        BorderRadius.circular(20),
      ),

      child: child,
    );
  }
}
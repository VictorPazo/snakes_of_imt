import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'screens.dart';
import '../services/services.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() =>
      _LoginPageState();
}

class _LoginPageState
    extends State<LoginPage> {

  final TextEditingController
  emailController =
  TextEditingController();

  final TextEditingController
  senhaController =
  TextEditingController();

  final Color primaryGreen =
  const Color(0x99115F15);

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: primaryGreen,

      body: Column(

        children: [

          const SizedBox(height: 80),

          // 🔝 LOGO
          CircleAvatar(

            radius: 40,

            backgroundColor: Colors.white,

            child: ClipOval(

              child: Image.asset(

                'assets/logo.png',

                width: 60,
                height: 60,

                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 👋 TITULO
          Text(

            "welcome".tr(),

            style: const TextStyle(

              color: Colors.white,

              fontSize: 28,

              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          // 📄 SUBTITULO
          Text(

            "login_subtitle".tr(),

            textAlign: TextAlign.center,

            style: const TextStyle(
              color: Colors.white70,
            ),
          ),

          const SizedBox(height: 30),

          // 🔲 CARD LOGIN
          Expanded(

            child: Container(

              padding:
              const EdgeInsets.all(20),

              decoration: const BoxDecoration(

                color: Colors.white,

                borderRadius:
                BorderRadius.vertical(

                  top: Radius.circular(25),
                ),
              ),

              child: Column(

                children: [

                  // 📧 EMAIL
                  TextField(

                    controller:
                    emailController,

                    decoration: InputDecoration(

                      labelText:
                      "email".tr(),

                      border:
                      OutlineInputBorder(

                        borderRadius:
                        BorderRadius.circular(
                          10,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // 🔒 SENHA
                  TextField(

                    controller:
                    senhaController,

                    obscureText: true,

                    decoration: InputDecoration(

                      labelText:
                      "password".tr(),

                      border:
                      OutlineInputBorder(

                        borderRadius:
                        BorderRadius.circular(
                          10,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 🔥 BOTÃO LOGIN
                  SizedBox(

                    width: double.infinity,

                    child: ElevatedButton(

                      onPressed: () async {

                        final authService =
                        AuthService();

                        final erro =
                        await authService.login(

                          email:
                          emailController.text,

                          senha:
                          senhaController.text,
                        );

                        if (erro == null) {

                          Navigator.pushReplacement(

                            context,

                            MaterialPageRoute(

                              builder: (_) =>
                              const HomePage(),
                            ),
                          );

                        } else {

                          ScaffoldMessenger.of(context)
                              .showSnackBar(

                            SnackBar(
                              content: Text(erro),
                            ),
                          );
                        }
                      },

                      style:
                      ElevatedButton.styleFrom(

                        backgroundColor:
                        const Color(0xFF115F15),

                        padding:
                        const EdgeInsets.all(15),
                      ),

                      child: Text(

                        "login".tr(),

                        style: const TextStyle(

                          color: Colors.white,

                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // 🆕 CRIAR CONTA
                  GestureDetector(

                    onTap: () {

                      Navigator.push(

                        context,

                        MaterialPageRoute(

                          builder: (_) =>
                          const CadastroPage(),
                        ),
                      );
                    },

                    child: Text(

                      "create_account".tr(),

                      style: const TextStyle(

                        color:
                        Color(0xFF115F15),

                        fontWeight:
                        FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
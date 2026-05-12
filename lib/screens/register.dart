import 'screens.dart';
import '../services/services.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  final TextEditingController confirmaSenhaController = TextEditingController();
  final TextEditingController telefoneController = TextEditingController();

  final Color primaryGreen = const Color(0x99115F15);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryGreen,
      body: SafeArea(
        child: Column(
          children: [

            const SizedBox(height: 20),

            const Text(
              "Cadastro",
              style: TextStyle(color: Colors.white, fontSize: 22),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(25),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [

                      buildField("Nome", nomeController),
                      buildField("Email", emailController),
                      buildField("Senha", senhaController, isPassword: true),
                      buildField("Confirmar senha", confirmaSenhaController, isPassword: true),
                      buildField("Telefone", telefoneController),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (senhaController.text != confirmaSenhaController.text) {

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('As senhas não coincidem'),
                                ),
                              );

                              return;
                            }

                            final authService = AuthService();

                            final erro = await authService.cadastrarUsuario(
                              nome: nomeController.text,
                              email: emailController.text,
                              senha: senhaController.text,
                              telefone: telefoneController.text,
                            );

                            if (erro == null) {

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Usuário cadastrado com sucesso'),
                                ),
                              );

                            } else {

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(erro),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF115F15),
                            padding: const EdgeInsets.all(15),
                          ),
                          child: const Text("Realizar Cadastro"),
                        ),
                      ),

                      const SizedBox(height: 20),

                      IconButton(
                        icon: const Icon(Icons.keyboard_arrow_down, size: 40),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildField(String label, TextEditingController controller,
      {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
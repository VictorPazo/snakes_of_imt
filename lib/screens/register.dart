import 'screens.dart';
import '../services/services.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() =>
      _CadastroPageState();
}

class _CadastroPageState
    extends State<CadastroPage> {

  final TextEditingController nomeController =
  TextEditingController();

  final TextEditingController emailController =
  TextEditingController();

  final TextEditingController senhaController =
  TextEditingController();

  final TextEditingController
  confirmaSenhaController =
  TextEditingController();

  bool mostrarSenha = false;

  bool mostrarConfirmarSenha = false;

  String? estadoSelecionado;

  String? cidadeSelecionada;

  bool tentouCadastrar = false;

  final List<String> estados = [

    'AC','AL','AP','AM','BA','CE','DF','ES',
    'GO','MA','MT','MS','MG','PA','PB','PR',
    'PE','PI','RJ','RN','RS','RO','RR','SC',
    'SP','SE','TO'
  ];

  List<String> cidades = [];

  final Color primaryGreen =
  const Color(0x99115F15);

  // 🔥 VALIDADORES

  bool get nomeInvalido =>
      tentouCadastrar &&
          nomeController.text.trim().isEmpty;

  bool get emailInvalido {

    if (!tentouCadastrar) return false;

    final email =
    emailController.text.trim();

    return email.isEmpty ||
        !email.contains('@');
  }

  bool get senhaInvalida =>
      tentouCadastrar &&
          senhaController.text.length < 6;

  bool get confirmaSenhaInvalida =>
      tentouCadastrar &&
          confirmaSenhaController.text !=
              senhaController.text;

  bool get estadoInvalido =>
      tentouCadastrar &&
          estadoSelecionado == null;

  bool get cidadeInvalida =>
      tentouCadastrar &&
          cidadeSelecionada == null;

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

              style: TextStyle(

                color: Colors.white,

                fontSize: 22,
              ),
            ),

            const SizedBox(height: 20),

            Expanded(

              child: Container(

                padding:
                const EdgeInsets.all(20),

                decoration:
                const BoxDecoration(

                  color: Colors.white,

                  borderRadius:
                  BorderRadius.vertical(

                    top:
                    Radius.circular(25),
                  ),
                ),

                child: SingleChildScrollView(

                  child: Column(

                    children: [

                      buildField(

                        "Nome",

                        nomeController,

                        error:
                        nomeInvalido,
                      ),

                      buildField(

                        "Email",

                        emailController,

                        error:
                        emailInvalido,
                      ),

                      buildField(

                        "Senha",

                        senhaController,

                        isPassword: true,

                        mostrarSenha:
                        mostrarSenha,

                        error:
                        senhaInvalida,

                        onTogglePassword: () {

                          setState(() {

                            mostrarSenha =
                            !mostrarSenha;
                          });
                        },
                      ),

                      buildField(

                        "Confirmar senha",

                        confirmaSenhaController,

                        isPassword: true,

                        mostrarSenha:
                        mostrarConfirmarSenha,

                        error:
                        confirmaSenhaInvalida,

                        onTogglePassword: () {

                          setState(() {

                            mostrarConfirmarSenha =
                            !mostrarConfirmarSenha;
                          });
                        },
                      ),

                      // 🔥 ESTADO
                      Padding(

                        padding:
                        const EdgeInsets.only(
                          bottom: 15,
                        ),

                        child:
                        DropdownButtonFormField<String>(

                          value:
                          estadoSelecionado,

                          decoration:
                          InputDecoration(

                            labelText:
                            'Estado',

                            errorText:
                            estadoInvalido

                                ? 'Selecione um estado'
                                : null,

                            enabledBorder:
                            OutlineInputBorder(

                              borderRadius:
                              BorderRadius.circular(10),

                              borderSide:
                              BorderSide(

                                color:
                                estadoInvalido

                                    ? Colors.red
                                    : Colors.grey,
                              ),
                            ),

                            focusedBorder:
                            OutlineInputBorder(

                              borderRadius:
                              BorderRadius.circular(10),

                              borderSide:
                              BorderSide(

                                color:
                                estadoInvalido

                                    ? Colors.red
                                    : Colors.green,
                              ),
                            ),
                          ),

                          items:
                          estados.map((estado) {

                            return DropdownMenuItem(

                              value: estado,

                              child: Text(
                                estado,
                              ),
                            );
                          }).toList(),

                          onChanged:
                              (value) async {

                            setState(() {

                              estadoSelecionado =
                                  value;

                              cidadeSelecionada =
                              null;

                              cidades = [];
                            });

                            if (value != null) {

                              final ibgeService =
                              IbgeService();

                              final cidadesIBGE =

                              await ibgeService
                                  .buscarCidades(
                                value,
                              );

                              setState(() {

                                cidades =
                                    cidadesIBGE;
                              });
                            }
                          },
                        ),
                      ),

                      // 🔥 CIDADE
                      Padding(

                        padding:
                        const EdgeInsets.only(
                          bottom: 15,
                        ),

                        child:
                        DropdownButtonFormField<String>(

                          value:
                          cidadeSelecionada,

                          decoration:
                          InputDecoration(

                            labelText:
                            'Cidade',

                            errorText:
                            cidadeInvalida

                                ? 'Selecione uma cidade'
                                : null,

                            enabledBorder:
                            OutlineInputBorder(

                              borderRadius:
                              BorderRadius.circular(10),

                              borderSide:
                              BorderSide(

                                color:
                                cidadeInvalida

                                    ? Colors.red
                                    : Colors.grey,
                              ),
                            ),

                            focusedBorder:
                            OutlineInputBorder(

                              borderRadius:
                              BorderRadius.circular(10),

                              borderSide:
                              BorderSide(

                                color:
                                cidadeInvalida

                                    ? Colors.red
                                    : Colors.green,
                              ),
                            ),
                          ),

                          items:
                          cidades.map((cidade) {

                            return DropdownMenuItem(

                              value: cidade,

                              child: Text(
                                cidade,
                              ),
                            );
                          }).toList(),

                          onChanged: (value) {

                            setState(() {

                              cidadeSelecionada =
                                  value;
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 🔥 BOTÃO
                      SizedBox(

                        width: double.infinity,

                        child: ElevatedButton(

                          onPressed: () async {

                            setState(() {

                              tentouCadastrar =
                              true;
                            });

                            if (

                            nomeInvalido ||
                                emailInvalido ||
                                senhaInvalida ||
                                confirmaSenhaInvalida ||
                                estadoInvalido ||
                                cidadeInvalida
                            ) {
                              return;
                            }

                            final authService =
                            AuthService();

                            final erro =

                            await authService
                                .cadastrarUsuario(

                              nome:
                              nomeController.text,

                              email:
                              emailController.text,

                              senha:
                              senhaController.text,

                              estado:
                              estadoSelecionado ?? '',

                              cidade:
                              cidadeSelecionada ?? '',
                            );

                            if (erro == null) {

                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(

                                const SnackBar(

                                  content: Text(
                                    'Usuário cadastrado com sucesso',
                                  ),
                                ),
                              );

                            } else {

                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(

                                SnackBar(
                                  content:
                                  Text(erro),
                                ),
                              );
                            }
                          },

                          style:
                          ElevatedButton.styleFrom(

                            backgroundColor:
                            const Color(0xFFFFFFFF),

                            padding:
                            const EdgeInsets.all(15),
                          ),

                          child: const Text(
                            "Realizar Cadastro",
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      IconButton(

                        icon: const Icon(

                          Icons.keyboard_arrow_down,

                          size: 40,
                        ),

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

  // 🔥 FIELD
  Widget buildField(

      String label,

      TextEditingController controller, {

        bool isPassword = false,

        bool mostrarSenha = false,

        bool error = false,

        VoidCallback? onTogglePassword,
      }) {

    return Padding(

      padding:
      const EdgeInsets.only(bottom: 15),

      child: TextField(

        controller: controller,

        obscureText:
        isPassword ? !mostrarSenha : false,

        autocorrect: false,

        enableSuggestions: false,

        decoration: InputDecoration(

          labelText: label,

          errorText:
          error ? 'Campo inválido' : null,

          enabledBorder:
          OutlineInputBorder(

            borderRadius:
            BorderRadius.circular(10),

            borderSide: BorderSide(

              color:
              error
                  ? Colors.red
                  : Colors.grey,
            ),
          ),

          focusedBorder:
          OutlineInputBorder(

            borderRadius:
            BorderRadius.circular(10),

            borderSide: BorderSide(

              color:
              error
                  ? Colors.red
                  : Colors.green,
            ),
          ),

          errorBorder:
          OutlineInputBorder(

            borderRadius:
            BorderRadius.circular(10),

            borderSide:
            const BorderSide(
              color: Colors.red,
            ),
          ),

          focusedErrorBorder:
          OutlineInputBorder(

            borderRadius:
            BorderRadius.circular(10),

            borderSide:
            const BorderSide(
              color: Colors.red,
              width: 2,
            ),
          ),

          suffixIcon: isPassword

              ? IconButton(

            icon: Icon(

              mostrarSenha

                  ? Icons.visibility
                  : Icons.visibility_off,
            ),

            onPressed:
            onTogglePassword,
          )

              : null,
        ),
      ),
    );
  }
}
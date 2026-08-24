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

  final TextEditingController cidadeBuscaController =
  TextEditingController();

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

                              // 🔎 BUSCA CIDADE
                              // Limpa o texto digitado no campo de busca
                              // sempre que o estado muda, já que a lista
                              // de cidades válidas também mudou.
                              cidadeBuscaController.clear();

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

                      // 🔎 BUSCA CIDADE
                      // Substitui o DropdownButtonFormField de Cidade por um
                      // Autocomplete que filtra a lista `cidades` (já carregada
                      // pelo IbgeService) conforme o usuário digita.
                      Padding(

                        padding:
                        const EdgeInsets.only(
                          bottom: 15,
                        ),

                        child: Autocomplete<String>(

                          optionsBuilder: (TextEditingValue textEditingValue) {

                            // Se nenhum estado foi escolhido ainda, não há
                            // o que sugerir.
                            if (cidades.isEmpty) {
                              return const Iterable<String>.empty();
                            }

                            final query = textEditingValue.text.toLowerCase();

                            if (query.isEmpty) {
                              return cidades;
                            }

                            return cidades.where((cidade) {
                              return cidade.toLowerCase().contains(query);
                            });
                          },

                          onSelected: (String selecao) {

                            setState(() {
                              cidadeSelecionada = selecao;
                            });
                          },

                          fieldViewBuilder: (
                              BuildContext context,
                              TextEditingController fieldController,
                              FocusNode fieldFocusNode,
                              VoidCallback onFieldSubmitted,
                              ) {

                            // Mantém o controller interno do Autocomplete em
                            // sincronia com o nosso, e vice-versa, para que o
                            // clear() feito ao trocar o Estado também limpe
                            // o que está visível no campo de texto.
                            cidadeBuscaController.value = fieldController.value;

                            fieldController.addListener(() {
                              if (fieldController.text != cidadeSelecionada) {
                                // Usuário está digitando algo diferente do que
                                // tinha selecionado antes: invalida a seleção
                                // até que ele escolha uma opção da lista de novo.
                                if (cidadeSelecionada != null &&
                                    fieldController.text != cidadeSelecionada) {
                                  setState(() {
                                    cidadeSelecionada = null;
                                  });
                                }
                              }
                            });

                            return TextFormField(

                              controller: fieldController,

                              focusNode: fieldFocusNode,

                              enabled: cidades.isNotEmpty,

                              decoration: InputDecoration(

                                labelText: cidades.isEmpty
                                    ? 'Selecione um estado primeiro'
                                    : 'Cidade',

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
                            );
                          },

                          optionsViewBuilder: (
                              BuildContext context,
                              AutocompleteOnSelected<String> onSelected,
                              Iterable<String> options,
                              ) {

                            return Align(
                              alignment: Alignment.topLeft,
                              child: Material(
                                elevation: 4,
                                borderRadius: BorderRadius.circular(10),
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxHeight: 220,
                                  ),
                                  child: ListView.builder(
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    itemCount: options.length,
                                    itemBuilder: (context, index) {
                                      final option = options.elementAt(index);
                                      return ListTile(
                                        title: Text(option),
                                        onTap: () => onSelected(option),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 20),

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

                              if (!mounted) return;

                              // 🔁 VOLTAR AO LOGIN
                              // Navega primeiro, e mostra o SnackBar de
                              // sucesso já no contexto da LoginPage —
                              // assim a transição não compete com o
                              // tempo de exibição do SnackBar na tela
                              // de Cadastro, que está sendo removida.
                              Navigator.pushAndRemoveUntil(

                                context,

                                MaterialPageRoute(
                                  builder: (_) => LoginPage(),
                                ),

                                    (route) => false,
                              );

                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(

                                const SnackBar(

                                  content: Text(
                                    'Cadastro criado com sucesso',
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

  // 🧱 CAMPO PADRÃO
  // Constrói um TextFormField padronizado, com suporte a
  // campo de senha (ícone de olho para mostrar/ocultar) e a
  // exibição de erro de validação.
  Widget buildField(
      String label,
      TextEditingController controller, {

        bool isPassword = false,

        bool mostrarSenha = false,

        bool error = false,

        VoidCallback? onTogglePassword,
      }) {

    return Padding(

      padding: const EdgeInsets.only(
        bottom: 15,
      ),

      child: TextFormField(

        controller: controller,

        obscureText:
        isPassword && !mostrarSenha,

        decoration: InputDecoration(

          labelText: label,

          errorText: error
              ? 'Campo inválido'
              : null,

          enabledBorder: OutlineInputBorder(

            borderRadius:
            BorderRadius.circular(10),

            borderSide: BorderSide(

              color: error
                  ? Colors.red
                  : Colors.grey,
            ),
          ),

          focusedBorder: OutlineInputBorder(

            borderRadius:
            BorderRadius.circular(10),

            borderSide: BorderSide(

              color: error
                  ? Colors.red
                  : Colors.green,
            ),
          ),

          // 👁️ MOSTRAR/OCULTAR SENHA
          // Só exibe o ícone de olho quando o campo for de senha.
          suffixIcon: isPassword
              ? IconButton(

            icon: Icon(

              mostrarSenha
                  ? Icons.visibility
                  : Icons.visibility_off,
            ),

            onPressed: onTogglePassword,
          )
              : null,
        ),
      ),
    );
  }
}
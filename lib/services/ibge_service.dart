import 'dart:convert';
import 'package:http/http.dart' as http;

class IbgeService {

  Future<List<String>> buscarCidades(String uf) async {

    final response = await http.get(
      Uri.parse(
        'https://servicodados.ibge.gov.br/api/v1/localidades/estados/$uf/municipios',
      ),
    );

    if (response.statusCode == 200) {

      final List data = jsonDecode(response.body);

      return data
          .map<String>((cidade) => cidade['nome'].toString())
          .toList();

    } else {

      throw Exception('Erro ao carregar cidades');
    }
  }
}
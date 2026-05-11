import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {

  final supabase = Supabase.instance.client;

  Future<String?> cadastrarUsuario({
    required String nome,
    required String email,
    required String senha,
    required String telefone,
  }) async {

    try {
      final AuthResponse response =
          await supabase.auth.signUp(
        email: email,
        password: senha,
      );

      final user = response.user;

      if (user == null) {
        return 'Erro ao criar usuário';
      }

      await supabase.from('profiles').insert({
        'id': user.id,
        'name': nome,
        'mail': email,
        'phone': telefone,
      });

      return null;

    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> login({
    required String email,
    required String senha,
  }) async {

    try {
      await supabase.auth.signInWithPassword(
        email: email,
        password: senha,
      );

      return null;

    } catch (e) {
      return e.toString();
    }
  }

}
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

      if (e is AuthException) {

        switch (e.message) {

          case 'User already registered':
            return 'Este email já está cadastrado';

          case 'Password should be at least 6 characters': // Verificar senhas fortes 
            return 'A senha deve ter pelo menos 6 caracteres';

          default:
            return 'Erro ao cadastrar usuário';
        }
      }

      return 'Erro inesperado! Será implementado em atualizações futuras';
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

      if (e is AuthException) {

        switch (e.message) {

          case 'Invalid login credentials':
            return 'Email ou senha inválidos';

          case 'Email not confirmed':
            return 'Confirme seu email antes de entrar';

          default:
            return 'Erro de autenticação';
        }
      }

      return 'Erro inesperado! Será implementado em atualizações futuras';
    }
  }

}
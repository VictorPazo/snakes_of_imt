import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/snake_model.dart';

class SnakeInformationService {

  final supabase = Supabase.instance.client;

  Future<SnakeModel?> getSnakeById(
      int snakeId,
      ) async {

    try {

      final response = await supabase
          .from('snakes')
          .select()
          .eq('id', snakeId)
          .single();

      return SnakeModel.fromMap(response);

    } catch (e) {

      return null;
    }
  }
}
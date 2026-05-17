import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {

  final supabase = Supabase.instance.client;

  Future<String?> uploadImage(File imageFile) async {

    try {

      final user = supabase.auth.currentUser;

      if (user == null) {
        return null;
      }

      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}.jpg';

      final filePath =
          '${user.id}/$fileName';

      await supabase.storage
          .from('snake-images')
          .upload(
            filePath,
            imageFile,
          );

      final imageUrl = supabase.storage
          .from('snake-images')
          .getPublicUrl(filePath);

      return imageUrl;

    } catch (e) {

      print('Erro upload imagem: $e');

      return null;
    }
  }
}
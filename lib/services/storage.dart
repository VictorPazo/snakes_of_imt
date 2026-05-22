import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/upload_result.dart';

class StorageService {

  final supabase = Supabase.instance.client;

  Future<UploadResult?> uploadImage(
      File imageFile,
      ) async {

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
          .from('user-history')
          .upload(
        filePath,
        imageFile,
      );

      final imageUrl = await supabase.storage
          .from('user-history')
          .createSignedUrl(
        filePath,
        3600,
      );

      return UploadResult(
        filePath: filePath,
        signedUrl: imageUrl,
      );

    } catch (e, stackTrace) {

      debugPrint(
          'Erro ao realizar upload da imagem: $e'
      );

      debugPrint(
          'StackTrace: $stackTrace'
      );

      return null;
    }
  }
}
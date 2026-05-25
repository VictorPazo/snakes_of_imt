import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/upload_result.dart';

class UploadService {

  final supabase =
      Supabase.instance.client;

  Future<UploadResult?> uploadImage(
      File file,
      ) async {

    try {

      final fileName =

          '${DateTime.now().millisecondsSinceEpoch}.jpg';

      final filePath =
          'uploads/$fileName';

      // 🔥 UPLOAD
      await supabase.storage

          .from('user-history')

          .upload(
        filePath,
        file,
      );

      // 🔥 URL
      final publicUrl =

      supabase.storage

          .from('user-history')

          .getPublicUrl(filePath);

      return UploadResult(

        filePath: filePath,

        signedUrl: publicUrl,
      );

    } catch (e) {

      print("UPLOAD ERRO: $e");

      return null;
    }
  }
}
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class IAService {

  //colocar ip da máquina local
  final String baseUrl =
      'http://192.168.0.6:8000';

  Future<Map<String, dynamic>?> predictSnake(
      File imageFile,
      ) async {

    try {

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/predict'),
      );

      request.files.add(

        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
        ),
      );

      final response = await request
          .send()
          .timeout(const Duration(seconds: 30));

      final responseBody =
          await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return jsonDecode(responseBody);
      }

      debugPrint(
        'predictSnake HTTP ${response.statusCode}: $responseBody',
      );

      return null;

    } catch (e, stackTrace) {

      debugPrint('predictSnake erro: $e');
      debugPrint('StackTrace: $stackTrace');

      return null;
    }
  }
}
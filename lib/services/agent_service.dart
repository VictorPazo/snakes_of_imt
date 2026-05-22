import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class IAService {

  final String baseUrl =
      'http://10.2.131.255:8000';

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

      final response =
      await request.send();

      if (response.statusCode == 200) {

        final responseBody =
        await response.stream.bytesToString();

        return jsonDecode(responseBody);
      }

      return null;

    } catch (e) {

      return null;
    }
  }
}
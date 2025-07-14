import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

class ParserService {
  // https://web-production-3945.up.railway.app
  static const String _apiUrl = 'http://localhost:8080/parse';

  static Future<List<Map<String, dynamic>>> parseInstagramLink(String url) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'url': url}),
      );

      if (response.statusCode != 200) {
        throw Exception('Ошибка API: ${response.statusCode}');
      }

      final data = jsonDecode(response.body);
      final List detected = data['results'] ?? [];

      return detected.map<Map<String, dynamic>>((item) {
        return {
          'name': item['name'] ?? 'Unknown',
          'type': item['type'] ?? 'Unknown',
          'source': data['source'] ?? url
        };
      }).toList();
    } catch (e, stack) {
      log('parseInstagramLink error: $e', stackTrace: stack, name: 'ParserService');
      rethrow;
    }
  }
}

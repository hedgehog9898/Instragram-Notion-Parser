import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class NotionService {
  static final _token = dotenv.env['NOTION_TOKEN'];
  static final _databaseId = dotenv.env['NOTION_DATABASE_ID'];

  static Future<void> exportItem(Map item) async {
    final uri = Uri.parse('https://api.notion.com/v1/pages');

    final body = {
      "parent": {"database_id": _databaseId},
      "properties": {
        "Name": {
          "title": [
            {"text": {"content": item['name'] ?? 'Untitled'}}
          ]
        },
        "Type": {
          "multi_select": [
            { "name": item['type'] ?? 'Unknown'}
          ]
        },
        "Watch Status": {
          "status": { "name": "Watchlist" }
        }
      }
    };

    final headers = {
      'Authorization': 'Bearer $_token',
      'Content-Type': 'application/json',
      'Notion-Version': '2022-06-28'
    };

    final res = await http.post(uri, headers: headers, body: jsonEncode(body));

    if (res.statusCode >= 400) {
      throw Exception('Notion API error: ${res.body}');
    }
  }
}

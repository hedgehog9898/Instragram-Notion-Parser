import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'services/parser_service.dart';
import 'services/notion_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = TextEditingController();
  final _box = Hive.box('media_items');
  String? _notionError;

  void _submitLink() async {
    final link = _controller.text.trim();
    if (link.isEmpty) return;

    try {
      final parsedList = await ParserService.parseInstagramLink(link);
      for (final item in parsedList) {
        await _box.add(item);
      }
      _controller.clear();
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    }
  }

  void _deleteItem(int index) {
    _box.deleteAt(index);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final items = _box.values.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Insta Parser')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Instagram link',
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _submitLink,
              child: const Text('Parse and Save'),
            ),
            const SizedBox(height: 20),
            const Divider(),
            if (_notionError != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SelectableText(
                  _notionError!,
                  style: TextStyle(color: _notionError!.startsWith('Ошибка') ? Colors.red : Colors.green),
                ),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (_, index) {
                  final item = items[index] as Map;
                  return ListTile(
                    title: Text(item['name'] ?? 'No title'),
                    subtitle: Text(item['source'] ?? ''),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteItem(index),
                    ),
                  );
                },
              ),
            ),

            ElevatedButton(
              onPressed: () async {
                final items = _box.values.toList();
                _notionError = null;
                setState(() {});

                for (final item in items) {
                  try {
                    await NotionService.exportItem(item as Map);
                  } catch (e) {
                    setState(() {
                      _notionError = 'Ошибка экспорта: $e';
                    });
                    break;
                  }
                }
              },
              child: const Text('Экспортировать в Notion'),
            ),
          ],
        ),
      ),
    );
  }
}

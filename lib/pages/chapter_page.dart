import 'dart:io';
import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import 'reader_page.dart';
import 'package:path/path.dart' as p;

class ChapterPage extends StatelessWidget {
  final String seriesPath;

  const ChapterPage({super.key, required this.seriesPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chapters')),
      body: FutureBuilder<List<Directory>>(
        future: StorageService.listChapters(seriesPath),
        builder: (_, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final chapters = snap.data!;

          return ListView.builder(
            itemCount: chapters.length,
            itemBuilder: (_, i) {
              final name = p.basename(chapters[i].path);
              return ListTile(
                title: Text(name),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ReaderPage(chapterPath: chapters[i].path),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

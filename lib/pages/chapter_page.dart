import 'dart:io';
import 'package:flutter/material.dart';

import '../services/storage_service.dart';
import 'reader_page.dart';

class ChapterPage extends StatelessWidget {
  final String seriesPath;

  const ChapterPage({super.key, required this.seriesPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chapters")),
      body: FutureBuilder<List<Directory>>(
        future: StorageService.listDirectories(seriesPath),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());

          final chapters = snap.data!;
          return ListView.builder(
            itemCount: chapters.length,
            itemBuilder: (_, i) {
              final c = chapters[i];
              return ListTile(
                title: Text(c.path.split("/").last),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReaderPage(chapterPath: c.path),
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

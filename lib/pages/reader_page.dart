import 'dart:io';
import 'package:flutter/material.dart';

import '../services/storage_service.dart';

class ReaderPage extends StatelessWidget {
  final String chapterPath;

  const ReaderPage({super.key, required this.chapterPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reader")),
      body: FutureBuilder<List<File>>(
        future: StorageService.listImages(chapterPath),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());

          final images = snap.data!;
          return ListView.builder(
            itemCount: images.length,
            itemBuilder: (_, i) {
              return Image.file(
                images[i],
                width: double.infinity,
                fit: BoxFit.fitWidth,
              );
            },
          );
        },
      ),
    );
  }
}

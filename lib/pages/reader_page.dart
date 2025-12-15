import 'dart:io';
import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class ReaderPage extends StatelessWidget {
  final String chapterPath;
  const ReaderPage({super.key, required this.chapterPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reader')),
      body: FutureBuilder<List<File>>(
        future: StorageService.listImages(chapterPath),
        builder: (_, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());

          final images = snap.data!;
          if (images.isEmpty) return const Center(child: Text("Tidak ada gambar"));

          return ListView.builder(
            itemCount: images.length,
            itemBuilder: (_, i) => Image.file(
              images[i],
              fit: BoxFit.fitWidth,
            ),
          );
        },
      ),
    );
  }
}

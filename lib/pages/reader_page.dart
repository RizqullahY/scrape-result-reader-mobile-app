import 'dart:io';
import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class ReaderPage extends StatelessWidget {
  final String chapterPath;

  const ReaderPage({super.key, required this.chapterPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reader"),
      ),
      body: FutureBuilder<List<File>>(
        future: StorageService.listImages(chapterPath),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final images = snapshot.data!;

          if (images.isEmpty) {
            return const Center(
              child: Text("No images found"),
            );
          }

          return ListView.builder(
            itemCount: images.length,
            itemBuilder: (context, index) {
              return Image.file(
                images[index],
                width: double.infinity,
                fit: BoxFit.fitWidth,
                errorBuilder: (_, __, ___) => Container(
                  height: 200,
                  alignment: Alignment.center,
                  child: const Icon(Icons.broken_image),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

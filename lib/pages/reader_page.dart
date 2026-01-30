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
        title: const Text('Reader'),
      ),
      body: FutureBuilder<List<File>>(
        future: StorageService.listImages(chapterPath),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snap.hasData || snap.data!.isEmpty) {
            return const Center(child: Text('Tidak ada gambar'));
          }

          final images = snap.data!;

          return ListView.builder(
            key: PageStorageKey(chapterPath), // 🔥 ANTI RESET SCROLL
            cacheExtent: 2000, // 🔥 PRELOAD GAMBAR
            itemCount: images.length,
            itemBuilder: (context, i) {
              return RepaintBoundary(
                child: Image(
                  image: ResizeImage(
                    FileImage(images[i]),
                    width: MediaQuery.of(context).size.width.toInt(),
                  ),
                  fit: BoxFit.fitWidth,
                  gaplessPlayback: true, // 🔥 ANTI KEDIP / RELOAD
                ),
              );
            },
          );
        },
      ),
    );
  }
}

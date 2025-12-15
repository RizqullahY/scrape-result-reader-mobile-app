import 'dart:io';
import 'package:flutter/material.dart';

import '../services/storage_service.dart';

class ReaderPage extends StatelessWidget {
  final String chapterPath;

  const ReaderPage({
    super.key,
    required this.chapterPath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reader"),
      ),
      body: FutureBuilder<List<File>>(
        future: StorageService.listImages(chapterPath),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No images found"));
          }

          final images = snapshot.data!;

          return ListView.builder(
            cacheExtent: 3000,
            itemCount: images.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Image(
                  image: FileImage(images[index]),
                  width: double.infinity,
                  fit: BoxFit.fitWidth,

                  /// ✅ INI AMAN
                  frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                    if (frame != null || wasSynchronouslyLoaded) {
                      return child;
                    }

                    // Skeleton sebelum gambar tampil
                    return Container(
                      width: double.infinity,
                      height: 300,
                      color: Colors.grey.shade300,
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    );
                  },

                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.grey.shade200,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.broken_image,
                        size: 48,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

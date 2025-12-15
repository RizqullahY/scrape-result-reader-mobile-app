import 'dart:io';
import 'package:flutter/material.dart';

import '../services/storage_service.dart';

class ReaderPage extends StatefulWidget {
  final String chapterPath;

  const ReaderPage({
    super.key,
    required this.chapterPath,
  });

  @override
  State<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {
  bool _showMargin = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reader"),
        actions: [
          /// 🔘 Toggle margin
          IconButton(
            icon: Icon(
              _showMargin ? Icons.crop_free : Icons.crop_square,
            ),
            tooltip: _showMargin ? "Hide margin" : "Show margin",
            onPressed: () {
              setState(() {
                _showMargin = !_showMargin;
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<File>>(
        future: StorageService.listImages(widget.chapterPath),
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
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  /// 🔹 Info halaman (opsional tampil selalu)
                  if (_showMargin)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 12,
                      ),
                      child: Text(
                        "Page ${index + 1} / ${images.length}",
                        style: Theme.of(context).textTheme.labelSmall,
                        textAlign: TextAlign.center,
                      ),
                    ),

                  /// 🔹 Image
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: _showMargin ? 12 : 0,
                      left: _showMargin ? 8 : 0,
                      right: _showMargin ? 8 : 0,
                    ),
                    child: Image(
                      image: FileImage(images[index]),
                      width: double.infinity,
                      fit: BoxFit.fitWidth,

                      frameBuilder:
                          (context, child, frame, wasSynchronouslyLoaded) {
                        if (frame != null || wasSynchronouslyLoaded) {
                          return child;
                        }

                        return Container(
                          width: double.infinity,
                          height: 300,
                          color: Colors.grey.shade300,
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
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
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

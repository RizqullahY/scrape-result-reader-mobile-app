import 'dart:io';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../services/storage_service.dart';
import 'package:path/path.dart' as p;

class ReaderPage extends StatefulWidget {
  final String chapterPath;

  const ReaderPage({super.key, required this.chapterPath});

  @override
  State<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {
  bool _showDebug = false;
  int _currentImage = 1;
  int _totalImages = 0;

  void _onVisible(int index, double visibleFraction) {
    if (visibleFraction > 0.6 && _currentImage != index + 1) {
      setState(() {
        _currentImage = index + 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final chapterName = p.basename(widget.chapterPath);

    return Scaffold(
      appBar: AppBar(
        title: _showDebug
            ? Text("Chapter: $chapterName | Image: $_currentImage / $_totalImages")
            : const Text("Reader"),
        actions: [
          IconButton(
            icon: Icon(_showDebug ? Icons.bug_report : Icons.bug_report_outlined),
            tooltip: "Toggle debug info",
            onPressed: () {
              setState(() {
                _showDebug = !_showDebug;
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<File>>(
        future: StorageService.listImages(widget.chapterPath),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final images = snapshot.data!;
          _totalImages = images.length;

          return ListView.builder(
            cacheExtent: 3000,
            itemCount: images.length,
            itemBuilder: (context, index) {
              return VisibilityDetector(
                key: Key('image-$index'),
                onVisibilityChanged: (info) {
                  _onVisible(index, info.visibleFraction);
                },
                child: Image(
                  image: FileImage(images[index]),
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                  frameBuilder: (context, child, frame, wasSync) {
                    if (frame != null || wasSync) return child;
                    return Container(
                      height: 300,
                      color: Colors.grey.shade300,
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    );
                  },
                  errorBuilder: (_, __, ___) => Container(
                    height: 200,
                    alignment: Alignment.center,
                    child: const Icon(Icons.broken_image),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

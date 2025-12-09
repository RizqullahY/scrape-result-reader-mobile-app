import 'dart:io';
import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';

void main() {
  runApp(const ComicApp());
}

class ComicApp extends StatelessWidget {
  const ComicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Offline Comic Reader",
      theme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? comicsPath;

  Future<String?> pickZip() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );
    return res?.files.single.path;
  }

  Future<String> unzipComic(String zipPath) async {
    final dir = await getApplicationDocumentsDirectory();
    final outputDir = Directory("${dir.path}/comics");

    if (!outputDir.existsSync()) {
      outputDir.createSync(recursive: true);
    }

    final bytes = File(zipPath).readAsBytesSync();
    final archive = ZipDecoder().decodeBytes(bytes);

    for (final file in archive) {
      final filePath = "${outputDir.path}/${file.name}";
      if (file.isFile) {
        File(filePath)
          ..createSync(recursive: true)
          ..writeAsBytesSync(file.content as List<int>);
      } else {
        Directory(filePath).createSync(recursive: true);
      }
    }

    return outputDir.path;
  }

  Future<void> importZip() async {
    final zip = await pickZip();
    if (zip == null) return;

    final path = await unzipComic(zip);
    setState(() {
      comicsPath = path;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Offline Comic Reader")),
      body: comicsPath == null
          ? Center(
              child: ElevatedButton(
                onPressed: importZip,
                child: const Text("Import ZIP Komik"),
              ),
            )
          : FutureBuilder<List<Directory>>(
              future: listSeries(comicsPath!),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final series = snapshot.data!;

                return ListView.builder(
                  itemCount: series.length,
                  itemBuilder: (context, i) {
                    final s = series[i];
                    return ListTile(
                      title: Text(s.path.split("/").last),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ChapterPage(seriesPath: s.path),
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

Future<List<Directory>> listSeries(String rootPath) async {
  return Directory(rootPath)
      .listSync()
      .whereType<Directory>()
      .toList();
}

class ChapterPage extends StatelessWidget {
  final String seriesPath;

  const ChapterPage({super.key, required this.seriesPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chapters")),
      body: FutureBuilder<List<Directory>>(
        future: listChapters(seriesPath),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

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
                      builder: (_) =>
                          ReaderPage(chapterPath: c.path),
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

Future<List<Directory>> listChapters(String seriesPath) async {
  return Directory(seriesPath)
      .listSync()
      .whereType<Directory>()
      .toList();
}

class ReaderPage extends StatelessWidget {
  final String chapterPath;

  const ReaderPage({super.key, required this.chapterPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reader")),
      body: FutureBuilder<List<File>>(
        future: listImages(chapterPath),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final images = snap.data!;

          return PageView.builder(
            itemCount: images.length,
            itemBuilder: (_, i) {
              return PhotoView(
                imageProvider: FileImage(images[i]),
              );
            },
          );
        },
      ),
    );
  }
}

Future<List<File>> listImages(String chapterPath) async {
  final files = Directory(chapterPath)
      .listSync()
      .whereType<File>()
      .where((f) =>
          f.path.endsWith(".jpg") ||
          f.path.endsWith(".jpeg") ||
          f.path.endsWith(".png"))
      .toList();

  files.sort((a, b) => a.path.compareTo(b.path));

  return files;
}

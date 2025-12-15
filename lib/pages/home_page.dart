import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../services/unzip_service.dart';
import '../services/storage_service.dart';
import '../pages/chapter_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Directory? comicsRoot;

  @override
  void initState() {
    super.initState();
    _loadRoot();
  }

  Future<void> _loadRoot() async {
    final root = await StorageService.getComicsRoot();
    if (!mounted) return;
    setState(() => comicsRoot = root);
  }

  Future<void> _importZip() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );
    if (res == null) return;

    await UnzipService.unzip(res.files.single.path!);

    if (!mounted) return;
    setState(() {}); // refresh list

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("ZIP berhasil diimport")),
    );
  }

  Future<void> _deleteSeries(Directory dir) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hapus Series?"),
        content: Text(dir.path.split('/').last),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Batal")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Hapus")),
        ],
      ),
    );

    if (ok == true) {
      await StorageService.deleteDirectory(dir);
      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Series berhasil dihapus")));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (comicsRoot == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Comic Reader"),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: _importZip,
          ),
        ],
      ),
      body: FutureBuilder<List<Directory>>(
        future: StorageService.listSeries(comicsRoot!.path),
        builder: (_, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final seriesList = snap.data!;

          if (seriesList.isEmpty) {
            return const Center(
              child: Text("Belum ada komik.\nImport ZIP dulu."),
            );
          }

          return ListView.builder(
            itemCount: seriesList.length,
            itemBuilder: (_, i) {
              final series = seriesList[i];
              final name = series.path.split('/').last;

              return ListTile(
                title: Text(name),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ChapterPage(seriesPath: series.path),
                    ),
                  );
                },
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteSeries(series),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

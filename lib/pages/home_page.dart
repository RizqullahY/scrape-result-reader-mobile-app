import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../services/unzip_service.dart';
import '../services/storage_service.dart';
import 'chapter_page.dart';

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

  Future<void> importZip() async {
    final file = await pickZip();
    if (file == null) return;

    final path = await UnzipService.unzipComic(file);
    setState(() => comicsPath = path);
  }

  Future<void> deleteSeries(Directory folder) async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hapus Folder Ini?"),
        content: Text(folder.path.split("/").last),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Hapus")),
        ],
      ),
    );

    if (confirm == true) {
      await StorageService.deleteFolder(folder);
      setState(() {});
    }
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
              future: StorageService.listDirectories(comicsPath!),
              builder: (context, snap) {
                if (!snap.hasData) return const Center(child: CircularProgressIndicator());

                final list = snap.data!;
                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (_, i) {
                    final folder = list[i];
                    return ListTile(
                      title: Text(folder.path.split("/").last),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteSeries(folder),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChapterPage(seriesPath: folder.path),
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

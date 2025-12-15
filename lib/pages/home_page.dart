import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  @override
  void initState() {
    super.initState();
    loadComicsPath();
  }

  Future<void> loadComicsPath() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString("comicsPath");
    if (!mounted) return;
    setState(() {
      comicsPath = saved;
    });
  }

  Future<String?> pickZip() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );
    return res?.files.single.path;
  }

  Future<void> importZip() async {
    final zip = await pickZip();
    if (zip == null) return;

    // panggil service unzip (pastikan UnzipService.unzipComic ada)
    final path = await UnzipService.unzipComic(zip);

    // simpan path di SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("comicsPath", path);

    // cek mounted sebelum setState / pakai context
    if (!mounted) return;
    setState(() {
      comicsPath = path;
    });

    // beri feedback ke user
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Berhasil mengimport komik!")),
    );
  }

  Future<void> deleteSeries(Directory folder) async {
    // showDialog juga memakai context — pastikan mounted sebelum menampilkan
    final confirm = await showDialog<bool>(
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
      await StorageService.deleteDirectory(folder);

      if (!mounted) return;
      setState(() {});

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Folder berhasil dihapus")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scraping Result Reader"),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: importZip,
          ),
        ],
      ),
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
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snap.hasError) {
                  return Center(child: Text("Error: ${snap.error}"));
                }

                final list = snap.data ?? [];

                if (list.isEmpty) {
                  return const Center(
                    child: Text(
                      "Belum ada komik.\nSilakan import ZIP.",
                      textAlign: TextAlign.center,
                    ),
                  );
                }

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

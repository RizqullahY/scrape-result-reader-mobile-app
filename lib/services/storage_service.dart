import 'dart:io';
// import 'package:path/path.dart' as p;

class StorageService {
  static Future<Directory> getComicsRoot() async {
    final dir = Directory("/data/user/0/com.example.app/app_flutter/comics");

    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    return dir;
  }

  static Future<List<Directory>> listDirectories(String rootPath) async {
    final dir = Directory(rootPath);

    if (!dir.existsSync()) return [];

    return dir
        .listSync()
        .whereType<Directory>()
        .toList();
  }

  static Future<List<File>> listImages(String chapterPath) async {
    final dir = Directory(chapterPath);

    if (!dir.existsSync()) return [];

    final files = dir
        .listSync()
        .whereType<File>()
        .where((file) {
          final name = file.path.toLowerCase();
          return name.endsWith(".jpg") ||
              name.endsWith(".jpeg") ||
              name.endsWith(".png");
        })
        .toList();

    files.sort((a, b) => a.path.compareTo(b.path));
    return files;
  }

  static Future<void> deleteDirectory(Directory dir) async {
    if (dir.existsSync()) {
      dir.deleteSync(recursive: true);
    }
  }
}

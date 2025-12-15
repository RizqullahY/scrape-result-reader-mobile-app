import 'dart:io';

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
    return dir.listSync().whereType<Directory>().toList();
  }

  static Future<List<File>> listImages(String chapterPath) async {
    final dir = Directory(chapterPath);
    if (!dir.existsSync()) return [];

    final files = dir
        .listSync()
        .whereType<File>()
        .where((file) {
          final name = file.path.toLowerCase();
          return name.endsWith('.jpg') ||
              name.endsWith('.jpeg') ||
              name.endsWith('.png');
        })
        .toList();

    files.sort((a, b) {
      final aNum = _fileNumber(a);
      final bNum = _fileNumber(b);
      return aNum.compareTo(bNum);
    });

    return files;
  }

  static int _fileNumber(File file) {
    final name = file.uri.pathSegments.last; // "001.jpg"
    final base = name.split('.').first;      // "001"
    return int.tryParse(base) ?? 0;
  }

  static Future<void> deleteDirectory(Directory dir) async {
    if (dir.existsSync()) {
      dir.deleteSync(recursive: true);
    }
  }
}

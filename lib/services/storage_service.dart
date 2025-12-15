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

    // 🔥 SORTING NUMERIK YANG BENER
    files.sort((a, b) {
      final aNum = _extractNumber(a.path);
      final bNum = _extractNumber(b.path);

      if (aNum != bNum) {
        return aNum.compareTo(bNum);
      }

      // fallback kalau angka sama
      return a.path.compareTo(b.path);
    });

    return files;
  }

  static int _extractNumber(String path) {
    final name = path.split('/').last;
    final match = RegExp(r'\d+').firstMatch(name);
    return match != null ? int.parse(match.group(0)!) : 0;
  }

  static Future<void> deleteDirectory(Directory dir) async {
    if (dir.existsSync()) {
      dir.deleteSync(recursive: true);
    }
  }
}

import 'dart:io';
import 'package:path/path.dart' as p;

class StorageService {
  /// ROOT folder comics
  static Future<Directory> getComicsRoot() async {
    final dir = Directory("/data/user/0/com.example.app/app_flutter/comics");
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir;
  }

  /// List SERIES atau CHAPTER di path manapun
  static Future<List<Directory>> listFolders(String path) async {
    final dir = Directory(path);
    if (!dir.existsSync()) return [];
    final list = dir.listSync().whereType<Directory>().toList();
    list.sort((a, b) => a.path.compareTo(b.path));
    return list;
  }

  /// List IMAGE dalam chapter
  static Future<List<File>> listImages(String chapterPath) async {
    final dir = Directory(chapterPath);
    if (!dir.existsSync()) return [];

    final images = dir
        .listSync()
        .whereType<File>()
        .where((f) {
          final n = f.path.toLowerCase();
          return n.endsWith('.jpg') ||
              n.endsWith('.jpeg') ||
              n.endsWith('.png') ||
              n.endsWith('.webp');
        })
        .toList();

    images.sort((a, b) {
      final aNum = _num(p.basename(a.path));
      final bNum = _num(p.basename(b.path));
      return aNum.compareTo(bNum);
    });

    return images;
  }

  /// Hapus folder apapun
  static Future<void> deleteDirectory(Directory dir) async {
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  }

  static int _num(String name) {
    final m = RegExp(r'\d+').firstMatch(name);
    return m == null ? 0 : int.parse(m.group(0)!);
  }
}

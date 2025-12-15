import 'dart:io';
import 'package:path/path.dart' as p;

class StorageService {

  /// ROOT folder comics
  static Future<Directory> getComicsRoot() async {
    final dir = Directory("/data/user/0/com.example.app/app_flutter/comics");
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir;
  }

  /// List folder SERIES di root comics
  static Future<List<Directory>> listSeries(String rootPath) async {
    final dir = Directory(rootPath);
    if (!dir.existsSync()) return [];
    final series = dir.listSync().whereType<Directory>().toList();
    series.sort((a, b) => a.path.compareTo(b.path));
    return series;
  }

  /// List CHAPTER dalam satu SERIES
  static Future<List<Directory>> listChapters(String seriesPath) async {
    final dir = Directory(seriesPath);
    if (!dir.existsSync()) return [];
    final chapters = dir.listSync().whereType<Directory>().toList();
    chapters.sort((a, b) => a.path.compareTo(b.path));
    return chapters;
  }

  /// List IMAGE dalam satu CHAPTER
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

  /// Hapus folder (series atau chapter)
  static Future<void> deleteDirectory(Directory dir) async {
    if (dir.existsSync()) {
      dir.deleteSync(recursive: true);
    }
  }

  static int _num(String name) {
    final m = RegExp(r'\d+').firstMatch(name);
    return m == null ? 0 : int.parse(m.group(0)!);
  }
}

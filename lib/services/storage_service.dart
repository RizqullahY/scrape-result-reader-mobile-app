import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class StorageService {
  /// ROOT folder comics (ANDROID ONLY, AMAN)
  static Future<Directory> getComicsRoot() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'comics'));
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir;
  }

  /// List folder (series / chapter)
  static Future<List<Directory>> listFolders(String path) async {
    final dir = Directory(path);
    if (!dir.existsSync()) return [];

    final list = dir.listSync().whereType<Directory>().toList();
    list.sort((a, b) => a.path.compareTo(b.path));
    return list;
  }

  /// List image dalam chapter (URUT BENAR)
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

    // SORT AMAN (001, 002, 010)
    images.sort((a, b) =>
        p.basename(a.path).compareTo(p.basename(b.path)));

    return images;
  }

  static Future<void> deleteDirectory(Directory dir) async {
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  }
}
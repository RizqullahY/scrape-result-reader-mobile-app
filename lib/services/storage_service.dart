import 'dart:io';

class StorageService {
  static Future<List<Directory>> listDirectories(String path) async {
    return Directory(path)
        .listSync()
        .whereType<Directory>()
        .toList();
  }

  static Future<List<File>> listImages(String chapterPath) async {
    final files = Directory(chapterPath)
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith(".jpg") ||
                      f.path.endsWith(".jpeg") ||
                      f.path.endsWith(".png"))
        .toList();

    files.sort((a, b) => a.path.compareTo(b.path));

    return files;
  }

  static Future<void> deleteFolder(Directory directory) async {
    directory.deleteSync(recursive: true);
  }
}

import 'dart:io';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;
import 'storage_service.dart';

class UnzipService {
  static Future<String> unzip(String zipPath) async {
    final root = await StorageService.getComicsRoot();
    final seriesName = p.basenameWithoutExtension(zipPath);
    final outDir = Directory(p.join(root.path, seriesName));

    if (!outDir.existsSync()) outDir.createSync(recursive: true);

    final bytes = File(zipPath).readAsBytesSync();
    final archive = ZipDecoder().decodeBytes(bytes);

    for (final f in archive) {
      // STRIP ROOT FOLDER ZIP
      final parts = p.split(f.name);
      final relativePath = parts.length > 1
          ? p.joinAll(parts.sublist(1))
          : parts.first;

      final outPath = p.join(outDir.path, relativePath);

      if (f.isFile) {
        File(outPath)
          ..createSync(recursive: true)
          ..writeAsBytesSync(f.content);
      } else {
        Directory(outPath).createSync(recursive: true);
      }
    }

    return outDir.path;
  }
}
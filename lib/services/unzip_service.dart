import 'dart:io';
import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class UnzipService {
  static Future<String> unzip(String zipPath) async {
    final docs = await getApplicationDocumentsDirectory();
    final seriesName = p.basenameWithoutExtension(zipPath);
    final outDir = Directory(p.join(docs.path, 'comics', seriesName));

    if (!outDir.existsSync()) outDir.createSync(recursive: true);

    final bytes = File(zipPath).readAsBytesSync();
    final archive = ZipDecoder().decodeBytes(bytes);

    for (final f in archive) {
      if (f.name.startsWith('__MACOSX')) continue;
      final outPath = p.join(outDir.path, f.name);

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

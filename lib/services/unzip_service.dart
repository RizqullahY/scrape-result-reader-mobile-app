import 'dart:io';
import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class UnzipService {
  static Future<String> unzipComic(String zipPath) async {
    final docsDir = await getApplicationDocumentsDirectory();

    final zipName = p.basenameWithoutExtension(zipPath);
    final outputDir = Directory(
      p.join(docsDir.path, 'comics', zipName),
    );

    if (!outputDir.existsSync()) {
      outputDir.createSync(recursive: true);
    }

    final bytes = File(zipPath).readAsBytesSync();
    final archive = ZipDecoder().decodeBytes(bytes);

    for (final file in archive) {
      if (file.name.startsWith('__MACOSX')) continue;

      final outPath = p.join(outputDir.path, file.name);

      if (file.isFile) {
        File(outPath)
          ..createSync(recursive: true)
          ..writeAsBytesSync(file.content);
      } else {
        Directory(outPath).createSync(recursive: true);
      }
    }

    // ⬅️ INI YANG DIPASS KE READER
    return outputDir.path;
  }
}

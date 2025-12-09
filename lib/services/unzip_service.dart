import 'dart:io';
import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';

class UnzipService {
  static Future<String> unzipComic(String zipPath) async {
    final dir = await getApplicationDocumentsDirectory();
    final outputDir = Directory("${dir.path}/comics");

    if (!outputDir.existsSync()) {
      outputDir.createSync(recursive: true);
    }

    final bytes = File(zipPath).readAsBytesSync();
    final archive = ZipDecoder().decodeBytes(bytes);

    for (final file in archive) {
      final filePath = "${outputDir.path}/${file.name}";
      if (file.isFile) {
        File(filePath)
          ..createSync(recursive: true)
          ..writeAsBytesSync(file.content);
      } else {
        Directory(filePath).createSync(recursive: true);
      }
    }

    return outputDir.path;
  }
}

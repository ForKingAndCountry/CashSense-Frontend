import 'dart:io';

import 'package:path_provider/path_provider.dart';

class ReportFileService {
  static Future<Directory> reportsDirectory() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/reports');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  static Future<File> fileFor(String fileName) async {
    return File('${(await reportsDirectory()).path}/$fileName');
  }

  static Future<File> write(String fileName, String content) async {
    final file = await fileFor(fileName);
    await file.writeAsString(content);
    return file;
  }

  static Future<String> read(String fileName) async {
    final file = await fileFor(fileName);
    if (!await file.exists()) return '';
    return file.readAsString();
  }

  static Future<void> delete(String fileName) async {
    final file = await fileFor(fileName);
    if (await file.exists()) {
      await file.delete();
    }
  }
}

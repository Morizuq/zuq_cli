import 'dart:io';
import 'package:path/path.dart' as p;

class TemplatesLocator {
  TemplatesLocator._();

  static String getTemplatesPath() {
    try {
      final scriptPath = Platform.script.toFilePath();
      final rootDir = File(scriptPath).parent.parent.path;
      final templatesDir = Directory(p.join(rootDir, 'templates'));
      if (templatesDir.existsSync()) {
        return templatesDir.path;
      }
    } catch (_) {
      // Ignored: fallback to current directory
    }
    return p.join(Directory.current.path, 'templates');
  }
}

import 'dart:io';
import 'dart:isolate';
import 'package:path/path.dart' as p;

class TemplatesLocator {
  TemplatesLocator._();

  static String getTemplatesPath() {
    try {
      final entryPointUri = Uri.parse('package:zuq_cli/zuq_cli.dart');
      final resolvedUri = Isolate.resolvePackageUriSync(entryPointUri);
      if (resolvedUri != null) {
        final entryPointPath = resolvedUri.toFilePath();
        final rootDir = File(entryPointPath).parent.parent.path;
        final templatesDir = Directory(p.join(rootDir, 'templates'));
        if (templatesDir.existsSync()) {
          return templatesDir.path;
        }
      }
    } catch (_) {
      // Ignored: fallback to current directory
    }
    return p.join(Directory.current.path, 'templates');
  }
}

import 'dart:io';

import 'package:path/path.dart' as p;

class DirectoryGenerator {
  const DirectoryGenerator();

  Future<void> generate(String libPath) async {
    final directories = ['core', 'features', 'shared'];

    for (String dir in directories) {
      final directoryPath = p.join(libPath, dir);

      Directory(directoryPath).createSync(recursive: true);

      final gitKeepFile = File(p.join(directoryPath, '.gitkeep'));
      gitKeepFile.writeAsStringSync('');

      print('Created $directoryPath');
    }
  }
}

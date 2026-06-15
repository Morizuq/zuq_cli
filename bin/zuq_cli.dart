import 'dart:io';

import 'package:zuq_cli/core/cli.dart';

void main(List<String> arguments) async {
  final cli = ZuqCli();

  final exitCode = await cli.run(arguments);
  exit(exitCode);
}

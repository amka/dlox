import 'dart:io';

import 'src/scanner.dart';

class Lox {
  static bool hadError = false;

  static void runFile(String path) {
    if (!File(path).existsSync()) {
      print('File not found: $path');
      return;
    }

    final content = File(path).readAsStringSync();
    run(content);
    if (hadError) exit(65);
  }

  static void runPrompt() {
    print('🐸 Running in prompt mode. Press Ctrl+C or type "/exit" to exit.');
    while (true) {
      stdout.write('> ');
      final line = stdin.readLineSync();
      if (line == null || line == '/exit') {
        print('\n✋ Session closed. Bye!');
        break;
      }
      run(line);
      hadError = false;
    }
  }

  static void run(String source) {
    final scanner = Scanner(source);
    for (var token in scanner.scanTokens()) {
      stdout.writeln(token.toString());
    }
  }

  static void error(int line, String message) {
    report(line, "", message);
  }

  static void report(int line, String where, String message) {
    stderr.writeln('[line $line] Error$where: $message');
    hadError = true;
  }
}

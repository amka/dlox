import 'package:dlox/lox.dart';

void main(List<String> arguments) {
  print(arguments);

  if (arguments.length > 1) {
    print('Usage: dlox <script>');
    return;
  } else if (arguments.length == 1) {
    Lox.runFile(arguments[0]);
  } else {
    Lox.runPrompt();
  }
}

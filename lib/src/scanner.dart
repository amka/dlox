import 'package:dlox/src/token.dart';

import '../lox.dart';
import 'keywords.dart' show keywords;

class Scanner {
  final String source;
  final List<Token> tokens = [];

  int start = 0;
  int current = 0;
  int line = 1;

  Scanner(this.source);

  List<Token> scanTokens() {
    while (!isAtEnd()) {
      start = current;
      scanToken();
    }

    tokens.add(Token(TokenType.EOF, "", null, line));
    return tokens;
  }

  bool isAtEnd() {
    return current >= source.length;
  }

  void scanToken() {
    final c = advance();
    switch (c) {
      case '(':
        addToken(TokenType.LEFT_PAREN);
        break;
      case ')':
        addToken(TokenType.RIGHT_PAREN);
        break;
      case '{':
        addToken(TokenType.LEFT_BRACE);
        break;
      case '}':
        addToken(TokenType.RIGHT_BRACE);
        break;
      case ',':
        addToken(TokenType.COMMA);
        break;
      case '.':
        addToken(TokenType.DOT);
        break;
      case '-':
        addToken(TokenType.MINUS);
        break;
      case '+':
        addToken(TokenType.PLUS);
        break;
      case ';':
        addToken(TokenType.SEMICOLON);
        break;
      case '*':
        addToken(TokenType.STAR);
        break;
      case '!':
        addToken(match('=') ? TokenType.BANG_EQUAL : TokenType.BANG);
        break;
      case '=':
        addToken(match('=') ? TokenType.EQUAL_EQUAL : TokenType.EQUAL);
        break;
      case '<':
        addToken(match('=') ? TokenType.LESS_EQUAL : TokenType.LESS);
        break;
      case '>':
        addToken(match('=') ? TokenType.GREATER_EQUAL : TokenType.GREATER);
        break;
      case '/':
        if (match('/')) {
          while (peek() != '\n' && !isAtEnd()) {
            advance();
          }
        } else {
          addToken(TokenType.SLASH);
        }
        break;
      case ' ':
      case '\r':
      case '\t':
        // Ignore whitespace.
        break;
      case '\n':
        line++;
        break;
      case '"':
        string();
        break;
      default:
        if (isDigit(c)) {
          number();
        } else if (isAlpha(c)) {
          identifier();
        } else {
          Lox.error(line, 'Unexpected character.');
        }
        break;
    }
  }

  String advance() {
    return source[current++];
  }

  void addToken(TokenType type, {Object? literal}) {
    final text = source.substring(start, current);
    tokens.add(Token(type, text, literal, line));
  }

  bool match(String expected) {
    if (isAtEnd()) return false;
    if (source[current] != expected) return false;

    current++;
    return true;
  }

  String peek() {
    if (isAtEnd()) return '\0';
    return source[current];
  }

  String peekNext() {
    if (current + 1 >= source.length) return '\0';
    return source[current + 1];
  }

  void string() {
    while (peek() != '"' && !isAtEnd()) {
      // Support of multiline strings.
      if (peek() == '\n') line++;
      {
        advance();
      }
    }

    if (isAtEnd()) {
      Lox.error(line, 'Unterminated string.');
      return;
    }

    // the closing
    advance();

    // Trim the surrounding quotes.
    final value = source.substring(start + 1, current - 1);
    addToken(TokenType.STRING, literal: value);
  }

  void number() {
    while (isDigit(peek())) {
      advance();
    }

    // Look for a fractional part and skip _ in 1_000_000 literals.
    if ((peek() == '.' || peek() == '_') && isDigit(peekNext())) {
      // Consume the "."
      advance();
      while (isDigit(peek())) {
        advance();
      }
    }

    addToken(TokenType.NUMBER,
        literal: double.parse(source.substring(start, current)));
  }

  void identifier() {
    while (isAlphaNumeric(peek())) {
      advance();
    }

    final text = source.substring(start, current);
    final tokenType = keywords[text] ?? TokenType.IDENTIFIER;

    addToken(tokenType);
  }

  bool isDigit(String c) {
    return c.codeUnitAt(0) >= '0'.codeUnitAt(0) &&
        c.codeUnitAt(0) <= '9'.codeUnitAt(0);
  }

  bool isAlpha(String c) {
    return (c.codeUnitAt(0) >= 'a'.codeUnitAt(0) &&
            c.codeUnitAt(0) <= 'z'.codeUnitAt(0)) ||
        (c.codeUnitAt(0) >= 'A'.codeUnitAt(0) &&
            c.codeUnitAt(0) <= 'Z'.codeUnitAt(0));
  }

  bool isAlphaNumeric(String c) {
    return isAlpha(c) || isDigit(c);
  }
}

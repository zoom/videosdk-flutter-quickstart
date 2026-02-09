import 'dart:io';
import 'package:args/args.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:dotenv/dotenv.dart';

// ANSI color codes for terminal output
const String red = '\x1B[31m';
const String yellow = '\x1B[33m';
const String cyan = '\x1B[36m';
const String white = '\x1B[37m';
const String dim = '\x1B[2m';
const String bold = '\x1B[1m';
const String reset = '\x1B[0m';

String? sdkKey;
String? sdkSecret;

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption(
      'role',
      abbr: 'r',
      defaultsTo: '1',
      help: 'Role type (0 = host, 1 = participant, default: 1)',
    )
    ..addOption(
      'expires',
      abbr: 'e',
      defaultsTo: '2',
      help: 'Token expiration time in hours (default: 2)',
    )
    ..addFlag(
      'quiet',
      abbr: 'q',
      negatable: false,
      help: 'Output only the token, no color or extra info',
    )
    ..addFlag(
      'copy-to-clipboard',
      abbr: 'c',
      negatable: false,
      help: 'Copy the token to clipboard',
    )
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Show this help message',
    );

  try {
    final results = parser.parse(arguments);

    if (results['help'] as bool) {
      printHelp(parser);
      exit(0);
    }

    if (results.rest.isEmpty) {
      stderr.writeln('$red$bold✗ Error:$reset Session name is required');
      stderr.writeln('');
      printHelp(parser);
      exit(1);
    }

    final sessionName = results.rest[0];

    validateEnvironment();
    validateSessionName(sessionName);

    final role = int.tryParse(results['role'] as String);
    if (role == null) {
      stderr.writeln('$red$bold✗ Error:$reset Invalid role value: "${results['role']}". Must be a number.');
      exit(1);
    }
    validateRole(role);

    final expiresInHours = double.tryParse(results['expires'] as String);
    if (expiresInHours == null || expiresInHours <= 0) {
      stderr.writeln(
          '$red$bold✗ Error:$reset Invalid expiration time: "${results['expires']}". Must be a positive number.');
      exit(1);
    }

    final token = generateSignature(sessionName, role, expiresInHours);

    if (results['quiet'] as bool) {
      stdout.writeln(token);
    } else {
      stdout.writeln('${dim}Session:$reset $white$sessionName$reset');
      stdout.writeln('${dim}Role:$reset $white$role$reset');
      stdout.writeln('${dim}Expires in:$reset $white$expiresInHours hour(s)$reset');
      stdout.writeln('$dim\nToken:\n$reset$cyan$token$reset');
    }

    if (results['copy-to-clipboard'] as bool) {
      await copyToClipboard(token);
    }
  } catch (e) {
    stderr.writeln('$red$bold✗ Error:$reset $e');
    exit(1);
  }
}

void printHelp(ArgParser parser) {
  stdout.writeln('${cyan}Generate a VideoSDK JWT token for a session$reset');
  stdout.writeln('');
  stdout.writeln('Usage: dart run scripts/generate_token.dart <sessionName> [options]');
  stdout.writeln('');
  stdout.writeln('Arguments:');
  stdout.writeln('  sessionName    Name of the session/topic');
  stdout.writeln('');
  stdout.writeln('Options:');
  stdout.writeln(parser.usage);
}

void validateEnvironment() {
  // Load .env file from project root
  final envFile = File('${Directory.current.path}/.env');
  if (envFile.existsSync()) {
    final env = DotEnv()..load([envFile.path]);
    sdkKey = env['SDK_KEY'];
    sdkSecret = env['SDK_SECRET'];
  } else {
    // Try environment variables
    sdkKey = Platform.environment['SDK_KEY'];
    sdkSecret = Platform.environment['SDK_SECRET'];
  }

  if (sdkKey == null || sdkSecret == null) {
    stderr.writeln('$red$bold✗ Error:$reset SDK_KEY and SDK_SECRET must be set in your environment or .env file');
    stderr.writeln('$dim   Please ensure your .env file contains both variables.$reset');
    exit(1);
  }

  if (sdkKey!.trim().isEmpty || sdkSecret!.trim().isEmpty) {
    stderr.writeln('$red$bold✗ Error:$reset SDK_KEY and SDK_SECRET cannot be empty');
    exit(1);
  }
}

void validateSessionName(String sessionName) {
  if (sessionName.trim().isEmpty) {
    stderr.writeln('$red$bold✗ Error:$reset Session name cannot be empty');
    exit(1);
  }

  if (sessionName.length > 200) {
    stderr.writeln('$red$bold✗ Error:$reset Session name is too long (max 200 characters)');
    exit(1);
  }
}

void validateRole(int role) {
  if (role < 0) {
    stderr.writeln('$red$bold✗ Error:$reset Invalid role: $role. Role must be a non-negative integer.');
    exit(1);
  }

  if (role > 10) {
    stderr.writeln(
        '$yellow$bold⚠ Warning:$reset Role $role is unusually high. Common values are 0 (host) or 1 (participant).');
  }
}

String generateSignature(String sessionName, int role, double expiresInHours) {
  final iat = (DateTime.now().millisecondsSinceEpoch ~/ 1000) - 30;
  final exp = iat + (60 * 60 * expiresInHours).toInt();

  final payload = {
    'app_key': sdkKey,
    'tpc': sessionName,
    'role_type': role,
    'version': 1,
    'iat': iat,
    'exp': exp,
  };

  final jwt = JWT(payload);
  final token = jwt.sign(SecretKey(sdkSecret!), algorithm: JWTAlgorithm.HS256);

  return token;
}

Future<void> copyToClipboard(String text) async {
  try {
    Process? process;

    // Try pbcopy (macOS)
    if (Platform.isMacOS) {
      try {
        process = await Process.start('pbcopy', []);
        process.stdin.write(text);
        await process.stdin.close();
        final exitCode = await process.exitCode;
        if (exitCode == 0) {
          stdout.writeln('$dim✓ Token copied to clipboard$reset');
          return;
        }
      } catch (_) {}
    }

    // Try xclip (Linux)
    if (Platform.isLinux) {
      try {
        process = await Process.start('xclip', ['-selection', 'clipboard']);
        process.stdin.write(text);
        await process.stdin.close();
        final exitCode = await process.exitCode;
        if (exitCode == 0) {
          stdout.writeln('$dim✓ Token copied to clipboard$reset');
          return;
        }
      } catch (_) {}

      // Try xsel as fallback
      try {
        process = await Process.start('xsel', ['--clipboard', '--input']);
        process.stdin.write(text);
        await process.stdin.close();
        final exitCode = await process.exitCode;
        if (exitCode == 0) {
          stdout.writeln('$dim✓ Token copied to clipboard$reset');
          return;
        }
      } catch (_) {}
    }

    // Try clip (Windows)
    if (Platform.isWindows) {
      try {
        process = await Process.start('clip', []);
        process.stdin.write(text);
        await process.stdin.close();
        final exitCode = await process.exitCode;
        if (exitCode == 0) {
          stdout.writeln('$dim✓ Token copied to clipboard$reset');
          return;
        }
      } catch (_) {}
    }

    stderr.writeln('$yellow⚠ Warning:$reset Could not copy to clipboard. Clipboard utility not available.');
  } catch (e) {
    stderr.writeln('$yellow⚠ Warning:$reset Failed to copy to clipboard: $e');
  }
}

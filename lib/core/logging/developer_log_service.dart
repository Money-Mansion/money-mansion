import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class DeveloperLogEntry {
  final DateTime timestamp;
  final String level;
  final String message;
  final String? stackTrace;

  const DeveloperLogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
    this.stackTrace,
  });

  String get line {
    final stack = stackTrace == null ? '' : '\n$stackTrace';
    return '[${timestamp.toIso8601String()}][$level] $message$stack';
  }
}

class DeveloperLogService {
  DeveloperLogService._();

  static const _maxEntries = 500;
  static final ValueNotifier<List<DeveloperLogEntry>> entries =
      ValueNotifier<List<DeveloperLogEntry>>(<DeveloperLogEntry>[]);

  static File? _logFile;
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized || kIsWeb || !kDebugMode) return;
    _initialized = true;
    try {
      final dir = await getTemporaryDirectory();
      final file =
          File('${dir.path}${Platform.pathSeparator}developer_logs.txt');
      if (!await file.exists()) {
        await file.create(recursive: true);
      }
      _logFile = file;
    } catch (_) {
      _logFile = null;
    }
  }

  static void capturePrint(String message) {
    _record('INFO', message);
  }

  static void info(String message) {
    _record('INFO', message);
  }

  static void warning(String message) {
    _record('WARN', message);
  }

  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    final details = error == null ? message : '$message: $error';
    _record('ERROR', details, stackTrace: stackTrace);
  }

  static Future<void> clear() async {
    entries.value = <DeveloperLogEntry>[];
    final file = _logFile;
    if (file != null) {
      try {
        await file.writeAsString('');
      } catch (_) {}
    }
  }

  static Future<String> exportText() async {
    final file = _logFile;
    if (file != null && await file.exists()) {
      return file.readAsString();
    }
    return entries.value.map((entry) => entry.line).join('\n');
  }

  static void _record(
    String level,
    String message, {
    StackTrace? stackTrace,
  }) {
    if (!kDebugMode) return;
    final sanitizedMessage = _sanitize(message);
    final entry = DeveloperLogEntry(
      timestamp: DateTime.now(),
      level: level,
      message: sanitizedMessage,
      stackTrace: stackTrace == null ? null : _sanitize(stackTrace.toString()),
    );
    final next = <DeveloperLogEntry>[...entries.value, entry];
    entries.value = next.length > _maxEntries
        ? next.sublist(next.length - _maxEntries)
        : next;
    unawaited(_append(entry.line));
  }

  static Future<void> _append(String line) async {
    final file = _logFile;
    if (file == null) return;
    try {
      await file.writeAsString('$line\n', mode: FileMode.append);
    } catch (_) {}
  }

  static String _sanitize(String value) {
    return value
        .replaceAll(
          RegExp(r'Bearer\s+[A-Za-z0-9._~+/=-]+', caseSensitive: false),
          'Bearer [redacted]',
        )
        .replaceAll(
          RegExp(r'gsk_[A-Za-z0-9]+'),
          '[redacted-api-key]',
        )
        .replaceAll(
          RegExp(r'gh[pousr]_[A-Za-z0-9_]+'),
          '[redacted-github-token]',
        );
  }
}

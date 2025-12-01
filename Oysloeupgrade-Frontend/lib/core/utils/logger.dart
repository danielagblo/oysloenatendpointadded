import 'dart:developer' as developer;

/// Lightweight wrapper around [developer.log] to keep logging consistent.
void logInfo(String message, {String name = 'APP'}) {
  developer.log(message, name: name, level: 800);
}

void logError(String message, {Object? error, StackTrace? stackTrace, String name = 'APP'}) {
  developer.log(
    message,
    name: name,
    level: 1000,
    error: error,
    stackTrace: stackTrace,
  );
}

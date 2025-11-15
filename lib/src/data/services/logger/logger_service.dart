import 'dart:async';

import 'package:auto_deployment/src/domain/extensions/date_format_ext.dart';

class LoggerService {
  final StreamController<List<String>> logController =
      StreamController<List<String>>.broadcast();
  Stream<List<String>> get logs => logController.stream;
  final List<String> _cachedLogs = <String>[];
  static const int _logStackSize = 100;

  int get length => _cachedLogs.length;

  String? get last => _cachedLogs.lastOrNull;
  String? get first => _cachedLogs.firstOrNull;

  void setLog(List<String> messages) {
    logController.add(messages);
  }

  void clamp(int start, int end) {
    _cachedLogs.replaceRange(
      start,
      end,
      <String>[],
    );
    logController.add(_cachedLogs);
  }

  void clampIfRequired([int max = _logStackSize]) {
    if (_cachedLogs.length > max) {
      final int delta = _cachedLogs.length - _logStackSize;
      clamp(0, delta);
    }
  }

  //TODO: implement log levels
  void log(String message, [bool ignore = false]) {
    if (ignore) return;
    clampIfRequired();
    final String resultM = '[${DateTime.now().formatHhMmSs()}]: '
        '$message';
    logController.add([
      ..._cachedLogs,
      resultM,
    ]);
    _cachedLogs.add(resultM);
  }

  void dispose() {
    logController.close();
  }
}

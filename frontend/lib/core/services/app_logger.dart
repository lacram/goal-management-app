import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

/// 로그 레벨
enum LogLevel {
  debug,
  info,
  warning,
  error,
  fatal;

  String get prefix {
    switch (this) {
      case LogLevel.debug:
        return '🔍 DEBUG';
      case LogLevel.info:
        return '📘 INFO';
      case LogLevel.warning:
        return '⚠️ WARN';
      case LogLevel.error:
        return '❌ ERROR';
      case LogLevel.fatal:
        return '💀 FATAL';
    }
  }
}

/// 앱 로그 서비스
class AppLogger {
  static final AppLogger _instance = AppLogger._internal();
  factory AppLogger() => _instance;
  AppLogger._internal();

  final _dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss.SSS');
  final List<String> _logBuffer = [];
  static const int _maxBufferSize = 1000;
  
  String? _logFilePath;
  IOSink? _logSink;
  
  // PC 로그 파일 경로 (Windows)
  static const String pcLogPath = r'C:\workspace\goal-management-app\logs\app_realtime.log';

  /// 로그 시스템 초기화
  Future<void> initialize() async {
    try {
      // PC 로그 파일 디렉토리 생성
      final pcLogDir = Directory(r'C:\workspace\goal-management-app\logs');
      if (!pcLogDir.existsSync()) {
        pcLogDir.createSync(recursive: true);
      }

      // PC 로그 파일 설정
      _logFilePath = pcLogPath;
      final file = File(_logFilePath!);
      
      // 기존 파일 삭제 후 새로 시작
      if (file.existsSync()) {
        file.deleteSync();
      }
      
      _logSink = file.openWrite(mode: FileMode.writeOnlyAppend);

      info('AppLogger', '로그 시스템 초기화 완료: $_logFilePath');
      info('AppLogger', '='.padRight(80, '='));
      info('AppLogger', '앱 시작 시간: ${DateTime.now()}');
      info('AppLogger', '='.padRight(80, '='));
    } catch (e) {
      debugPrint('로그 시스템 초기화 실패: $e');
    }
  }

  /// 로그 기록
  void _log(LogLevel level, String tag, String message, [dynamic error, StackTrace? stackTrace]) {
    final timestamp = _dateFormat.format(DateTime.now());
    final logMessage = '[$timestamp] ${level.prefix} [$tag] $message';

    // 콘솔 출력
    debugPrint(logMessage);
    if (error != null) {
      debugPrint('Error: $error');
    }
    if (stackTrace != null) {
      debugPrint('StackTrace: $stackTrace');
    }

    // 버퍼에 추가
    _logBuffer.add(logMessage);
    if (error != null) {
      _logBuffer.add('Error: $error');
    }
    if (stackTrace != null) {
      _logBuffer.add('StackTrace: $stackTrace');
    }

    // 버퍼 크기 제한
    if (_logBuffer.length > _maxBufferSize) {
      _logBuffer.removeRange(0, _logBuffer.length - _maxBufferSize);
    }

    // 파일에 기록
    _writeToFile(logMessage, error, stackTrace);
  }

  /// 파일에 로그 기록
  void _writeToFile(String message, dynamic error, StackTrace? stackTrace) {
    try {
      _logSink?.writeln(message);
      if (error != null) {
        _logSink?.writeln('Error: $error');
      }
      if (stackTrace != null) {
        _logSink?.writeln('StackTrace: $stackTrace');
      }
      _logSink?.flush();
    } catch (e) {
      debugPrint('로그 파일 쓰기 실패: $e');
    }
  }

  /// Debug 로그
  void debug(String tag, String message) {
    _log(LogLevel.debug, tag, message);
  }

  /// Info 로그
  void info(String tag, String message) {
    _log(LogLevel.info, tag, message);
  }

  /// Warning 로그
  void warning(String tag, String message, [dynamic error]) {
    _log(LogLevel.warning, tag, message, error);
  }

  /// Error 로그
  void error(String tag, String message, [dynamic error, StackTrace? stackTrace]) {
    _log(LogLevel.error, tag, message, error, stackTrace);
  }

  /// Fatal 로그
  void fatal(String tag, String message, [dynamic error, StackTrace? stackTrace]) {
    _log(LogLevel.fatal, tag, message, error, stackTrace);
  }

  /// 네트워크 요청 로그
  void networkRequest(String method, String url, [Map<String, dynamic>? body]) {
    final message = '$method $url';
    if (body != null) {
      _log(LogLevel.info, 'Network', '$message\nBody: $body');
    } else {
      _log(LogLevel.info, 'Network', message);
    }
  }

  /// 네트워크 응답 로그
  void networkResponse(int statusCode, String url, [dynamic responseBody]) {
    final message = '$statusCode $url';
    if (responseBody != null && responseBody.toString().length < 500) {
      _log(LogLevel.info, 'Network', '$message\nResponse: $responseBody');
    } else {
      _log(LogLevel.info, 'Network', message);
    }
  }

  /// 네트워크 오류 로그
  void networkError(String url, dynamic error, [StackTrace? stackTrace]) {
    _log(LogLevel.error, 'Network', 'Request failed: $url', error, stackTrace);
  }

  /// 화면 전환 로그
  void navigation(String from, String to) {
    _log(LogLevel.debug, 'Navigation', '$from → $to');
  }

  /// 사용자 액션 로그
  void userAction(String action, [Map<String, dynamic>? data]) {
    if (data != null) {
      _log(LogLevel.info, 'UserAction', '$action - Data: $data');
    } else {
      _log(LogLevel.info, 'UserAction', action);
    }
  }

  /// Provider 상태 변경 로그
  void providerStateChange(String provider, String state) {
    _log(LogLevel.debug, 'Provider', '$provider: $state');
  }

  /// 구분선 로그
  void separator([String message = '']) {
    final line = '─'.padRight(80, '─');
    if (message.isNotEmpty) {
      _logSink?.writeln('\n$line');
      _logSink?.writeln('  $message');
      _logSink?.writeln('$line\n');
    } else {
      _logSink?.writeln(line);
    }
    _logSink?.flush();
  }

  /// 버퍼에 있는 모든 로그 가져오기
  List<String> getLogs() {
    return List.unmodifiable(_logBuffer);
  }

  /// 로그 파일 경로 가져오기
  String? getLogFilePath() {
    return _logFilePath;
  }

  /// 로그 클리어
  void clearLogs() {
    _logBuffer.clear();
    info('AppLogger', '로그 버퍼 클리어');
  }

  /// 종료
  Future<void> dispose() async {
    separator('앱 종료');
    info('AppLogger', '로그 시스템 종료');
    await _logSink?.flush();
    await _logSink?.close();
  }
}

/// 전역 로거 인스턴스
final logger = AppLogger();

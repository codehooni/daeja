import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';

class Log {
  // 호출자 정보 추출
  static String _getCaller() {
    final stackTrace = StackTrace.current.toString();
    final lines = stackTrace.split('\n');

    // 스택에서 Log 클래스가 아닌 첫 번째 호출자 찾기
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (!line.contains('Log.') && !line.contains('_getCaller')) {
        // 클래스명과 메서드명 추출
        final match = RegExp(r'#\d+\s+(.+?)\s+\(').firstMatch(line);
        if (match != null) {
          final caller = match.group(1) ?? 'Unknown';
          // 파일 경로 제거하고 클래스.메서드만 반환
          return caller.split('.').take(2).join('.');
        }
      }
    }
    return 'Unknown';
  }

  // 일반 로그 - 흐름 파악용
  static void d(String message) {
    if (kDebugMode) {
      final caller = _getCaller();
      dev.log('💬 [$caller] $message', name: 'DEBUG');
    }
  }

  // API 호출 로그
  static void api(String message) {
    if (kDebugMode) {
      final caller = _getCaller();
      dev.log('🌐 [$caller] $message', name: 'API');
    }
  }

  // 에러 로그
  static void e(String message, [Object? error]) {
    if (kDebugMode) {
      final caller = _getCaller();
      dev.log('❌ [$caller] $message${error != null ? '\n$error' : ''}', name: 'ERROR');
    }
  }

  // 성공 로그
  static void s(String message) {
    if (kDebugMode) {
      final caller = _getCaller();
      dev.log('✅ [$caller] $message', name: 'SUCCESS');
    }
  }
}
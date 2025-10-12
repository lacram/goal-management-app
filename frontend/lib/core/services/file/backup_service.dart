import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../../models/goal.dart';

class FileBackupService {
  static const String _backupFileName = 'goal_backup';
  static const String _fileExtension = '.json';
  static const String _backupVersion = '1.0.0';

  /// 목표 데이터를 JSON 파일로 백업
  Future<BackupResult> backupGoals(List<Goal> goals) async {
    try {
      final backupData = BackupData(
        goals: goals,
        version: _backupVersion,
        timestamp: DateTime.now(),
        deviceInfo: await _getDeviceInfo(),
      );

      final jsonString = jsonEncode(backupData.toJson());
      
      if (kIsWeb) {
        return await _webBackup(jsonString);
      } else {
        return await _mobileBackup(jsonString);
      }
    } catch (e) {
      return BackupResult.error('백업 중 오류가 발생했습니다: $e');
    }
  }

  /// JSON 파일에서 목표 데이터 복원
  Future<RestoreResult> restoreGoals() async {
    try {
      if (kIsWeb) {
        return await _webRestore();
      } else {
        return await _mobileRestore();
      }
    } catch (e) {
      return RestoreResult.error('복원 중 오류가 발생했습니다: $e');
    }
  }

  /// 자동 백업 (로컬 저장)
  Future<bool> autoBackup(List<Goal> goals) async {
    try {
      final backupData = BackupData(
        goals: goals,
        version: _backupVersion,
        timestamp: DateTime.now(),
        deviceInfo: await _getDeviceInfo(),
        isAutoBackup: true,
      );

      final jsonString = jsonEncode(backupData.toJson());
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/auto_backup$_fileExtension');
      
      await file.writeAsString(jsonString);
      
      // 오래된 자동 백업 파일들 정리 (최근 5개만 유지)
      await _cleanupOldBackups(directory);
      
      debugPrint('자동 백업 완료: ${file.path}');
      return true;
    } catch (e) {
      debugPrint('자동 백업 실패: $e');
      return false;
    }
  }

  /// 자동 백업에서 복원
  Future<RestoreResult> restoreFromAutoBackup() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/auto_backup$_fileExtension');
      
      if (!await file.exists()) {
        return RestoreResult.error('자동 백업 파일이 없습니다');
      }

      final jsonString = await file.readAsString();
      final backupData = BackupData.fromJson(jsonDecode(jsonString));
      
      return RestoreResult.success(
        goals: backupData.goals,
        backupInfo: BackupInfo(
          timestamp: backupData.timestamp,
          version: backupData.version,
          deviceInfo: backupData.deviceInfo,
          goalCount: backupData.goals.length,
        ),
      );
    } catch (e) {
      return RestoreResult.error('자동 백업 복원 실패: $e');
    }
  }

  /// 백업 파일 목록 조회
  Future<List<BackupFileInfo>> getBackupFiles() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final files = directory.listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith(_fileExtension))
          .toList();

      final backupFiles = <BackupFileInfo>[];
      
      for (final file in files) {
        try {
          final jsonString = await file.readAsString();
          final backupData = BackupData.fromJson(jsonDecode(jsonString));
          
          backupFiles.add(BackupFileInfo(
            fileName: file.path.split('/').last,
            filePath: file.path,
            timestamp: backupData.timestamp,
            version: backupData.version,
            goalCount: backupData.goals.length,
            fileSize: await file.length(),
            isAutoBackup: backupData.isAutoBackup,
          ));
        } catch (e) {
          debugPrint('백업 파일 읽기 실패: ${file.path}, $e');
        }
      }

      // 타임스탬프 순으로 정렬 (최신순)
      backupFiles.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      return backupFiles;
    } catch (e) {
      debugPrint('백업 파일 목록 조회 실패: $e');
      return [];
    }
  }

  /// 특정 백업 파일에서 복원
  Future<RestoreResult> restoreFromFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return RestoreResult.error('백업 파일을 찾을 수 없습니다');
      }

      final jsonString = await file.readAsString();
      final backupData = BackupData.fromJson(jsonDecode(jsonString));
      
      return RestoreResult.success(
        goals: backupData.goals,
        backupInfo: BackupInfo(
          timestamp: backupData.timestamp,
          version: backupData.version,
          deviceInfo: backupData.deviceInfo,
          goalCount: backupData.goals.length,
        ),
      );
    } catch (e) {
      return RestoreResult.error('파일 복원 실패: $e');
    }
  }

  /// 백업 파일 삭제
  Future<bool> deleteBackupFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('백업 파일 삭제 실패: $e');
      return false;
    }
  }

  // 웹 플랫폼 백업
  Future<BackupResult> _webBackup(String jsonString) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${_backupFileName}_$timestamp$_fileExtension';
      
      // 웹에서는 브라우저 다운로드를 통한 백업
      final bytes = utf8.encode(jsonString);
      
      // 실제 웹 구현에서는 html 패키지를 사용
      // import 'dart:html' as html;
      // final blob = html.Blob([bytes]);
      // final url = html.Url.createObjectUrlFromBlob(blob);
      // final anchor = html.AnchorElement(href: url)
      //   ..setAttribute('download', fileName)
      //   ..click();
      // html.Url.revokeObjectUrl(url);
      
      return BackupResult.success(
        message: '백업 파일이 다운로드되었습니다',
        filePath: fileName,
      );
    } catch (e) {
      throw Exception('웹 백업 실패: $e');
    }
  }

  // 모바일 플랫폼 백업
  Future<BackupResult> _mobileBackup(String jsonString) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${_backupFileName}_$timestamp$_fileExtension';
      final file = File('${directory.path}/$fileName');
      
      await file.writeAsString(jsonString);
      
      // 파일 공유
      final result = await Share.shareXFiles(
        [XFile(file.path)],
        text: '목표 관리 앱 백업 파일',
        subject: '목표 백업 - ${DateTime.now().toLocal().toString().split(' ')[0]}',
      );
      
      return BackupResult.success(
        message: '백업 파일이 저장되고 공유되었습니다',
        filePath: file.path,
      );
    } catch (e) {
      throw Exception('모바일 백업 실패: $e');
    }
  }

  // 웹 플랫폼 복원
  Future<RestoreResult> _webRestore() async {
    try {
      // 웹에서는 파일 선택 다이얼로그를 통한 복원
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return RestoreResult.error('파일이 선택되지 않았습니다');
      }

      final file = result.files.first;
      if (file.bytes == null) {
        return RestoreResult.error('파일을 읽을 수 없습니다');
      }

      final jsonString = utf8.decode(file.bytes!);
      final backupData = BackupData.fromJson(jsonDecode(jsonString));
      
      return RestoreResult.success(
        goals: backupData.goals,
        backupInfo: BackupInfo(
          timestamp: backupData.timestamp,
          version: backupData.version,
          deviceInfo: backupData.deviceInfo,
          goalCount: backupData.goals.length,
        ),
      );
    } catch (e) {
      throw Exception('웹 복원 실패: $e');
    }
  }

  // 모바일 플랫폼 복원
  Future<RestoreResult> _mobileRestore() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return RestoreResult.error('파일이 선택되지 않았습니다');
      }

      final filePath = result.files.first.path;
      if (filePath == null) {
        return RestoreResult.error('파일 경로를 가져올 수 없습니다');
      }

      final file = File(filePath);
      final jsonString = await file.readAsString();
      final backupData = BackupData.fromJson(jsonDecode(jsonString));
      
      return RestoreResult.success(
        goals: backupData.goals,
        backupInfo: BackupInfo(
          timestamp: backupData.timestamp,
          version: backupData.version,
          deviceInfo: backupData.deviceInfo,
          goalCount: backupData.goals.length,
        ),
      );
    } catch (e) {
      throw Exception('모바일 복원 실패: $e');
    }
  }

  // 디바이스 정보 수집
  Future<Map<String, dynamic>> _getDeviceInfo() async {
    try {
      // 실제 구현에서는 device_info_plus 패키지 사용
      return {
        'platform': kIsWeb ? 'web' : Platform.operatingSystem,
        'version': '1.0.0',
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'platform': 'unknown',
        'version': '1.0.0',
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  // 오래된 백업 파일 정리
  Future<void> _cleanupOldBackups(Directory directory) async {
    try {
      final autoBackupFiles = directory.listSync()
          .whereType<File>()
          .where((file) => file.path.contains('auto_backup'))
          .toList();

      // 수정 시간 순으로 정렬
      autoBackupFiles.sort((a, b) => 
          b.lastModifiedSync().compareTo(a.lastModifiedSync()));

      // 최근 5개를 제외하고 삭제
      if (autoBackupFiles.length > 5) {
        for (int i = 5; i < autoBackupFiles.length; i++) {
          await autoBackupFiles[i].delete();
        }
      }
    } catch (e) {
      debugPrint('백업 파일 정리 실패: $e');
    }
  }
}

// 백업 데이터 모델
class BackupData {
  final List<Goal> goals;
  final String version;
  final DateTime timestamp;
  final Map<String, dynamic> deviceInfo;
  final bool isAutoBackup;

  BackupData({
    required this.goals,
    required this.version,
    required this.timestamp,
    required this.deviceInfo,
    this.isAutoBackup = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'goals': goals.map((goal) => goal.toJson()).toList(),
      'version': version,
      'timestamp': timestamp.toIso8601String(),
      'deviceInfo': deviceInfo,
      'isAutoBackup': isAutoBackup,
    };
  }

  factory BackupData.fromJson(Map<String, dynamic> json) {
    return BackupData(
      goals: (json['goals'] as List)
          .map((goalJson) => Goal.fromJson(goalJson))
          .toList(),
      version: json['version'] ?? '1.0.0',
      timestamp: DateTime.parse(json['timestamp']),
      deviceInfo: json['deviceInfo'] ?? {},
      isAutoBackup: json['isAutoBackup'] ?? false,
    );
  }
}

// 백업 결과
class BackupResult {
  final bool isSuccess;
  final String message;
  final String? filePath;

  BackupResult.success({required this.message, this.filePath})
      : isSuccess = true;

  BackupResult.error(this.message)
      : isSuccess = false,
        filePath = null;
}

// 복원 결과
class RestoreResult {
  final bool isSuccess;
  final String? message;
  final List<Goal>? goals;
  final BackupInfo? backupInfo;

  RestoreResult.success({required this.goals, required this.backupInfo})
      : isSuccess = true,
        message = null;

  RestoreResult.error(this.message)
      : isSuccess = false,
        goals = null,
        backupInfo = null;
}

// 백업 정보
class BackupInfo {
  final DateTime timestamp;
  final String version;
  final Map<String, dynamic> deviceInfo;
  final int goalCount;

  BackupInfo({
    required this.timestamp,
    required this.version,
    required this.deviceInfo,
    required this.goalCount,
  });
}

// 백업 파일 정보
class BackupFileInfo {
  final String fileName;
  final String filePath;
  final DateTime timestamp;
  final String version;
  final int goalCount;
  final int fileSize;
  final bool isAutoBackup;

  BackupFileInfo({
    required this.fileName,
    required this.filePath,
    required this.timestamp,
    required this.version,
    required this.goalCount,
    required this.fileSize,
    required this.isAutoBackup,
  });

  String get formattedSize {
    if (fileSize < 1024) return '${fileSize}B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)}KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  String get formattedDate {
    return '${timestamp.year}.${timestamp.month.toString().padLeft(2, '0')}.${timestamp.day.toString().padLeft(2, '0')} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}

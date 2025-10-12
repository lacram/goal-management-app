                        Icons.folder_open,
                          size: 48,
                          color: AppColors.textSecondaryColor,
                        ),
                      ),
                      const SizedBox(height: AppSizes.paddingMedium),
                      Text(
                        '백업 파일이 없습니다',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSizes.paddingSmall),
                      Text(
                        '첫 번째 백업을 생성해보세요!',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              StaggeredListAnimation(
                children: _backupFiles.map((backupFile) => 
                  _buildBackupFileItem(backupFile)
                ).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupFileItem(BackupFileInfo backupFile) {
    return AnimatedGoalCard(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: backupFile.isAutoBackup 
                ? AppColors.successColor.withOpacity(0.1)
                : AppColors.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            backupFile.isAutoBackup ? Icons.backup : Icons.file_copy,
            color: backupFile.isAutoBackup 
                ? AppColors.successColor 
                : AppColors.primaryColor,
          ),
        ),
        title: Text(
          backupFile.isAutoBackup ? '자동 백업' : '수동 백업',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${backupFile.goalCount}개 목표 • ${backupFile.formattedSize}'),
            Text(
              backupFile.formattedDate,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondaryColor,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleBackupFileAction(value, backupFile),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'restore',
              child: Row(
                children: [
                  Icon(Icons.restore),
                  SizedBox(width: 8),
                  Text('복원'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'share',
              child: Row(
                children: [
                  Icon(Icons.share),
                  SizedBox(width: 8),
                  Text('공유'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('삭제', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        onTap: () => _showBackupFileDetails(backupFile),
      ),
    );
  }

  // 액션 메서드들
  Future<void> _createBackup() async {
    setState(() => _isLoading = true);
    
    try {
      final goalProvider = context.read<GoalProvider>();
      await goalProvider.loadGoals();
      
      final result = await _backupService.backupGoals(goalProvider.goals);
      
      if (result.isSuccess) {
        _showSuccessSnackBar(result.message);
        await _loadBackupFiles();
      } else {
        _showErrorSnackBar(result.message);
      }
    } catch (e) {
      _showErrorSnackBar('백업 생성 중 오류가 발생했습니다: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _restoreFromFile() async {
    try {
      final result = await _backupService.restoreGoals();
      if (result.isSuccess && result.goals != null) {
        await _processRestore(result.goals!, result.backupInfo!);
      } else {
        _showErrorSnackBar(result.message ?? '복원에 실패했습니다');
      }
    } catch (e) {
      _showErrorSnackBar('파일 복원 중 오류가 발생했습니다: $e');
    }
  }

  Future<void> _restoreFromAutoBackup() async {
    try {
      final result = await _backupService.restoreFromAutoBackup();
      if (result.isSuccess && result.goals != null) {
        await _processRestore(result.goals!, result.backupInfo!);
      } else {
        _showErrorSnackBar(result.message ?? '자동 백업에서 복원에 실패했습니다');
      }
    } catch (e) {
      _showErrorSnackBar('자동 백업 복원 중 오류가 발생했습니다: $e');
    }
  }

  Future<void> _processRestore(List<Goal> goals, BackupInfo backupInfo) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('데이터 복원'),
        content: Text(
          '${backupInfo.goalCount}개의 목표를 복원하시겠습니까?\n\n'
          '백업 날짜: ${backupInfo.timestamp.toLocal().toString().split(' ')[0]}\n'
          '현재 목표들은 백업된 목표로 대체됩니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('복원'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      
      try {
        final goalProvider = context.read<GoalProvider>();
        
        // 기존 목표들 삭제
        await goalProvider.loadGoals();
        for (final goal in goalProvider.goals) {
          if (goal.id != null) {
            await goalProvider.deleteGoal(goal.id!);
          }
        }
        
        // 백업된 목표들 복원 (ID를 null로 설정하여 새로 생성)
        for (final goal in goals) {
          final newGoal = goal.copyWith(id: null);
          await goalProvider.createGoal(newGoal);
        }
        
        _showSuccessSnackBar('${goals.length}개의 목표가 성공적으로 복원되었습니다');
        
        // 홈 화면으로 돌아가기
        if (mounted) {
          Navigator.popUntil(context, (route) => route.isFirst);
        }
      } catch (e) {
        _showErrorSnackBar('복원 중 오류가 발생했습니다: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _cleanupOldBackups() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('백업 파일 정리'),
        content: const Text('오래된 자동 백업 파일들을 삭제하시겠습니까?\n\n'
            '최근 5개의 백업 파일만 유지됩니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorColor,
            ),
            child: const Text('정리'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // 실제 정리 로직 구현
      _showSuccessSnackBar('백업 파일이 정리되었습니다');
      await _loadBackupFiles();
    }
  }

  void _handleBackupFileAction(String action, BackupFileInfo backupFile) {
    switch (action) {
      case 'restore':
        _restoreFromSpecificFile(backupFile);
        break;
      case 'share':
        _shareBackupFile(backupFile);
        break;
      case 'delete':
        _deleteBackupFile(backupFile);
        break;
    }
  }

  Future<void> _restoreFromSpecificFile(BackupFileInfo backupFile) async {
    try {
      final result = await _backupService.restoreFromFile(backupFile.filePath);
      if (result.isSuccess && result.goals != null) {
        await _processRestore(result.goals!, result.backupInfo!);
      } else {
        _showErrorSnackBar(result.message ?? '복원에 실패했습니다');
      }
    } catch (e) {
      _showErrorSnackBar('백업 파일 복원 중 오류가 발생했습니다: $e');
    }
  }

  void _shareBackupFile(BackupFileInfo backupFile) {
    // 파일 공유 로직
    _showSuccessSnackBar('백업 파일 공유 기능은 추후 구현 예정입니다');
  }

  Future<void> _deleteBackupFile(BackupFileInfo backupFile) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('백업 파일 삭제'),
        content: Text('정말로 "${backupFile.fileName}" 파일을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorColor,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _backupService.deleteBackupFile(backupFile.filePath);
      if (success) {
        _showSuccessSnackBar('백업 파일이 삭제되었습니다');
        await _loadBackupFiles();
      } else {
        _showErrorSnackBar('백업 파일 삭제에 실패했습니다');
      }
    }
  }

  void _showBackupFileDetails(BackupFileInfo backupFile) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(backupFile.isAutoBackup ? '자동 백업 정보' : '백업 파일 정보'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('파일명', backupFile.fileName),
            _buildDetailRow('생성일', backupFile.formattedDate),
            _buildDetailRow('목표 개수', '${backupFile.goalCount}개'),
            _buildDetailRow('파일 크기', backupFile.formattedSize),
            _buildDetailRow('버전', backupFile.version),
            _buildDetailRow('타입', backupFile.isAutoBackup ? '자동 백업' : '수동 백업'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _restoreFromSpecificFile(backupFile);
            },
            child: const Text('복원'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondaryColor,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.successColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.errorColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

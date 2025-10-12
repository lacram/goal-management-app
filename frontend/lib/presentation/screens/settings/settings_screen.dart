import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/theme/app_theme_complete.dart';
import '../../../data/providers/goal_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/animations/animated_widgets.dart';
import '../../widgets/animations/animated_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with TickerProviderStateMixin {
  final NotificationService _notificationService = NotificationService();
  bool _notificationsEnabled = true;
  bool _isLoading = false;
  late AnimationController _themeChangeController;

  @override
  void initState() {
    super.initState();
    _themeChangeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _loadSettings();
  }

  @override
  void dispose() {
    _themeChangeController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _notificationsEnabled = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FadeInWidget(
          child: const Text('설정'),
        ),
        elevation: 0,
      ),
      body: _isLoading
          ? const LoadingWidget(message: '설정을 적용하는 중...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              child: StaggeredListAnimation(
                children: [
                  _buildNotificationSection(),
                  const SizedBox(height: AppSizes.paddingLarge),
                  _buildThemeSection(),
                  const SizedBox(height: AppSizes.paddingLarge),
                  _buildDataSection(),
                  const SizedBox(height: AppSizes.paddingLarge),
                  _buildAppInfoSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildNotificationSection() {
    return _buildSettingsSection(
      title: '알림 설정',
      icon: Icons.notifications,
      children: [
        AnimatedGoalCard(
          child: SwitchListTile(
            title: const Text('알림 활성화'),
            subtitle: Text(_notificationsEnabled 
                ? '목표 리마인더와 알림을 받습니다'
                : '모든 알림이 비활성화됩니다'),
            value: _notificationsEnabled,
            onChanged: _toggleNotifications,
            secondary: PulseAnimation(
              child: Icon(
                _notificationsEnabled ? Icons.notifications_active : Icons.notifications_off,
                color: _notificationsEnabled ? AppColors.successColor : AppColors.textSecondaryColor,
              ),
            ),
          ),
        ),
        if (_notificationsEnabled) ...[
          const Divider(),
          _buildAnimatedListTile(
            leading: Icons.schedule,
            title: '주간 진행률 알림',
            subtitle: '매주 일요일 저녁에 진행률 알림',
            value: true,
            onChanged: (value) {
              if (value) {
                _notificationService.scheduleWeeklyProgressReminder();
              }
            },
          ),
          _buildAnimatedListTile(
            leading: Icons.celebration,
            title: '목표 완료 축하',
            subtitle: '목표 달성시 축하 알림 표시',
            value: true,
            onChanged: (value) {},
          ),
          _buildAnimatedListTile(
            leading: Icons.warning,
            title: '마감일 알림',
            subtitle: '마감일 하루 전과 당일 알림',
            value: true,
            onChanged: (value) {},
          ),
        ],
      ],
    );
  }

  Widget _buildThemeSection() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return _buildSettingsSection(
          title: '테마 설정',
          icon: Icons.palette,
          children: [
            _buildThemeRadioTile(
              title: '시스템 테마',
              subtitle: '기기 설정을 따릅니다',
              value: ThemeMode.system,
              groupValue: themeProvider.themeMode,
              icon: Icons.settings_system_daydream,
              onChanged: (theme) => _changeTheme(themeProvider, theme),
            ),
            _buildThemeRadioTile(
              title: '라이트 모드',
              subtitle: '밝은 테마',
              value: ThemeMode.light,
              groupValue: themeProvider.themeMode,
              icon: Icons.light_mode,
              onChanged: (theme) => _changeTheme(themeProvider, theme),
            ),
            _buildThemeRadioTile(
              title: '다크 모드',
              subtitle: '어두운 테마',
              value: ThemeMode.dark,
              groupValue: themeProvider.themeMode,
              icon: Icons.dark_mode,
              onChanged: (theme) => _changeTheme(themeProvider, theme),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDataSection() {
    return _buildSettingsSection(
      title: '데이터 관리',
      icon: Icons.storage,
      children: [
        _buildActionListTile(
          leading: Icons.backup,
          title: '데이터 내보내기',
          subtitle: '목표 데이터를 JSON 파일로 내보내기',
          trailing: Icons.download,
          onTap: _exportData,
        ),
        _buildActionListTile(
          leading: Icons.restore,
          title: '데이터 가져오기',
          subtitle: '백업 파일에서 목표 데이터 가져오기',
          trailing: Icons.upload,
          onTap: _importData,
        ),
        const Divider(),
        _buildActionListTile(
          leading: Icons.delete_forever,
          title: '모든 데이터 삭제',
          subtitle: '모든 목표와 설정을 영구 삭제',
          trailing: Icons.warning,
          onTap: _showDeleteAllDataDialog,
          isDestructive: true,
        ),
      ],
    );
  }

  Widget _buildAppInfoSection() {
    return _buildSettingsSection(
      title: '앱 정보',
      icon: Icons.info,
      children: [
        _buildActionListTile(
          leading: Icons.apps,
          title: '앱 버전',
          subtitle: '1.0.0',
          trailing: Icons.arrow_forward_ios,
        ),
        _buildActionListTile(
          leading: Icons.help,
          title: '도움말',
          subtitle: '앱 사용법과 FAQ',
          trailing: Icons.arrow_forward_ios,
          onTap: _showHelpDialog,
        ),
        _buildActionListTile(
          leading: Icons.feedback,
          title: '피드백 보내기',
          subtitle: '개선 사항이나 버그 신고',
          trailing: Icons.arrow_forward_ios,
          onTap: _sendFeedback,
        ),
        _buildActionListTile(
          leading: Icons.star,
          title: '앱 평가하기',
          subtitle: '앱스토어에서 평가하기',
          trailing: Icons.arrow_forward_ios,
          onTap: _rateApp,
        ),
      ],
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return AnimatedGoalCard(
      child: Card(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor.withOpacity(0.1),
                    Theme.of(context).primaryColor.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: Theme.of(context).primaryColor),
                  ),
                  const SizedBox(width: AppSizes.paddingMedium),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildThemeRadioTile({
    required String title,
    required String subtitle,
    required ThemeMode value,
    required ThemeMode groupValue,
    required IconData icon,
    required Function(ThemeMode?) onChanged,
  }) {
    final isSelected = value == groupValue;
    
    return AnimatedGoalCard(
      isSelected: isSelected,
      child: RadioListTile<ThemeMode>(
        title: Text(title),
        subtitle: Text(subtitle),
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
        secondary: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected 
                ? Theme.of(context).primaryColor.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isSelected 
                ? Theme.of(context).primaryColor
                : Theme.of(context).iconTheme.color,
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedListTile({
    required IconData leading,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return AnimatedGoalCard(
      child: ListTile(
        leading: Icon(leading),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildActionListTile({
    required IconData leading,
    required String title,
    required String subtitle,
    required IconData trailing,
    VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    return AnimatedGoalCard(
      onTap: onTap,
      child: ListTile(
        leading: Icon(
          leading,
          color: isDestructive ? AppColors.errorColor : null,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? AppColors.errorColor : null,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: Icon(
          trailing,
          color: isDestructive ? AppColors.errorColor : null,
        ),
        onTap: onTap,
      ),
    );
  }

  // 액션 메서드들
  Future<void> _toggleNotifications(bool value) async {
    setState(() => _isLoading = true);

    try {
      if (value) {
        final hasPermission = await _notificationService.requestPermissions();
        if (!hasPermission) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('알림 권한이 필요합니다. 설정에서 권한을 허용해주세요.'),
                backgroundColor: AppColors.warningColor,
              ),
            );
          }
          return;
        }

        await _notificationService.initialize();
        
        final goalProvider = context.read<GoalProvider>();
        await goalProvider.loadAllGoals();
        
        for (final goal in goalProvider.goals) {
          if (goal.reminderEnabled) {
            await _notificationService.scheduleGoalReminder(goal);
          }
          if (goal.dueDate != null) {
            await _notificationService.scheduleDueDateReminder(goal);
          }
        }
        
        await _notificationService.scheduleWeeklyProgressReminder();
      } else {
        await _notificationService.cancelAllNotifications();
      }

      setState(() {
        _notificationsEnabled = value;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(value ? '알림이 활성화되었습니다' : '알림이 비활성화되었습니다'),
            backgroundColor: AppColors.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('알림 설정 중 오류가 발생했습니다: $e'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _changeTheme(ThemeProvider themeProvider, ThemeMode? theme) {
    if (theme != null) {
      // 테마 변경 애니메이션 시작
      _themeChangeController.forward().then((_) {
        themeProvider.setThemeMode(theme);
        _themeChangeController.reverse();
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('테마가 ${_getThemeDisplayName(theme)}(으)로 변경되었습니다'),
          backgroundColor: AppColors.successColor,
        ),
      );
    }
  }

  String _getThemeDisplayName(ThemeMode theme) {
    switch (theme) {
      case ThemeMode.system:
        return '시스템 테마';
      case ThemeMode.light:
        return '라이트 모드';
      case ThemeMode.dark:
        return '다크 모드';
    }
  }

  Future<void> _exportData() async {
    setState(() => _isLoading = true);

    try {
      final goalProvider = context.read<GoalProvider>();
      await goalProvider.loadAllGoals();
      
      final data = {
        'goals': goalProvider.goals.map((goal) => goal.toJson()).toList(),
        'exportDate': DateTime.now().toIso8601String(),
        'version': '1.0.0',
      };

      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('데이터가 성공적으로 내보내졌습니다!'),
            backgroundColor: AppColors.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('데이터 내보내기 중 오류가 발생했습니다: $e'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _importData() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('데이터 가져오기'),
        content: const Text('백업 파일을 선택하여 데이터를 가져올 수 있습니다.\n\n'
            '기존 데이터는 덮어쓰여질 수 있으니 주의하세요.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('파일 선택 기능은 추후 구현 예정입니다'),
                  backgroundColor: AppColors.infoColor,
                ),
              );
            },
            child: const Text('파일 선택'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAllDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '모든 데이터 삭제',
          style: TextStyle(color: AppColors.errorColor),
        ),
        content: const Text(
          '정말로 모든 목표와 설정을 삭제하시겠습니까?\n\n'
          '이 작업은 되돌릴 수 없습니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteAllData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorColor,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAllData() async {
    setState(() => _isLoading = true);

    try {
      final goalProvider = context.read<GoalProvider>();
      await goalProvider.loadAllGoals();
      
      for (final goal in goalProvider.goals) {
        if (goal.id != null) {
          await goalProvider.deleteGoal(goal.id!);
        }
      }

      await _notificationService.cancelAllNotifications();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('모든 데이터가 삭제되었습니다'),
            backgroundColor: AppColors.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('데이터 삭제 중 오류가 발생했습니다: $e'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('도움말'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHelpItem('📝 목표 생성', '새로운 목표를 만들어 체계적으로 관리하세요.'),
              _buildHelpItem('🎯 계층 구조', '평생 목표부터 일간 목표까지 단계별로 설정하세요.'),
              _buildHelpItem('📊 진행률 추적', '하위 목표 완료도에 따라 자동으로 진행률이 계산됩니다.'),
              _buildHelpItem('🔔 알림 설정', '목표별로 리마인더를 설정하여 놓치지 마세요.'),
              _buildHelpItem('📈 통계 분석', '목표 달성률과 분석을 통해 성과를 확인하세요.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(description),
        ],
      ),
    );
  }

  void _sendFeedback() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('피드백 보내기'),
        content: const Text('개선 사항이나 버그가 있으시면 알려주세요!\n\n'
            '실제 앱에서는 이메일 클라이언트나 피드백 폼으로 연결됩니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _rateApp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('앱 평가하기'),
        content: const Text('앱이 도움이 되셨나요? 앱스토어에서 평가를 남겨주세요!\n\n'
            '실제 앱에서는 앱스토어로 연결됩니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('나중에'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('감사합니다! 평가 기능은 실제 배포시 활성화됩니다.'),
                  backgroundColor: AppColors.successColor,
                ),
              );
            },
            child: const Text('평가하기'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/goal_provider.dart';
import '../../../data/models/goal.dart';
import '../../../core/constants/app_constants.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GoalProvider>().loadAllGoals();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 통계'),
        elevation: 0,
      ),
      body: Consumer<GoalProvider>(
        builder: (context, goalProvider, child) {
          final goals = goalProvider.goals;
          
          if (goals.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    '아직 목표가 없습니다',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '목표를 추가하여 통계를 확인해보세요!',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final overallStats = _calculateOverallStats(goals);
          final typeStats = _calculateTypeStats(goals);
          final priorityStats = _calculatePriorityStats(goals);
          final monthlyData = _calculateMonthlyCompletionData(goals);
          final deadlineStats = _calculateDeadlineStats(goals);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 전체 통계 카드
                _buildOverallStatsCard(overallStats),
                const SizedBox(height: 16),
                
                // 타입별 통계
                _buildTypeStatsCard(typeStats),
                const SizedBox(height: 16),
                
                // 우선순위별 통계
                _buildPriorityStatsCard(priorityStats),
                const SizedBox(height: 16),
                
                // 월별 완료 통계
                _buildMonthlyStatsCard(monthlyData),
                const SizedBox(height: 16),
                
                // 마감일 통계
                _buildDeadlineStatsCard(deadlineStats),
                const SizedBox(height: 16),
                
                // 최근 활동
                _buildRecentActivityCard(goals),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverallStatsCard(OverallStats stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '전체 통계',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    '전체 목표',
                    '${stats.totalGoals}개',
                    Icons.flag,
                    AppColors.primaryColor,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '완료된 목표',
                    '${stats.completedGoals}개',
                    Icons.check_circle,
                    AppColors.successColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    '진행중인 목표',
                    '${stats.activeGoals}개',
                    Icons.pending,
                    AppColors.warningColor,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '달성률',
                    '${stats.completionRate.toStringAsFixed(1)}%',
                    Icons.trending_up,
                    _getAchievementColor(stats.completionRate),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getAchievementColor(stats.completionRate).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.psychology,
                    color: _getAchievementColor(stats.completionRate),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getAchievementMessage(stats.completionRate),
                      style: TextStyle(
                        color: _getAchievementColor(stats.completionRate),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeStatsCard(Map<GoalType, TypeStats> typeStats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '타입별 통계',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...typeStats.entries.map((entry) {
              final type = entry.key;
              final stats = entry.value;
              final completionRate = stats.total > 0 
                  ? (stats.completed / stats.total * 100) 
                  : 0.0;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getTypeIcon(type),
                          size: 20,
                          color: AppColors.primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _getTypeText(type),
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        Text(
                          '${stats.completed}/${stats.total}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${completionRate.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _getAchievementColor(completionRate),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: stats.total > 0 ? stats.completed / stats.total : 0,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getAchievementColor(completionRate),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityStatsCard(Map<int, PriorityStats> priorityStats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '우선순위별 통계',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...priorityStats.entries.map((entry) {
              final priority = entry.key;
              final stats = entry.value;
              final completionRate = stats.total > 0 
                  ? (stats.completed / stats.total * 100) 
                  : 0.0;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getPriorityColor(priority),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${_getPriorityText(priority)} 우선순위',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Text(
                      '${stats.completed}/${stats.total}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${completionRate.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _getAchievementColor(completionRate),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyStatsCard(List<MonthlyData> monthlyData) {
    if (monthlyData.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxValue = monthlyData.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '월별 완료 통계',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: monthlyData.map((data) {
                  final height = maxValue > 0 ? (data.value / maxValue) * 150 : 0.0;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '${data.value}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: height,
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            data.month,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeadlineStatsCard(DeadlineStats stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '마감일 현황',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDeadlineItem(
                    '지난 목표',
                    '${stats.overdue}개',
                    Icons.schedule,
                    AppColors.errorColor,
                  ),
                ),
                Expanded(
                  child: _buildDeadlineItem(
                    '오늘 마감',
                    '${stats.dueToday}개',
                    Icons.today,
                    AppColors.warningColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildDeadlineItem(
                    '이번주 마감',
                    '${stats.dueThisWeek}개',
                    Icons.date_range,
                    AppColors.infoColor,
                  ),
                ),
                Expanded(
                  child: _buildDeadlineItem(
                    '마감일 없음',
                    '${stats.noDueDate}개',
                    Icons.schedule_outlined,
                    Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivityCard(List<Goal> goals) {
    final recentGoals = goals
        .where((g) => g.completedAt != null)
        .toList()
      ..sort((a, b) => b.completedAt!.compareTo(a.completedAt!));
    
    final recentlyCompleted = recentGoals.take(5).toList();

    if (recentlyCompleted.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '최근 완료한 목표',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...recentlyCompleted.map((goal) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppColors.successColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            goal.title,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            _getRelativeTime(goal.completedAt!),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      _getTypeIcon(goal.type),
                      size: 16,
                      color: Colors.grey,
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDeadlineItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // 계산 메서드들
  OverallStats _calculateOverallStats(List<Goal> goals) {
    final totalGoals = goals.length;
    final completedGoals = goals.where((g) => g.isCompleted).length;
    final activeGoals = totalGoals - completedGoals;
    final completionRate = totalGoals > 0 ? (completedGoals / totalGoals * 100) : 0.0;

    return OverallStats(
      totalGoals: totalGoals,
      completedGoals: completedGoals,
      activeGoals: activeGoals,
      completionRate: completionRate,
    );
  }

  Map<GoalType, TypeStats> _calculateTypeStats(List<Goal> goals) {
    final Map<GoalType, TypeStats> typeStats = {};
    
    for (final type in GoalType.values) {
      final typeGoals = goals.where((g) => g.type == type).toList();
      final completed = typeGoals.where((g) => g.isCompleted).length;
      
      if (typeGoals.isNotEmpty) {
        typeStats[type] = TypeStats(
          total: typeGoals.length,
          completed: completed,
          active: typeGoals.length - completed,
        );
      }
    }
    
    return typeStats;
  }

  Map<int, PriorityStats> _calculatePriorityStats(List<Goal> goals) {
    final Map<int, PriorityStats> priorityStats = {};
    
    for (int priority = 1; priority <= 3; priority++) {
      final priorityGoals = goals.where((g) => g.priority == priority).toList();
      final completed = priorityGoals.where((g) => g.isCompleted).length;
      
      if (priorityGoals.isNotEmpty) {
        priorityStats[priority] = PriorityStats(
          total: priorityGoals.length,
          completed: completed,
        );
      }
    }
    
    return priorityStats;
  }

  List<MonthlyData> _calculateMonthlyCompletionData(List<Goal> goals) {
    final Map<String, int> monthlyCount = {};
    
    for (final goal in goals.where((g) => g.completedAt != null)) {
      final monthKey = '${goal.completedAt!.year}-${goal.completedAt!.month.toString().padLeft(2, '0')}';
      monthlyCount[monthKey] = (monthlyCount[monthKey] ?? 0) + 1;
    }
    
    final sortedEntries = monthlyCount.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    
    return sortedEntries.take(6).map((entry) {
      final parts = entry.key.split('-');
      final month = '${parts[1]}월';
      return MonthlyData(month: month, value: entry.value);
    }).toList();
  }

  DeadlineStats _calculateDeadlineStats(List<Goal> goals) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final nextWeek = today.add(const Duration(days: 7));
    
    int overdue = 0;
    int dueToday = 0;
    int dueThisWeek = 0;
    int noDueDate = 0;
    
    for (final goal in goals.where((g) => !g.isCompleted)) {
      if (goal.dueDate == null) {
        noDueDate++;
      } else {
        final dueDate = DateTime(goal.dueDate!.year, goal.dueDate!.month, goal.dueDate!.day);
        if (dueDate.isBefore(today)) {
          overdue++;
        } else if (dueDate.isAtSameMomentAs(today)) {
          dueToday++;
        } else if (dueDate.isBefore(nextWeek)) {
          dueThisWeek++;
        }
      }
    }
    
    return DeadlineStats(
      overdue: overdue,
      dueToday: dueToday,
      dueThisWeek: dueThisWeek,
      noDueDate: noDueDate,
    );
  }

  // 헬퍼 메서드들
  Color _getAchievementColor(double rate) {
    if (rate >= 80) return AppColors.successColor;
    if (rate >= 60) return AppColors.infoColor;
    if (rate >= 40) return AppColors.warningColor;
    return AppColors.errorColor;
  }

  String _getAchievementMessage(double rate) {
    if (rate >= 80) return '훌륭해요! 목표를 잘 달성하고 있습니다! 🎉';
    if (rate >= 60) return '좋은 진행률이에요! 조금 더 힘내세요! 💪';
    if (rate >= 40) return '괜찮은 시작이에요! 더 열심히 해봅시다! 🚀';
    if (rate > 0) return '시작이 반이에요! 꾸준히 도전해보세요! 📈';
    return '새로운 목표를 세우고 시작해보세요! ✨';
  }

  String _getPriorityText(int priority) {
    switch (priority) {
      case 1: return '낮음';
      case 2: return '보통';
      case 3: return '높음';
      default: return '보통';
    }
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1: return AppColors.successColor;
      case 2: return AppColors.warningColor;
      case 3: return AppColors.errorColor;
      default: return AppColors.warningColor;
    }
  }

  IconData _getTypeIcon(GoalType type) {
    switch (type) {
      case GoalType.lifetime: return Icons.star;
      case GoalType.lifetimeSub: return Icons.star_border;
      case GoalType.yearly: return Icons.calendar_today;
      case GoalType.monthly: return Icons.calendar_view_month;
      case GoalType.weekly: return Icons.calendar_view_week;
      case GoalType.daily: return Icons.today;
    }
  }

  String _getTypeText(GoalType type) {
    switch (type) {
      case GoalType.lifetime: return '평생 목표';
      case GoalType.lifetimeSub: return '평생 하위 목표';
      case GoalType.yearly: return '연간 목표';
      case GoalType.monthly: return '월간 목표';
      case GoalType.weekly: return '주간 목표';
      case GoalType.daily: return '일간 목표';
    }
  }

  String _getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }
}

// 데이터 클래스들
class OverallStats {
  final int totalGoals;
  final int completedGoals;
  final int activeGoals;
  final double completionRate;

  OverallStats({
    required this.totalGoals,
    required this.completedGoals,
    required this.activeGoals,
    required this.completionRate,
  });
}

class TypeStats {
  final int total;
  final int completed;
  final int active;

  TypeStats({
    required this.total,
    required this.completed,
    required this.active,
  });
}

class PriorityStats {
  final int total;
  final int completed;

  PriorityStats({
    required this.total,
    required this.completed,
  });
}

class MonthlyData {
  final String month;
  final int value;

  MonthlyData({
    required this.month,
    required this.value,
  });
}

class DeadlineStats {
  final int overdue;
  final int dueToday;
  final int dueThisWeek;
  final int noDueDate;

  DeadlineStats({
    required this.overdue,
    required this.dueToday,
    required this.dueThisWeek,
    required this.noDueDate,
  });
}

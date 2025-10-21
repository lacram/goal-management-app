import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/animations/page_transitions.dart';
import '../../../data/providers/routine_provider.dart';
import '../../../data/models/routine.dart';
import '../../widgets/animations/animated_widgets.dart';
import 'create_routine_screen.dart';

class RoutineDetailScreen extends StatefulWidget {
  final Routine routine;

  const RoutineDetailScreen({super.key, required this.routine});

  @override
  State<RoutineDetailScreen> createState() => _RoutineDetailScreenState();
}

class _RoutineDetailScreenState extends State<RoutineDetailScreen> {
  late Routine _currentRoutine;
  List<RoutineCompletion> _completions = [];
  bool _isLoadingHistory = false;

  @override
  void initState() {
    super.initState();
    _currentRoutine = widget.routine;
    _loadCompletionHistory();
  }

  Future<void> _loadCompletionHistory() async {
    setState(() {
      _isLoadingHistory = true;
    });

    final routineProvider = context.read<RoutineProvider>();
    final completions = await routineProvider.getRoutineCompletions(_currentRoutine.id!);

    setState(() {
      _completions = completions;
      _isLoadingHistory = false;
    });
  }

  Future<void> _toggleComplete() async {
    final routineProvider = context.read<RoutineProvider>();

    if (_currentRoutine.completedToday) {
      await routineProvider.uncompleteRoutine(_currentRoutine.id!);
    } else {
      await routineProvider.completeRoutine(_currentRoutine.id!);
    }

    // 업데이트된 루틴 정보 다시 가져오기
    final updatedRoutine = await routineProvider.apiService.getRoutineById(_currentRoutine.id!);
    setState(() {
      _currentRoutine = updatedRoutine;
    });

    await _loadCompletionHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('루틴 상세'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.of(context).pushWithSlideFromRight(
                CreateRoutineScreen(editRoutine: _currentRoutine),
              );

              if (result == true && context.mounted) {
                final routineProvider = context.read<RoutineProvider>();
                final updatedRoutine = await routineProvider.apiService.getRoutineById(_currentRoutine.id!);
                setState(() {
                  _currentRoutine = updatedRoutine;
                });
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        children: [
          // 루틴 정보 카드
          _buildRoutineInfoCard(),
          const SizedBox(height: AppSizes.paddingLarge),

          // 완료 체크 버튼
          _buildCompleteButton(),
          const SizedBox(height: AppSizes.paddingLarge),

          // 완료 히스토리
          _buildCompletionHistory(),
        ],
      ),
    );
  }

  Widget _buildRoutineInfoCard() {
    return FadeInWidget(
      delay: const Duration(milliseconds: 200),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목
              Text(
                _currentRoutine.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: AppSizes.paddingMedium),

              // 주기
              Row(
                children: [
                  Icon(
                    _currentRoutine.frequency.icon,
                    color: _currentRoutine.frequency.color,
                    size: 24,
                  ),
                  const SizedBox(width: AppSizes.paddingSmall),
                  Text(
                    _currentRoutine.frequency.displayName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: _currentRoutine.frequency.color,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),

              // 설명 (있는 경우)
              if (_currentRoutine.description != null && _currentRoutine.description!.isNotEmpty) ...[
                const SizedBox(height: AppSizes.paddingMedium),
                const Divider(),
                const SizedBox(height: AppSizes.paddingMedium),
                Text(
                  AppStrings.routineDescription,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondaryColor,
                      ),
                ),
                const SizedBox(height: AppSizes.paddingSmall),
                Text(
                  _currentRoutine.description!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],

              // 생성 일시
              const SizedBox(height: AppSizes.paddingMedium),
              const Divider(),
              const SizedBox(height: AppSizes.paddingMedium),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '생성일',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondaryColor,
                        ),
                  ),
                  Text(
                    _currentRoutine.createdAt != null
                        ? DateFormat('yyyy.MM.dd HH:mm').format(_currentRoutine.createdAt!)
                        : '-',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompleteButton() {
    return ScaleInWidget(
      delay: const Duration(milliseconds: 300),
      child: SizedBox(
        width: double.infinity,
        height: AppSizes.buttonHeight,
        child: ElevatedButton(
          onPressed: _toggleComplete,
          style: ElevatedButton.styleFrom(
            backgroundColor: _currentRoutine.completedToday
                ? AppColors.successColor
                : AppColors.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _currentRoutine.completedToday
                    ? Icons.check_circle
                    : Icons.check_circle_outline,
                size: 24,
              ),
              const SizedBox(width: AppSizes.paddingSmall),
              Text(
                _currentRoutine.completedToday ? '오늘 완료함' : '완료 체크',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionHistory() {
    return FadeInWidget(
      delay: const Duration(milliseconds: 400),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.routineHistory,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppSizes.paddingMedium),

          if (_isLoadingHistory)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSizes.paddingLarge),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_completions.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.paddingLarge),
                child: Center(
                  child: Text(
                    '아직 완료 기록이 없습니다',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondaryColor,
                        ),
                  ),
                ),
              ),
            )
          else
            ..._completions.map((completion) => _buildCompletionItem(completion)),
        ],
      ),
    );
  }

  Widget _buildCompletionItem(RoutineCompletion completion) {
    final dateFormat = DateFormat('yyyy.MM.dd (E) HH:mm', 'ko');

    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingSmall),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _currentRoutine.frequency.color.withOpacity(0.2),
          child: Icon(
            Icons.check,
            color: _currentRoutine.frequency.color,
          ),
        ),
        title: Text(
          dateFormat.format(completion.completedAt),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: completion.note != null && completion.note!.isNotEmpty
            ? Text(completion.note!)
            : null,
      ),
    );
  }
}

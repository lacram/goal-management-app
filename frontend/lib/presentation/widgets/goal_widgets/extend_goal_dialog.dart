import 'package:flutter/material.dart';
import '../../../data/models/goal.dart';
import '../../../core/services/api_service.dart';
import 'package:intl/intl.dart';

/// 목표 기간 연장 다이얼로그
class ExtendGoalDialog extends StatefulWidget {
  final Goal goal;
  final VoidCallback onExtended;

  const ExtendGoalDialog({
    super.key,
    required this.goal,
    required this.onExtended,
  });

  @override
  State<ExtendGoalDialog> createState() => _ExtendGoalDialogState();
}

class _ExtendGoalDialogState extends State<ExtendGoalDialog> {
  final ApiService _apiService = ApiService();
  int _selectedDays = 7; // 기본 7일 연장
  bool _isLoading = false;
  final List<int> _daysOptions = [1, 3, 7, 14, 30];

  Future<void> _extendGoal() async {
    if (widget.goal.id == null) return;

    setState(() => _isLoading = true);

    try {
      await _apiService.extendGoalDueDate(widget.goal.id!, _selectedDays);

      if (mounted) {
        Navigator.of(context).pop();
        widget.onExtended();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.goal.title}의 기간이 $_selectedDays일 연장되었습니다'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('기간 연장 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentDueDate = widget.goal.dueDate;
    final newDueDate = currentDueDate?.add(Duration(days: _selectedDays));
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.calendar_month, color: Color(0xFF3B82F6)),
          SizedBox(width: 8),
          Text('목표 기간 연장'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 목표 제목
          Text(
            widget.goal.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          // 현재 마감일
          if (currentDueDate != null) ...[
            _buildDateInfo(
              label: '현재 마감일',
              date: dateFormat.format(currentDueDate),
              color: const Color(0xFF6B7280),
            ),
            const SizedBox(height: 12),
          ],

          // 연장 기간 선택
          const Text(
            '연장 기간 선택',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),

          // 연장 일수 버튼
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _daysOptions.map((days) {
              final isSelected = _selectedDays == days;
              return ChoiceChip(
                label: Text('$days일'),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _selectedDays = days);
                  }
                },
                selectedColor: const Color(0xFF3B82F6),
                backgroundColor: Colors.grey[200],
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // 새 마감일
          if (newDueDate != null) ...[
            _buildDateInfo(
              label: '새 마감일',
              date: dateFormat.format(newDueDate),
              color: const Color(0xFF10B981),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _extendGoal,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3B82F6),
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('연장하기'),
        ),
      ],
    );
  }

  Widget _buildDateInfo({
    required String label,
    required String date,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today, size: 16, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                date,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

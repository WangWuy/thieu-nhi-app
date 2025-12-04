import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thieu_nhi_app/core/models/student_model.dart';
import 'package:thieu_nhi_app/core/services/student_service.dart';
import 'package:thieu_nhi_app/features/students/bloc/students_bloc.dart';
import 'package:thieu_nhi_app/features/students/bloc/students_event.dart';
import 'package:thieu_nhi_app/theme/app_colors.dart';

class StudentDetailedScoresCard extends StatefulWidget {
  final StudentModel student;

  const StudentDetailedScoresCard({super.key, required this.student});

  @override
  State<StudentDetailedScoresCard> createState() =>
      _StudentDetailedScoresCardState();
}

class _StudentDetailedScoresCardState extends State<StudentDetailedScoresCard> {
  late StudentModel _student;
  late final StudentService _studentService;

  @override
  void initState() {
    super.initState();
    _student = widget.student;
    _studentService = StudentService();
  }

  @override
  void didUpdateWidget(covariant StudentDetailedScoresCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.student != widget.student) {
      _student = widget.student;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final mutedColor = theme.colorScheme.onSurface.withOpacity(0.7);
    final shadowColor =
        isDark ? Colors.black.withOpacity(0.35) : Colors.black.withOpacity(0.1);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Chi tiết điểm số',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: _openEditScoresSheet,
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Chỉnh sửa'),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  foregroundColor:
                      theme.colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Study scores section
          _buildSectionHeader(context, 'Điểm học tập', Icons.school),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildScoreDetail(context, '45\' HK1',
                    _student.study45Hk1?.toStringAsFixed(1) ?? '0.0'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildScoreDetail(context,
                    'Thi HK1', _student.examHk1?.toStringAsFixed(1) ?? '0.0'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildScoreDetail(context, '45\' HK2',
                    _student.study45Hk2?.toStringAsFixed(1) ?? '0.0'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildScoreDetail(context,
                    'Thi HK2', _student.examHk2?.toStringAsFixed(1) ?? '0.0'),
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),

          // Attendance details section
          _buildSectionHeader(context, 'Điểm danh chi tiết', Icons.event_available),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildAttendanceDetail(
                  context,
                  'Thứ 5',
                  _student.thursdayAttendanceCount?.toString() ?? '0',
                  'buổi',
                  AppColors.secondary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildAttendanceDetail(
                  context,
                  'Chủ nhật',
                  _student.sundayAttendanceCount?.toString() ?? '0',
                  'buổi',
                  AppColors.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          
          // Calculation explanation
          _buildCalculationInfo(context),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildScoreDetail(BuildContext context, String label, String score) {
    final scoreValue = double.tryParse(score) ?? 0.0;
    final color = _getScoreColor(scoreValue);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.2 : 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: 10,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            score,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceDetail(
      BuildContext context, String title, String count, String unit, Color color) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.2 : 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                count,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalculationInfo(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final mutedColor = theme.colorScheme.onSurface.withOpacity(0.7);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(isDark ? 0.6 : 0.9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: mutedColor),
              const SizedBox(width: 8),
              Text(
                'Cách tính điểm',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: mutedColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '• Học tập: (45\'HK1 + 45\'HK2 + ThiHK1×2 + ThiHK2×2) ÷ 6',
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 12,
              color: mutedColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '• Điểm danh: (Thứ5×0.4 + CN×0.6) × (10÷tổng tuần)',
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 12,
              color: mutedColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '• Tổng kết: Học tập×0.6 + Điểm danh×0.4',
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 12,
              color: mutedColor,
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 8.5) return AppColors.success;
    if (score >= 7.0) return AppColors.primary;
    if (score >= 5.5) return AppColors.warning;
    return AppColors.error;
  }

  void _openEditScoresSheet() {
    final study45Hk1Ctrl =
        TextEditingController(text: _student.study45Hk1?.toString() ?? '0');
    final examHk1Ctrl =
        TextEditingController(text: _student.examHk1?.toString() ?? '0');
    final study45Hk2Ctrl =
        TextEditingController(text: _student.study45Hk2?.toString() ?? '0');
    final examHk2Ctrl =
        TextEditingController(text: _student.examHk2?.toString() ?? '0');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (bottomSheetContext) {
        String? errorText;
        bool isSaving = false;

        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> handleSave() async {
              final values = {
                'study45Hk1': _parseScore(study45Hk1Ctrl.text),
                'examHk1': _parseScore(examHk1Ctrl.text),
                'study45Hk2': _parseScore(study45Hk2Ctrl.text),
                'examHk2': _parseScore(examHk2Ctrl.text),
              };

              final invalid = values.entries
                  .where((e) => e.value < 0 || e.value > 10 || e.value.isNaN)
                  .isNotEmpty;

              if (invalid) {
                setModalState(() {
                  errorText = 'Điểm phải trong khoảng 0 - 10';
                });
                return;
              }

              setModalState(() {
                isSaving = true;
                errorText = null;
              });
              try {
                final updated = await _studentService.updateStudent(
                  _student.id,
                  values,
                );

                if (updated != null) {
                  setState(() => _student = updated);
                  if (mounted) {
                    context.read<StudentsBloc>().add(
                          LoadStudentDetail(_student.id, forceRefresh: true),
                        );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã cập nhật điểm số'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                  Navigator.of(bottomSheetContext).pop();
                } else {
                  setModalState(() {
                    errorText = 'Không thể cập nhật điểm số, thử lại sau.';
                  });
                }
              } catch (e) {
                setModalState(() {
                  errorText = 'Lỗi: $e';
                });
              } finally {
                setModalState(() {
                  isSaving = false;
                });
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Chỉnh sửa điểm',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildScoreField('45\' HK1', study45Hk1Ctrl),
                      _buildScoreField('Thi HK1', examHk1Ctrl),
                      _buildScoreField('45\' HK2', study45Hk2Ctrl),
                      _buildScoreField('Thi HK2', examHk2Ctrl),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (errorText != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: AppColors.error.withOpacity(0.3)),
                      ),
                      child: Text(
                        errorText!,
                        style: const TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isSaving
                              ? null
                              : () => Navigator.of(bottomSheetContext).pop(),
                          child: const Text('Hủy'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isSaving ? null : handleSave,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: isSaving
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Text('Lưu'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  double _parseScore(String text) {
    final normalized = text.replaceAll(',', '.');
    return double.tryParse(normalized) ?? 0.0;
  }

  Widget _buildScoreField(String label, TextEditingController controller) {
    return SizedBox(
      width: 150,
      child: TextField(
        controller: controller,
        keyboardType:
            const TextInputType.numberWithOptions(decimal: true, signed: false),
        decoration: InputDecoration(
          labelText: label,
          hintText: '0 - 10',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }
}

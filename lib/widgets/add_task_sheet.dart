import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../models/task_type.dart';
import '../providers/task_provider.dart';
import '../utils/date_helpers.dart';

class AddTaskSheet extends StatefulWidget {
  const AddTaskSheet({super.key, this.initialDate, this.taskToEdit});

  final DateTime? initialDate;
  final Task? taskToEdit;

  bool get isEditing => taskToEdit != null;

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();

  late DateTime _selectedDate;
  TimeOfDay? _selectedTime;
  TaskType _selectedType = TaskType.normal;
  bool _weeklyAnyDay = true;
  Set<int> _weeklyDays = <int>{};
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    final editingTask = widget.taskToEdit;
    if (editingTask != null) {
      _titleController.text = editingTask.title;
      _selectedDate = dateOnly(editingTask.scheduledDate);
      _selectedType = editingTask.type;
      _weeklyAnyDay = editingTask.weeklyAnyDay;
      _weeklyDays = Set<int>.from(editingTask.weeklyDays);
      if (editingTask.timeInMinutes != null) {
        _selectedTime = TimeOfDay(
          hour: editingTask.timeInMinutes! ~/ 60,
          minute: editingTask.timeInMinutes! % 60,
        );
      }
    } else {
      _selectedDate = dateOnly(widget.initialDate ?? tomorrowDate());
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('ar'),
    );

    if (pickedDate == null) {
      return;
    }

    setState(() {
      _selectedDate = dateOnly(pickedDate);
    });
  }

  Future<void> _pickTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 21, minute: 0),
    );

    if (pickedTime == null) {
      return;
    }

    setState(() {
      _selectedTime = pickedTime;
    });
  }

  Future<void> _submit() async {
    if (_isSaving) {
      return;
    }

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    if (_selectedType == TaskType.weekly &&
        !_weeklyAnyDay &&
        _weeklyDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('اختر يومًا واحدًا على الأقل للمهمة الأسبوعية'),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final provider = context.read<TaskProvider>();
    final timeInMinutes = _selectedTime == null
        ? null
        : minutesFromTimeOfDay(_selectedTime!);

    if (widget.isEditing) {
      await provider.updateTask(
        taskId: widget.taskToEdit!.id,
        title: _titleController.text,
        date: _selectedDate,
        type: _selectedType,
        timeInMinutes: timeInMinutes,
        weeklyAnyDay: _weeklyAnyDay,
        weeklyDays: _weeklyDays,
      );
    } else {
      await provider.addTask(
        title: _titleController.text,
        date: _selectedDate,
        type: _selectedType,
        timeInMinutes: timeInMinutes,
        weeklyAnyDay: _weeklyAnyDay,
        weeklyDays: _weeklyDays,
      );
    }

    if (!mounted) {
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final dateLabel = DateFormat('EEEE، d MMMM', 'ar').format(_selectedDate);
    final timeLabel = _selectedTime == null
        ? 'بدون وقت'
        : MaterialLocalizations.of(context).formatTimeOfDay(_selectedTime!);

    return Padding(
      padding: EdgeInsets.only(
        left: 18,
        right: 18,
        top: 8,
        bottom: bottomInset + 18,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                widget.isEditing ? 'تعديل المهمة' : 'إضافة مهمة جديدة',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.isEditing
                    ? 'حدّث تفاصيل المهمة بسرعة.'
                    : 'خطوة صغيرة الآن تصنع يومًا أفضل غدًا.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'اسم المهمة',
                  hintText: 'مثال: تجهيز حقيبة العمل',
                ),
                validator: (String? value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'اسم المهمة مطلوب';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.calendar_month_rounded),
                      label: Text(dateLabel),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickTime,
                      icon: const Icon(Icons.schedule_rounded),
                      label: Text(timeLabel),
                    ),
                  ),
                  if (_selectedTime != null) ...<Widget>[
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _selectedTime = null;
                        });
                      },
                      icon: const Icon(Icons.close_rounded),
                      tooltip: 'حذف الوقت',
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'نوع المهمة',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              SegmentedButton<TaskType>(
                showSelectedIcon: false,
                segments: const <ButtonSegment<TaskType>>[
                  ButtonSegment<TaskType>(
                    value: TaskType.normal,
                    icon: Icon(Icons.task_outlined),
                    label: Text('عادية'),
                  ),
                  ButtonSegment<TaskType>(
                    value: TaskType.daily,
                    icon: Icon(Icons.repeat_rounded),
                    label: Text('يومية'),
                  ),
                  ButtonSegment<TaskType>(
                    value: TaskType.weekly,
                    icon: Icon(Icons.view_week_rounded),
                    label: Text('أسبوعية'),
                  ),
                ],
                selected: <TaskType>{_selectedType},
                onSelectionChanged: (Set<TaskType> selectedValues) {
                  setState(() {
                    _selectedType = selectedValues.first;
                  });
                },
              ),
              if (_selectedType == TaskType.weekly) ...<Widget>[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: Theme.of(context).colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.35),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _weeklyAnyDay,
                        onChanged: (bool? value) {
                          if (value == null) {
                            return;
                          }
                          setState(() {
                            _weeklyAnyDay = value;
                            if (value) {
                              _weeklyDays = <int>{};
                            }
                          });
                        },
                        title: const Text('مرة واحدة في الأسبوع (أي يوم)'),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      if (!_weeklyAnyDay) ...<Widget>[
                        const SizedBox(height: 6),
                        const Text('اختر الأيام المتاحة لهذه المهمة:'),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: weekDayDisplayOrder.map((int day) {
                            final selected = _weeklyDays.contains(day);
                            return FilterChip(
                              selected: selected,
                              label: Text(arabicWeekDayNames[day]!),
                              onSelected: (bool value) {
                                setState(() {
                                  if (value) {
                                    _weeklyDays.add(day);
                                  } else {
                                    _weeklyDays.remove(day);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _submit,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_rounded),
                  label: Text(
                    _isSaving
                        ? 'جارٍ الحفظ...'
                        : widget.isEditing
                        ? 'حفظ التعديلات'
                        : 'حفظ المهمة',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

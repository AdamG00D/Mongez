import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../models/task_type.dart';
import '../providers/task_provider.dart';
import '../utils/date_helpers.dart';
import 'reminder_permissions.dart';

class AddTaskSheet extends StatefulWidget {
  const AddTaskSheet({super.key, this.initialDate, this.taskToEdit});

  final DateTime? initialDate;
  final Task? taskToEdit;

  bool get isEditing => taskToEdit != null;

  static Future<void> show(
    BuildContext context, {
    Task? task,
    DateTime? initialDate,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (BuildContext context) =>
          AddTaskSheet(taskToEdit: task, initialDate: initialDate),
    );
  }

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  late DateTime _selectedDate;
  TimeOfDay? _selectedTime;
  TaskType _selectedType = TaskType.normal;
  TaskPriority _priority = TaskPriority.none;
  bool _weeklyAnyDay = true;
  Set<int> _weeklyDays = <int>{};
  int _weekStartDay = WeekSettings.defaultStartDay;
  WeeklyReminderMode _weeklyReminder = WeeklyReminderMode.everyDayUntilDone;
  bool _showNote = false;
  bool _isSaving = false;
  bool _permissionsChecked = false;

  @override
  void initState() {
    super.initState();

    final editingTask = widget.taskToEdit;
    if (editingTask != null) {
      _titleController.text = editingTask.title;
      _noteController.text = editingTask.note ?? '';
      _showNote = editingTask.note != null;
      _selectedDate = dateOnly(editingTask.scheduledDate);
      _selectedType = editingTask.type;
      _priority = editingTask.priority;
      _weeklyAnyDay = editingTask.weeklyAnyDay;
      _weeklyDays = Set<int>.from(editingTask.weeklyDays);
      _weekStartDay = editingTask.effectiveWeekStart;
      _weeklyReminder = editingTask.weeklyReminder;
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
    _noteController.dispose();
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
    if (pickedDate != null) {
      setState(() => _selectedDate = dateOnly(pickedDate));
    }
  }

  Future<void> _pickTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 21, minute: 0),
    );
    if (pickedTime != null) {
      setState(() => _selectedTime = pickedTime);
      await _checkReminderPermissions();
    }
  }

  Future<void> _checkReminderPermissions() async {
    if (_permissionsChecked || !mounted) {
      return;
    }
    _permissionsChecked = true;
    await ensureReminderPermissions(context);
  }

  Future<void> _submit() async {
    if (_isSaving) {
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) {
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

    if (_selectedTime != null) {
      // Editing a task that already had a time: still verify permissions.
      await _checkReminderPermissions();
      if (!mounted) {
        return;
      }
    }

    setState(() => _isSaving = true);

    final provider = context.read<TaskProvider>();
    final timeInMinutes = _selectedTime == null
        ? null
        : minutesFromTimeOfDay(_selectedTime!);
    final weekStart = _weekStartDay == WeekSettings.defaultStartDay
        ? null
        : _weekStartDay;

    if (widget.isEditing) {
      await provider.updateTask(
        taskId: widget.taskToEdit!.id,
        title: _titleController.text,
        date: _selectedDate,
        type: _selectedType,
        timeInMinutes: timeInMinutes,
        weeklyAnyDay: _weeklyAnyDay,
        weeklyDays: _weeklyDays,
        weekStartDay: weekStart,
        weeklyReminder: _weeklyReminder,
        priority: _priority,
        note: _noteController.text,
      );
    } else {
      await provider.addTask(
        title: _titleController.text,
        date: _selectedDate,
        type: _selectedType,
        timeInMinutes: timeInMinutes,
        weeklyAnyDay: _weeklyAnyDay,
        weeklyDays: _weeklyDays,
        weekStartDay: weekStart,
        weeklyReminder: _weeklyReminder,
        priority: _priority,
        note: _noteController.text,
      );
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final today = todayDate();
    final tomorrow = tomorrowDate();
    final isCustomDate =
        !isSameDate(_selectedDate, today) &&
        !isSameDate(_selectedDate, tomorrow);
    final dateLabel = DateFormat('EEEE d MMMM', 'ar').format(_selectedDate);

    Widget label(String text) => Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 8),
      child: Text(
        text,
        style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
      ),
    );

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                widget.isEditing ? 'تعديل المهمة' : 'مهمة جديدة',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _titleController,
                autofocus: !widget.isEditing,
                textInputAction: TextInputAction.done,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
                decoration: const InputDecoration(
                  hintText: 'ماذا تريد أن تنجز؟',
                  prefixIcon: Icon(Icons.edit_note_rounded),
                ),
                validator: (String? value) =>
                    (value == null || value.trim().isEmpty)
                    ? 'اكتب اسم المهمة'
                    : null,
                onFieldSubmitted: (_) => _submit(),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                child: _showNote
                    ? Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: TextField(
                          controller: _noteController,
                          minLines: 2,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            hintText: 'ملاحظات أو تفاصيل (اختياري)',
                            prefixIcon: Icon(Icons.notes_rounded),
                          ),
                        ),
                      )
                    : Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: TextButton.icon(
                          onPressed: () => setState(() => _showNote = true),
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: const Text('إضافة ملاحظة'),
                        ),
                      ),
              ),
              label('النوع'),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<TaskType>(
                  showSelectedIcon: false,
                  segments: TaskType.values
                      .map(
                        (TaskType type) => ButtonSegment<TaskType>(
                          value: type,
                          icon: Icon(type.icon, size: 18),
                          label: Text(type.label),
                        ),
                      )
                      .toList(),
                  selected: <TaskType>{_selectedType},
                  onSelectionChanged: (Set<TaskType> values) =>
                      setState(() => _selectedType = values.first),
                ),
              ),
              label(_selectedType == TaskType.normal ? 'اليوم' : 'تبدأ من'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  ChoiceChip(
                    label: const Text('اليوم'),
                    selected: isSameDate(_selectedDate, today),
                    onSelected: (_) => setState(() => _selectedDate = today),
                  ),
                  ChoiceChip(
                    label: const Text('غدًا'),
                    selected: isSameDate(_selectedDate, tomorrow),
                    onSelected: (_) => setState(() => _selectedDate = tomorrow),
                  ),
                  ChoiceChip(
                    avatar: const Icon(Icons.calendar_month_rounded, size: 18),
                    label: Text(isCustomDate ? dateLabel : 'تاريخ آخر'),
                    selected: isCustomDate,
                    onSelected: (_) => _pickDate(),
                  ),
                ],
              ),
              label('الوقت والتذكير'),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickTime,
                      icon: Icon(
                        _selectedTime == null
                            ? Icons.alarm_add_rounded
                            : Icons.alarm_on_rounded,
                      ),
                      label: Text(
                        _selectedTime == null
                            ? 'بدون وقت (بدون تذكير)'
                            : 'تذكير ${MaterialLocalizations.of(context).formatTimeOfDay(_selectedTime!)}',
                      ),
                    ),
                  ),
                  if (_selectedTime != null) ...<Widget>[
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      onPressed: () => setState(() => _selectedTime = null),
                      icon: const Icon(Icons.close_rounded),
                      tooltip: 'حذف الوقت',
                    ),
                  ],
                ],
              ),
              if (_selectedType == TaskType.weekly) _weeklyOptions(context),
              label('الأولوية'),
              Wrap(
                spacing: 8,
                children: TaskPriority.values.map((TaskPriority p) {
                  return ChoiceChip(
                    avatar: Icon(
                      Icons.circle,
                      size: 12,
                      color: p == TaskPriority.none ? scheme.outline : p.color,
                    ),
                    label: Text(p.label),
                    selected: _priority == p,
                    onSelected: (_) => setState(() => _priority = p),
                  );
                }).toList(),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _submit,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_rounded),
                  label: Text(
                    widget.isEditing ? 'حفظ التعديلات' : 'إضافة المهمة',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _weeklyOptions(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: scheme.primary.withValues(alpha: 0.06),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.15)),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'يبدأ الأسبوع يوم',
              style: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: weekDaysOrdered(DateTime.saturday).map((int day) {
                  return Padding(
                    padding: const EdgeInsetsDirectional.only(end: 6),
                    child: ChoiceChip(
                      label: Text(arabicWeekDayNames[day]!),
                      selected: _weekStartDay == day,
                      onSelected: (_) => setState(() => _weekStartDay = day),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _weeklyAnyDay,
              onChanged: (bool value) => setState(() {
                _weeklyAnyDay = value;
                if (value) {
                  _weeklyDays = <int>{};
                }
              }),
              title: const Text('مرة واحدة في أي يوم من الأسبوع'),
            ),
            if (!_weeklyAnyDay) ...<Widget>[
              const Text('الأيام المتاحة:'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: weekDaysOrdered(_weekStartDay).map((int day) {
                  return FilterChip(
                    showCheckmark: false,
                    selected: _weeklyDays.contains(day),
                    label: Text(arabicWeekDayNames[day]!),
                    onSelected: (bool value) => setState(() {
                      if (value) {
                        _weeklyDays.add(day);
                      } else {
                        _weeklyDays.remove(day);
                      }
                    }),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              'إذا لم تُنجز، ذكّرني',
              style: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: WeeklyReminderMode.values.map((
                WeeklyReminderMode mode,
              ) {
                return ChoiceChip(
                  label: Text(mode.label),
                  selected: _weeklyReminder == mode,
                  onSelected: (_) => setState(() => _weeklyReminder = mode),
                );
              }).toList(),
            ),
            if (_selectedTime == null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'حدّد وقتًا للمهمة لتفعيل التذكيرات.',
                  style: textTheme.bodySmall?.copyWith(color: scheme.error),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

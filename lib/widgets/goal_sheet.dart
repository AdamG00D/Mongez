import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/goal.dart';
import '../providers/goals_provider.dart';

class GoalSheet extends StatefulWidget {
  const GoalSheet({this.goal, this.suggestion, super.key});

  final Goal? goal;
  final GoalSuggestion? suggestion;

  static Future<void> show(
    BuildContext context, {
    Goal? goal,
    GoalSuggestion? suggestion,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (_) => GoalSheet(goal: goal, suggestion: suggestion),
    );
  }

  @override
  State<GoalSheet> createState() => _GoalSheetState();
}

class GoalSuggestion {
  const GoalSuggestion(this.title, this.icon, {this.target, this.unit});

  final String title;
  final String icon;
  final int? target;
  final String? unit;
}

const List<GoalSuggestion> goalSuggestions = <GoalSuggestion>[
  GoalSuggestion('قراءة 12 كتابًا', 'book', target: 12, unit: 'كتاب'),
  GoalSuggestion(
    'ممارسة الرياضة بانتظام',
    'fitness',
    target: 150,
    unit: 'تمرين',
  ),
  GoalSuggestion('ادخار مبلغ للطوارئ', 'money'),
  GoalSuggestion('تعلّم لغة جديدة', 'language'),
  GoalSuggestion('إنهاء كورس احترافي', 'study'),
  GoalSuggestion('حفظ جزء من القرآن', 'faith'),
  GoalSuggestion('السفر إلى مكان جديد', 'travel'),
  GoalSuggestion('بناء مشروع جانبي', 'code'),
];

class _GoalSheetState extends State<GoalSheet> {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _why = TextEditingController();
  final TextEditingController _target = TextEditingController();
  final TextEditingController _unit = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _icon = 'star';
  bool _numeric = false;

  @override
  void initState() {
    super.initState();
    final goal = widget.goal;
    final suggestion = widget.suggestion;
    if (goal != null) {
      _title.text = goal.title;
      _why.text = goal.why ?? '';
      _icon = goal.iconKey;
      _numeric = goal.hasTarget;
      _target.text = goal.target?.toString() ?? '';
      _unit.text = goal.unit ?? '';
    } else if (suggestion != null) {
      _title.text = suggestion.title;
      _icon = suggestion.icon;
      _numeric = suggestion.target != null;
      _target.text = suggestion.target?.toString() ?? '';
      _unit.text = suggestion.unit ?? '';
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _why.dispose();
    _target.dispose();
    _unit.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final provider = context.read<GoalsProvider>();
    final target = _numeric ? int.tryParse(_target.text.trim()) : null;
    if (widget.goal == null) {
      await provider.addGoal(
        title: _title.text,
        why: _why.text,
        target: target,
        unit: _numeric ? _unit.text : null,
        iconKey: _icon,
      );
    } else {
      await provider.updateGoal(
        widget.goal!.id,
        title: _title.text,
        why: _why.text,
        target: target,
        unit: _numeric ? _unit.text : null,
        iconKey: _icon,
      );
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final year = context.read<GoalsProvider>().year;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                widget.goal == null ? 'هدف جديد لعام $year' : 'تعديل الهدف',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _title,
                autofocus: widget.goal == null && widget.suggestion == null,
                style: const TextStyle(fontWeight: FontWeight.w700),
                decoration: const InputDecoration(
                  hintText: 'ما الذي تريد تحقيقه هذا العام؟',
                  prefixIcon: Icon(Icons.flag_rounded),
                ),
                validator: (String? v) =>
                    (v == null || v.trim().isEmpty) ? 'اكتب الهدف' : null,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _why,
                minLines: 2,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'لماذا هذا الهدف مهم لك؟ (سنذكّرك به حين تفتر)',
                  prefixIcon: Icon(Icons.favorite_rounded),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'الأيقونة',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: goalIcons.entries.map((
                  MapEntry<String, IconData> entry,
                ) {
                  final selected = entry.key == _icon;
                  return InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => setState(() => _icon = entry.key),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: selected
                            ? scheme.primary
                            : scheme.primary.withValues(alpha: 0.08),
                      ),
                      child: Icon(
                        entry.value,
                        color: selected ? scheme.onPrimary : scheme.primary,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _numeric,
                onChanged: (bool v) => setState(() => _numeric = v),
                title: const Text('هدف رقمي قابل للقياس'),
                subtitle: const Text('مثال: 12 كتابًا، 100 تمرين'),
              ),
              if (_numeric)
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextFormField(
                        controller: _target,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: 'العدد'),
                        validator: (String? v) {
                          if (!_numeric) {
                            return null;
                          }
                          final n = int.tryParse(v?.trim() ?? '');
                          return (n == null || n <= 0) ? 'رقم صحيح' : null;
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _unit,
                        decoration: const InputDecoration(
                          hintText: 'الوحدة (كتاب، كم...)',
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.check_rounded),
                  label: Text(widget.goal == null ? 'إضافة الهدف' : 'حفظ'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

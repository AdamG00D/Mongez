import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/goal.dart';
import '../providers/goals_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/motivation.dart';
import '../widgets/common.dart';
import '../widgets/goal_sheet.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  Future<void> _celebrateIf(BuildContext context, bool completed) async {
    if (!completed || !context.mounted) {
      return;
    }
    HapticFeedback.mediumImpact();
    if (context.read<SettingsProvider>().settings.celebrate) {
      showCelebration(context);
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('حققت هدفًا من أهداف السنة! 🏆 فخورون بك'),
        ),
      );
  }

  Future<void> _confirmDelete(BuildContext context, Goal goal) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('حذف الهدف؟'),
        content: Text('سيتم حذف "${goal.title}".'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if ((ok ?? false) && context.mounted) {
      await context.read<GoalsProvider>().deleteGoal(goal.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GoalsProvider>();
    final goals = provider.goalsForYear;
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final bottomPad = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add-goal',
        onPressed: () => GoalSheet.show(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'هدف جديد',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 100 + bottomPad),
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'أهداف السنة',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: provider.year,
                    borderRadius: BorderRadius.circular(16),
                    items: provider.availableYears
                        .map(
                          (int y) => DropdownMenuItem<int>(
                            value: y,
                            child: Text(
                              '$y',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (int? y) {
                      if (y != null) {
                        provider.setYear(y);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _YearHero(provider: provider, goals: goals),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(Icons.format_quote_rounded, color: scheme.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        quoteOfTheDay(),
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (goals.isEmpty) ...<Widget>[
              const EmptyState(
                icon: Icons.emoji_events_rounded,
                title: 'ما أهم ما تريد تحقيقه هذا العام؟',
                message:
                    'اكتب 3 إلى 5 أهداف فقط، وأضف سببك لكل هدف. سنذكّرك بها كل أسبوع.',
              ),
              Text(
                'اقتراحات سريعة',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: goalSuggestions
                    .map(
                      (GoalSuggestion s) => ActionChip(
                        avatar: Icon(goalIcons[s.icon], size: 18),
                        label: Text(s.title),
                        onPressed: () => GoalSheet.show(context, suggestion: s),
                      ),
                    )
                    .toList(),
              ),
            ] else ...<Widget>[
              const SectionTitle('أهدافك'),
              ...goals.map(
                (Goal goal) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _GoalCard(
                    goal: goal,
                    onTap: () => GoalSheet.show(context, goal: goal),
                    onLongPress: () => _confirmDelete(context, goal),
                    onToggle: () async {
                      final completed = await provider.toggleCompleted(goal.id);
                      if (context.mounted) {
                        await _celebrateIf(context, completed);
                      }
                    },
                    onStep: (int delta) async {
                      final completed = await provider.changeProgress(
                        goal.id,
                        delta,
                      );
                      if (context.mounted) {
                        await _celebrateIf(context, completed);
                      }
                    },
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _YearHero extends StatelessWidget {
  const _YearHero({required this.provider, required this.goals});

  final GoalsProvider provider;
  final List<Goal> goals;

  @override
  Widget build(BuildContext context) {
    final done = goals.where((Goal g) => g.isCompleted).length;
    final ratio = provider.yearGoalsRatio;
    final elapsed = provider.yearElapsedRatio;
    final textTheme = Theme.of(context).textTheme;

    return GradientCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              ProgressRing(
                value: ratio,
                size: 86,
                color: Colors.white,
                trackColor: Colors.white.withValues(alpha: 0.22),
                child: Text(
                  '${(ratio * 100).round()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      goals.isEmpty
                          ? 'ابدأ عامك بوضوح'
                          : 'حققت $done من ${goals.length}',
                      style: textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      goals.isEmpty
                          ? 'الأهداف المكتوبة أقرب للتحقق.'
                          : yearProgressMessage(elapsed, ratio),
                      style: textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Flexible(
                child: Text(
                  'مضى ${(elapsed * 100).round()}% من ${provider.year}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'متبقٍ ${provider.daysLeftInYear} يومًا',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: elapsed,
              minHeight: 7,
              color: Colors.white,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.goal,
    required this.onTap,
    required this.onLongPress,
    required this.onToggle,
    required this.onStep,
  });

  final Goal goal;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onToggle;
  final ValueChanged<int> onStep;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final color = goal.isCompleted ? const Color(0xFF10B981) : scheme.primary;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.13),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(goal.icon, color: color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      goal.title,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        decoration: goal.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ),
                  if (!goal.hasTarget || goal.isCompleted)
                    IconButton(
                      tooltip: goal.isCompleted ? 'إلغاء' : 'تحقق',
                      onPressed: onToggle,
                      icon: Icon(
                        goal.isCompleted
                            ? Icons.emoji_events_rounded
                            : Icons.radio_button_unchecked_rounded,
                        color: goal.isCompleted
                            ? const Color(0xFFF59E0B)
                            : scheme.outline,
                        size: 30,
                      ),
                    ),
                ],
              ),
              if (goal.why != null) ...<Widget>[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '💡 ${goal.why!}',
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
              if (goal.hasTarget) ...<Widget>[
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '${goal.progress} / ${goal.target} ${goal.unit ?? ''}',
                            style: textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: TweenAnimationBuilder<double>(
                              tween: Tween<double>(end: goal.ratio),
                              duration: const Duration(milliseconds: 400),
                              builder: (_, double v, _) =>
                                  LinearProgressIndicator(
                                    value: v,
                                    minHeight: 8,
                                    color: color,
                                    backgroundColor: color.withValues(
                                      alpha: 0.15,
                                    ),
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.outlined(
                      tooltip: 'إنقاص',
                      onPressed: goal.progress > 0 ? () => onStep(-1) : null,
                      icon: const Icon(Icons.remove_rounded),
                    ),
                    const SizedBox(width: 4),
                    IconButton.filled(
                      tooltip: 'زيادة',
                      onPressed: goal.isCompleted ? null : () => onStep(1),
                      icon: const Icon(Icons.add_rounded),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

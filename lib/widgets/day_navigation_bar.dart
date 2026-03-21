import 'package:flutter/material.dart';

class DayNavigationBar extends StatelessWidget {
  const DayNavigationBar({
    required this.onPrevious,
    required this.onNext,
    required this.onTomorrow,
    required this.onPickDate,
    required this.isTomorrowSelected,
    super.key,
  });

  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onTomorrow;
  final VoidCallback onPickDate;
  final bool isTomorrowSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: <Widget>[
          OutlinedButton.icon(
            onPressed: onPrevious,
            icon: const Icon(Icons.navigate_before_rounded),
            label: const Text('اليوم السابق'),
          ),
          OutlinedButton.icon(
            onPressed: onPickDate,
            icon: const Icon(Icons.calendar_month_rounded),
            label: const Text('اختيار تاريخ'),
          ),
          OutlinedButton.icon(
            onPressed: onNext,
            icon: const Icon(Icons.navigate_next_rounded),
            label: const Text('اليوم التالي'),
          ),
          FilledButton.icon(
            onPressed: isTomorrowSelected ? null : onTomorrow,
            icon: const Icon(Icons.bedtime_rounded),
            label: const Text('الرجوع إلى غدًا'),
          ),
        ],
      ),
    );
  }
}

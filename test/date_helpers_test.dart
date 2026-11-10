import 'package:flutter_test/flutter_test.dart';
import 'package:mongez/utils/date_helpers.dart';

void main() {
  test('tomorrowDate returns date only without time', () {
    final tomorrow = tomorrowDate();

    expect(tomorrow.hour, 0);
    expect(tomorrow.minute, 0);
    expect(tomorrow.second, 0);
  });

  test('dateKey and dateFromKey are reversible', () {
    final date = DateTime(2026, 3, 21);
    final key = dateKey(date);
    final restored = dateFromKey(key);

    expect(isSameDate(date, restored), isTrue);
  });

  test('greeting follows the time of day', () {
    String at(int hour, [int minute = 0]) =>
        greetingForNow(DateTime(2026, 11, 10, hour, minute));

    expect(at(4, 59), 'ليلة هادئة');
    expect(at(5), 'صباح الخير');
    expect(at(11, 59), 'صباح الخير');
    expect(at(12), 'نهارك سعيد');
    expect(at(17), 'مساء الخير');
    expect(at(23, 59), 'مساء الخير');
    expect(at(0), 'ليلة هادئة');
  });

  test('nextGreetingChange is the next boundary, where the text differs', () {
    for (var hour = 0; hour < 24; hour++) {
      final now = DateTime(2026, 11, 10, hour, 30);
      final next = nextGreetingChange(now);
      expect(next.isAfter(now), isTrue);
      expect(next.difference(now) <= const Duration(hours: 7), isTrue);
      expect(greetingForNow(next), isNot(greetingForNow(now)));
      expect(
        greetingForNow(next.subtract(const Duration(minutes: 1))),
        greetingForNow(now),
      );
    }
    expect(
      nextGreetingChange(DateTime(2026, 12, 31, 20)),
      DateTime(2027, 1, 1),
    );
  });
}

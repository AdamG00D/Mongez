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
}

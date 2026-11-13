import '../l10n/l10n.dart';

/// Short motivational quotes in the current language.
List<String> get motivationalQuotes {
  final l = L10n.current;
  return <String>[
    l.quote01,
    l.quote02,
    l.quote03,
    l.quote04,
    l.quote05,
    l.quote06,
    l.quote07,
    l.quote08,
    l.quote09,
    l.quote10,
    l.quote11,
    l.quote12,
    l.quote13,
    l.quote14,
    l.quote15,
    l.quote16,
    l.quote17,
    l.quote18,
  ];
}

/// Short encouragement after completing tasks, keyed by completion ratio.
String progressMessage(int done, int total) {
  if (total == 0) {
    return L10n.current.progressEmpty;
  }
  if (done == 0) {
    return L10n.current.progressNone;
  }
  if (done == total) {
    return L10n.current.progressAll;
  }
  final ratio = done / total;
  if (ratio < 0.34) {
    return L10n.current.progressStarted;
  }
  if (ratio < 0.67) {
    return L10n.current.progressHalf;
  }
  return L10n.current.progressAlmost;
}

String quoteOfTheDay([DateTime? date]) {
  final day = date ?? DateTime.now();
  final quotes = motivationalQuotes;
  final index = (day.year * 372 + day.month * 31 + day.day) % quotes.length;
  return quotes[index];
}

String yearProgressMessage(double yearRatio, double goalsRatio) {
  if (goalsRatio >= 1) {
    return L10n.current.yearAllDone;
  }
  if (goalsRatio + 0.05 >= yearRatio) {
    return L10n.current.yearAhead;
  }
  if (goalsRatio + 0.2 >= yearRatio) {
    return L10n.current.yearClose;
  }
  return L10n.current.yearBehind;
}

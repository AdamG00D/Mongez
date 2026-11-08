const List<String> motivationalQuotes = <String>[
  'الخطوات الصغيرة المتكررة تصنع نتائج كبيرة.',
  'لا تنتظر الحماس، ابدأ وسيأتي الحماس.',
  'أنت لا تحتاج أن تكون عظيمًا لتبدأ، لكنك تحتاج أن تبدأ لتكون عظيمًا.',
  'الانضباط هو أن تتذكر ما تريده حقًا.',
  'كل يوم فرصة جديدة لتقترب من هدفك خطوة.',
  'ما تفعله كل يوم أهم مما تفعله مرة واحدة.',
  'التقدّم البطيء أفضل من عدم التقدّم.',
  'ركّز على التحسّن بنسبة 1% كل يوم.',
  'النجاح مجموع جهود صغيرة تتكرر يومًا بعد يوم.',
  'لا تقارن بدايتك بنهاية غيرك.',
  'اجعل هدفك أكبر من أعذارك.',
  'العادة الجيدة تبدأ بقرار، وتستمر بتكرار.',
  'قليل دائم خير من كثير منقطع.',
  'خطّط ليومك قبل أن يخطّط لك.',
  'افعل اليوم ما سيشكرك عليه نفسك غدًا.',
  'الوقت الذي تستمتع بإضاعته ليس وقتًا ضائعًا، لكن الذي تندم عليه هو كذلك.',
  'أصعب خطوة هي الأولى، وأنت قادر عليها.',
  'لا يهم كم أنت بطيء، ما دمت لا تتوقف.',
];

/// Short encouragement after completing tasks, keyed by completion ratio.
String progressMessage(int done, int total) {
  if (total == 0) {
    return 'يوم فارغ؟ أضف أهم مهمة واحدة وابدأ بها.';
  }
  if (done == 0) {
    return 'ابدأ بأسهل مهمة، والباقي سيتبعها.';
  }
  if (done == total) {
    return 'أنجزت كل شيء! يوم رائع 🎉';
  }
  final ratio = done / total;
  if (ratio < 0.34) {
    return 'بداية جميلة، استمر!';
  }
  if (ratio < 0.67) {
    return 'أنت في منتصف الطريق 💪';
  }
  return 'اقتربت جدًا، مهمة أو اثنتان وتنتهي!';
}

String quoteOfTheDay([DateTime? date]) {
  final day = date ?? DateTime.now();
  final index =
      (day.year * 372 + day.month * 31 + day.day) % motivationalQuotes.length;
  return motivationalQuotes[index];
}

String yearProgressMessage(double yearRatio, double goalsRatio) {
  if (goalsRatio >= 1) {
    return 'أنجزت أهداف السنة كلها. وقت أحلام أكبر!';
  }
  if (goalsRatio + 0.05 >= yearRatio) {
    return 'أنت متقدّم على الجدول الزمني، أحسنت!';
  }
  if (goalsRatio + 0.2 >= yearRatio) {
    return 'قريب من المسار، دفعة صغيرة هذا الأسبوع.';
  }
  return 'ما زال هناك وقت. اختر هدفًا واحدًا واعمل عليه اليوم.';
}

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'مُنجز';

  @override
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String get undo => 'تراجع';

  @override
  String get save => 'حفظ';

  @override
  String get edit => 'تعديل';

  @override
  String get later => 'لاحقًا';

  @override
  String get options => 'خيارات';

  @override
  String get refresh => 'تحديث';

  @override
  String get today => 'اليوم';

  @override
  String get tomorrow => 'غدًا';

  @override
  String get yesterday => 'أمس';

  @override
  String get dayAfterTomorrow => 'بعد غد';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get linkOpenFailed => 'تعذر فتح الرابط';

  @override
  String get listSeparator => '، ';

  @override
  String get dateFormatFull => 'EEEE، d MMMM yyyy';

  @override
  String get dateFormatShort => 'd MMMM';

  @override
  String get dateFormatWeekdayDayMonth => 'EEEE، d MMMM';

  @override
  String get dateFormatMonthYear => 'MMMM yyyy';

  @override
  String get timeAm => 'ص';

  @override
  String get timePm => 'م';

  @override
  String get weekdayMonday => 'الإثنين';

  @override
  String get weekdayTuesday => 'الثلاثاء';

  @override
  String get weekdayWednesday => 'الأربعاء';

  @override
  String get weekdayThursday => 'الخميس';

  @override
  String get weekdayFriday => 'الجمعة';

  @override
  String get weekdaySaturday => 'السبت';

  @override
  String get weekdaySunday => 'الأحد';

  @override
  String get greetingNight => 'ليلة هادئة';

  @override
  String get greetingMorning => 'صباح الخير';

  @override
  String get greetingAfternoon => 'نهارك سعيد';

  @override
  String get greetingEvening => 'مساء الخير';

  @override
  String get durationLessThanMinute => 'أقل من دقيقة';

  @override
  String durationMinutes(int minutes) {
    return '$minutes د';
  }

  @override
  String durationHours(int hours) {
    return '$hours س';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours س $minutes د';
  }

  @override
  String durationMinutesCompact(int minutes) {
    return '$minutesد';
  }

  @override
  String durationHoursCompact(String hours) {
    return '$hoursس';
  }

  @override
  String get language => 'اللغة';

  @override
  String get languageSystem => 'لغة الجهاز';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageEnglish => 'English';

  @override
  String get navTasks => 'المهام';

  @override
  String get navGoals => 'الأهداف';

  @override
  String get navHistory => 'السجل';

  @override
  String get navScreenTime => 'وقت الشاشة';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get typeNormal => 'عادية';

  @override
  String get typeDaily => 'يومية';

  @override
  String get typeWeekly => 'أسبوعية';

  @override
  String get priorityNone => 'عادية';

  @override
  String get priorityMedium => 'مهمة';

  @override
  String get priorityHigh => 'عاجلة';

  @override
  String get weeklyReminderOnDays => 'في الأيام المحددة';

  @override
  String get weeklyReminderEveryDay => 'كل يوم حتى أنجزها';

  @override
  String get weeklyReminderLastDay => 'آخر يوم في الأسبوع';

  @override
  String get startPageAuto => 'تلقائي';

  @override
  String get paletteOcean => 'مُنجز';

  @override
  String get paletteEmerald => 'زمردي';

  @override
  String get paletteViolet => 'بنفسجي';

  @override
  String get paletteSunset => 'غروب';

  @override
  String get paletteRose => 'وردي';

  @override
  String get paletteTeal => 'فيروزي';

  @override
  String get paletteAmber => 'رملي';

  @override
  String get paletteRoyal => 'ملكي';

  @override
  String get paletteGraphite => 'رمادي';

  @override
  String get backgroundPlain => 'سادة';

  @override
  String get backgroundSoft => 'هادئ';

  @override
  String get backgroundAurora => 'شفق';

  @override
  String get backgroundMesh => 'متدرّج';

  @override
  String get backgroundDots => 'نقاط';

  @override
  String get backgroundWaves => 'أمواج';

  @override
  String get backgroundGrid => 'شبكة';

  @override
  String get backgroundStars => 'نجوم';

  @override
  String get backgroundCustom => 'صورة من جهازك';

  @override
  String get quote01 => 'الخطوات الصغيرة المتكررة تصنع نتائج كبيرة.';

  @override
  String get quote02 => 'لا تنتظر الحماس، ابدأ وسيأتي الحماس.';

  @override
  String get quote03 =>
      'أنت لا تحتاج أن تكون عظيمًا لتبدأ، لكنك تحتاج أن تبدأ لتكون عظيمًا.';

  @override
  String get quote04 => 'الانضباط هو أن تتذكر ما تريده حقًا.';

  @override
  String get quote05 => 'كل يوم فرصة جديدة لتقترب من هدفك خطوة.';

  @override
  String get quote06 => 'ما تفعله كل يوم أهم مما تفعله مرة واحدة.';

  @override
  String get quote07 => 'التقدّم البطيء أفضل من عدم التقدّم.';

  @override
  String get quote08 => 'ركّز على التحسّن بنسبة 1% كل يوم.';

  @override
  String get quote09 => 'النجاح مجموع جهود صغيرة تتكرر يومًا بعد يوم.';

  @override
  String get quote10 => 'لا تقارن بدايتك بنهاية غيرك.';

  @override
  String get quote11 => 'اجعل هدفك أكبر من أعذارك.';

  @override
  String get quote12 => 'العادة الجيدة تبدأ بقرار، وتستمر بتكرار.';

  @override
  String get quote13 => 'قليل دائم خير من كثير منقطع.';

  @override
  String get quote14 => 'خطّط ليومك قبل أن يخطّط لك.';

  @override
  String get quote15 => 'افعل اليوم ما سيشكرك عليه نفسك غدًا.';

  @override
  String get quote16 =>
      'الوقت الذي تستمتع بإضاعته ليس وقتًا ضائعًا، لكن الذي تندم عليه هو كذلك.';

  @override
  String get quote17 => 'أصعب خطوة هي الأولى، وأنت قادر عليها.';

  @override
  String get quote18 => 'لا يهم كم أنت بطيء، ما دمت لا تتوقف.';

  @override
  String get progressEmpty => 'يوم فارغ؟ أضف أهم مهمة واحدة وابدأ بها.';

  @override
  String get progressNone => 'ابدأ بأسهل مهمة، والباقي سيتبعها.';

  @override
  String get progressAll => 'أنجزت كل شيء! يوم رائع 🎉';

  @override
  String get progressStarted => 'بداية جميلة، استمر!';

  @override
  String get progressHalf => 'أنت في منتصف الطريق 💪';

  @override
  String get progressAlmost => 'اقتربت جدًا، مهمة أو اثنتان وتنتهي!';

  @override
  String get yearAllDone => 'أنجزت أهداف السنة كلها. وقت أحلام أكبر!';

  @override
  String get yearAhead => 'أنت متقدّم على الجدول الزمني، أحسنت!';

  @override
  String get yearClose => 'قريب من المسار، دفعة صغيرة هذا الأسبوع.';

  @override
  String get yearBehind =>
      'ما زال هناك وقت. اختر هدفًا واحدًا واعمل عليه اليوم.';

  @override
  String get seedPlanTomorrow => 'تخطيط أولويات الغد';

  @override
  String get seedWater => 'شرب 8 أكواب ماء';

  @override
  String get seedExercise => 'تمارين خفيفة 20 دقيقة';

  @override
  String get previousWeek => 'الأسبوع السابق';

  @override
  String get nextWeek => 'الأسبوع التالي';

  @override
  String get notificationsOffTitle => 'الإشعارات متوقفة';

  @override
  String get notificationsOffMessage =>
      'لن يصلك تذكير المهمة لأن إشعارات مُنجز متوقفة. فعّلها من الإعدادات.';

  @override
  String get openSettings => 'فتح الإعدادات';

  @override
  String get allowAlarmsTitle => 'اسمح بالمنبّهات والتذكيرات';

  @override
  String get allowAlarmsMessage =>
      'ليصل التذكير في موعده بالضبط، فعّل خيار \"المنبّهات والتذكيرات\" لمُنجز في الصفحة التالية.';

  @override
  String get allow => 'السماح';

  @override
  String get taskDoneThisWeek => 'تمت هذا الأسبوع';

  @override
  String get taskOnceThisWeek => 'مرة هذا الأسبوع';

  @override
  String get markDone => 'تم الإنجاز';

  @override
  String get markNotDone => 'إلغاء الإنجاز';

  @override
  String get allDoneSnack => 'أنجزت كل مهام اليوم! 🎉 استمر هكذا';

  @override
  String get taskDeletedKeepHistory =>
      'تم حذف المهمة (إنجازاتها السابقة باقية في السجل)';

  @override
  String get taskDeleted => 'تم حذف المهمة';

  @override
  String get deleteTaskAndHistoryTitle => 'حذف المهمة وسجلها؟';

  @override
  String deleteTaskAndHistoryMessage(String title, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'سيتم حذف \"$title\" ومعها $count إنجازات من السجل والعدّادات.',
      one: 'سيتم حذف \"$title\" ومعها 1 إنجاز من السجل والعدّادات.',
    );
    return '$_temp0';
  }

  @override
  String get taskAndHistoryDeleted => 'تم حذف المهمة وسجلها';

  @override
  String get postponeToNextDay => 'تأجيل لليوم التالي';

  @override
  String get postponedSnack => 'تم تأجيل المهمة يومًا';

  @override
  String get copyToTomorrow => 'نسخ إلى الغد';

  @override
  String get copiedSnack => 'تمت إضافة نسخة لليوم التالي';

  @override
  String get deleteTask => 'حذف المهمة';

  @override
  String get deleteTaskAndHistory => 'حذف المهمة وسجلها';

  @override
  String deletesCompletionsToo(int count) {
    return 'يحذف أيضًا $count إنجاز من السجل';
  }

  @override
  String get sortedByTime => 'تم ترتيب المهام حسب الوقت';

  @override
  String get sortedByPriority => 'تم ترتيب المهام حسب الأولوية';

  @override
  String get nothingToCarry =>
      'لا توجد مهام لمرة واحدة غير منجزة لنقلها. المهام اليومية والأسبوعية تتكرر تلقائيًا.';

  @override
  String movedTasks(int count, String target) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تم نقل $count مهام إلى $target',
      one: 'تم نقل 1 مهمة إلى $target',
    );
    return '$_temp0';
  }

  @override
  String get newTask => 'مهمة جديدة';

  @override
  String tasksHeaderCount(int count) {
    return 'المهام ($count)';
  }

  @override
  String get longPressToDrag => 'اضغط مطولًا للسحب';

  @override
  String get noTasksForDay => 'لا توجد مهام لهذا اليوم';

  @override
  String get allDoneTitle => 'أنجزت كل شيء!';

  @override
  String get noTasksMessage => 'ابدأ بأهم 3 مهام. القائمة القصيرة تُنجز.';

  @override
  String get completedHiddenMessage =>
      'المهام المكتملة مخفية. يمكنك إظهارها من القائمة.';

  @override
  String tasksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مهمة',
      few: '$count مهام',
      two: 'مهمتان',
      one: 'مهمة واحدة',
      zero: '0 مهام',
    );
    return '$_temp0';
  }

  @override
  String get carryToToday => 'اليوم';

  @override
  String get carryToTomorrow => 'الغد';

  @override
  String get carryToDayAfter => 'بعد غد';

  @override
  String carryToWeekday(String weekday) {
    return 'يوم $weekday';
  }

  @override
  String get sortTodayTasks => 'ترتيب مهام اليوم';

  @override
  String get byTime => 'حسب الوقت';

  @override
  String get byPriority => 'حسب الأولوية';

  @override
  String get showCompleted => 'إظهار المكتملة';

  @override
  String get hideCompleted => 'إخفاء المكتملة';

  @override
  String hiddenNow(String tasks) {
    return '$tasks مخفية الآن';
  }

  @override
  String moveUnfinishedTo(String target) {
    return 'نقل غير المنجز إلى $target';
  }

  @override
  String oneTimeCount(String tasks) {
    return '$tasks لمرة واحدة';
  }

  @override
  String get noUnfinishedOneTime => 'لا توجد مهام لمرة واحدة غير منجزة';

  @override
  String get swipeDone => 'تم';

  @override
  String get swipeUndo => 'إلغاء';

  @override
  String get chooseWeeklyDay => 'اختر يومًا واحدًا على الأقل للمهمة الأسبوعية';

  @override
  String get editTask => 'تعديل المهمة';

  @override
  String get taskTitleHint => 'ماذا تريد أن تنجز؟';

  @override
  String get taskTitleRequired => 'اكتب اسم المهمة';

  @override
  String get noteHint => 'ملاحظات أو تفاصيل (اختياري)';

  @override
  String get addNote => 'إضافة ملاحظة';

  @override
  String get taskTypeLabel => 'النوع';

  @override
  String get startsFrom => 'تبدأ من';

  @override
  String get otherDate => 'تاريخ آخر';

  @override
  String get timeAndReminder => 'الوقت والتذكير';

  @override
  String get noTimeNoReminder => 'بدون وقت (بدون تذكير)';

  @override
  String reminderAt(String time) {
    return 'تذكير $time';
  }

  @override
  String get removeTime => 'حذف الوقت';

  @override
  String get priority => 'الأولوية';

  @override
  String get saveChanges => 'حفظ التعديلات';

  @override
  String get addTask => 'إضافة المهمة';

  @override
  String get weekStartsOn => 'يبدأ الأسبوع يوم';

  @override
  String get onceAnyDay => 'مرة واحدة في أي يوم من الأسبوع';

  @override
  String get availableDays => 'الأيام المتاحة:';

  @override
  String get ifNotDoneRemindMe => 'إذا لم تُنجز، ذكّرني';

  @override
  String get setTimeForReminders => 'حدّد وقتًا للمهمة لتفعيل التذكيرات.';

  @override
  String get goalAchievedSnack => 'حققت هدفًا من أهداف السنة! 🏆 فخورون بك';

  @override
  String get deleteGoalTitle => 'حذف الهدف؟';

  @override
  String deleteGoalMessage(String title) {
    return 'سيتم حذف \"$title\".';
  }

  @override
  String get newGoal => 'هدف جديد';

  @override
  String get yearGoals => 'أهداف السنة';

  @override
  String get goalsEmptyTitle => 'ما أهم ما تريد تحقيقه هذا العام؟';

  @override
  String get goalsEmptyMessage =>
      'اكتب 3 إلى 5 أهداف فقط، وأضف سببك لكل هدف. سنذكّرك بها كل أسبوع.';

  @override
  String get quickSuggestions => 'اقتراحات سريعة';

  @override
  String get yourGoals => 'أهدافك';

  @override
  String get goalsHeroStart => 'ابدأ عامك بوضوح';

  @override
  String goalsHeroDone(int done, int total) {
    return 'حققت $done من $total';
  }

  @override
  String get goalsHeroWritten => 'الأهداف المكتوبة أقرب للتحقق.';

  @override
  String yearElapsed(int percent, int year) {
    return 'مضى $percent% من $year';
  }

  @override
  String daysLeftInYear(int days) {
    return 'متبقٍ $days يومًا';
  }

  @override
  String get goalMarkAchieved => 'تحقق';

  @override
  String get goalUnmark => 'إلغاء';

  @override
  String get decrease => 'إنقاص';

  @override
  String get increase => 'زيادة';

  @override
  String get suggestionBooks => 'قراءة 12 كتابًا';

  @override
  String get suggestionBooksUnit => 'كتاب';

  @override
  String get suggestionFitness => 'ممارسة الرياضة بانتظام';

  @override
  String get suggestionFitnessUnit => 'تمرين';

  @override
  String get suggestionMoney => 'ادخار مبلغ للطوارئ';

  @override
  String get suggestionLanguage => 'تعلّم لغة جديدة';

  @override
  String get suggestionStudy => 'إنهاء كورس احترافي';

  @override
  String get suggestionFaith => 'حفظ جزء من القرآن';

  @override
  String get suggestionTravel => 'السفر إلى مكان جديد';

  @override
  String get suggestionCode => 'بناء مشروع جانبي';

  @override
  String newGoalForYear(int year) {
    return 'هدف جديد لعام $year';
  }

  @override
  String get editGoal => 'تعديل الهدف';

  @override
  String get goalTitleHint => 'ما الذي تريد تحقيقه هذا العام؟';

  @override
  String get goalTitleRequired => 'اكتب الهدف';

  @override
  String get goalWhyHint => 'لماذا هذا الهدف مهم لك؟ (سنذكّرك به حين تفتر)';

  @override
  String get goalIcon => 'الأيقونة';

  @override
  String get numericGoal => 'هدف رقمي قابل للقياس';

  @override
  String get numericGoalExample => 'مثال: 12 كتابًا، 100 تمرين';

  @override
  String get goalTargetHint => 'العدد';

  @override
  String get wholeNumber => 'رقم صحيح';

  @override
  String get goalUnitHint => 'الوحدة (كتاب، كم...)';

  @override
  String get addGoal => 'إضافة الهدف';

  @override
  String get deletedFromHistory => 'تم الحذف من السجل';

  @override
  String get deleteTaskCompletionsTitle => 'حذف كل إنجازات المهمة؟';

  @override
  String deleteTaskCompletionsMessage(int count, String title) {
    return 'سيتم حذف $count إنجاز لـ \"$title\" من السجل والعدّادات. المهمة نفسها لن تُحذف.';
  }

  @override
  String deletedCompletions(int count) {
    return 'تم حذف $count إنجاز';
  }

  @override
  String get clearHistoryTitle => 'مسح السجل بالكامل؟';

  @override
  String clearHistoryMessage(int count) {
    return 'سيتم حذف كل الإنجازات ($count) والعدّادات وسلاسل الأيام. مهامك نفسها لن تُحذف.';
  }

  @override
  String get historyCleared => 'تم مسح السجل';

  @override
  String get historyTitle => 'السجل والإحصائيات';

  @override
  String get historyOptions => 'خيارات السجل';

  @override
  String get clearHistory => 'مسح السجل بالكامل';

  @override
  String get totalCompletions => 'إجمالي الإنجازات';

  @override
  String weekAndMonthCompletions(int week, int month) {
    return 'هذا الأسبوع $week • هذا الشهر $month';
  }

  @override
  String get streakDays => 'أيام متتالية';

  @override
  String bestStreak(int count) {
    return 'الأفضل: $count';
  }

  @override
  String get countByType => 'عدّاد الإنجاز حسب النوع';

  @override
  String typeTasks(String type) {
    return 'مهام $type';
  }

  @override
  String get last7Days => 'آخر 7 أيام';

  @override
  String get mostCompleted => 'الأكثر إنجازًا';

  @override
  String get completionLog => 'سجل الإنجاز';

  @override
  String get tapToDelete => 'اضغط على إنجاز لحذفه';

  @override
  String filterAll(int count) {
    return 'الكل ($count)';
  }

  @override
  String get noCompletionsTitle => 'لا إنجازات بعد';

  @override
  String get noCompletionsMessage =>
      'كل مهمة تنهيها تُسجَّل هنا مع وقت إنجازها، ولا يضيع السجل عند حذف المهمة.';

  @override
  String completedAt(String date, String time) {
    return 'أُنجزت $date • $time';
  }

  @override
  String get deleteThisCompletion => 'حذف هذا الإنجاز من السجل';

  @override
  String deleteAllTaskCompletions(int count) {
    return 'حذف كل إنجازات هذه المهمة ($count)';
  }

  @override
  String forDay(String date) {
    return 'عن يوم $date';
  }

  @override
  String dailyLimitFor(String app) {
    return 'حدّ يومي لـ $app';
  }

  @override
  String get noLimit => 'بدون حد';

  @override
  String get notSupportedTitle => 'غير مدعوم';

  @override
  String get notSupportedMessage =>
      'ميزة وقت الشاشة متاحة على أجهزة أندرويد فقط.';

  @override
  String get usageAccessTitle => 'الوصول إلى بيانات الاستخدام';

  @override
  String get noThanks => 'لا، شكرًا';

  @override
  String get agreeContinue => 'موافق، متابعة';

  @override
  String get screenTimeIntroTitle => 'اعرف أين يذهب وقتك';

  @override
  String get screenTimeIntroMessage =>
      'شاهد عدد ساعات فتح الشاشة، ومرات فتح القفل، والوقت في كل تطبيق.';

  @override
  String get screenTimePoint1 => 'إجمالي وقت الشاشة يوميًا وأسبوعيًا';

  @override
  String get screenTimePoint2 => 'ترتيب التطبيقات حسب الاستخدام';

  @override
  String get screenTimePoint3 => 'تتبع تطبيقات معيّنة بحد يومي';

  @override
  String get screenTimePoint4 => 'البيانات تبقى على جهازك ولا تُرسل لأي مكان';

  @override
  String get screenTimeGrantHint =>
      'اضغط الزر ثم فعّل \"مُنجز\" في قائمة \"الوصول إلى بيانات الاستخدام\"، ثم ارجع للتطبيق.';

  @override
  String get grantUsageAccess => 'منح صلاحية الوصول للاستخدام';

  @override
  String get restrictedTitle => 'زر السماح رمادي ولا يعمل؟';

  @override
  String get restrictedSubtitle =>
      'يظهر تحته \"Controlled by restricted setting\"';

  @override
  String get restrictedIntro =>
      'أندرويد يقفل هذه الصلاحية للتطبيقات المثبّتة من ملف APK. افتحها مرة واحدة هكذا:';

  @override
  String get restrictedStep1 =>
      'اضغط زر السماح الرمادي مرة واحدة حتى تظهر رسالة المنع، ثم أغلقها.';

  @override
  String get restrictedStep2 => 'اضغط \"فتح معلومات التطبيق\" بالأسفل.';

  @override
  String get restrictedStep3 =>
      'اضغط النقاط الثلاث ⋮ أعلى الصفحة ثم \"السماح بالإعدادات المقيّدة\" (Allow restricted settings) وأكّد ببصمتك أو رمز القفل.';

  @override
  String get restrictedStep4 =>
      'ارجع إلى هنا واضغط \"منح صلاحية الوصول للاستخدام\".';

  @override
  String get restrictedNote => 'لا تظهر النقاط الثلاث إلا بعد الخطوة الأولى.';

  @override
  String get openAppInfo => 'فتح معلومات التطبيق';

  @override
  String get screenOnTime => 'وقت فتح الشاشة';

  @override
  String unlocksCount(int count) {
    return '$count مرة فتح قفل';
  }

  @override
  String appsCount(int count) {
    return '$count تطبيق';
  }

  @override
  String belowAverage(String duration) {
    return 'أقل من متوسطك بـ $duration';
  }

  @override
  String aboveAverage(String duration) {
    return 'أعلى من متوسطك بـ $duration';
  }

  @override
  String averageLabel(String duration) {
    return 'المتوسط $duration';
  }

  @override
  String get trackedApps => 'تطبيقات أتابعها';

  @override
  String durationToday(String duration) {
    return '$duration اليوم';
  }

  @override
  String usageOfLimit(String used, String limit) {
    return '$used من $limit';
  }

  @override
  String get overLimit => ' — تجاوزت الحد!';

  @override
  String get editDailyLimit => 'تعديل الحد اليومي';

  @override
  String get stopTracking => 'إلغاء المتابعة';

  @override
  String get mostUsedApps => 'التطبيقات الأكثر استخدامًا';

  @override
  String get tapToTrack => 'اضغط لمتابعة تطبيق';

  @override
  String get loading => 'جارٍ التحميل...';

  @override
  String get noDataForDay => 'لا توجد بيانات لهذا اليوم.';

  @override
  String get notificationsEnabledUpdated =>
      'الإشعارات مفعّلة وتم تحديث التذكيرات';

  @override
  String get notificationsNotGranted => 'لم يتم منح صلاحية الإشعارات';

  @override
  String get backupSaved => 'تم حفظ النسخة الاحتياطية';

  @override
  String backupSaveFailed(String error) {
    return 'تعذر حفظ النسخة: $error';
  }

  @override
  String get fileReadFailed => 'تعذر قراءة الملف';

  @override
  String get restoreTitle => 'استعادة النسخة؟';

  @override
  String restoreMessage(int tasks, int goals, int history) {
    return 'سيتم استبدال المهام ($tasks) والأهداف ($goals) الحالية. السجل لن يُحذف، بل ستُدمج سجلات النسخة ($history) معه.';
  }

  @override
  String get restore => 'استعادة';

  @override
  String get restoreDone => 'تمت الاستعادة بنجاح';

  @override
  String get widgetPinRequested =>
      'تم إرسال طلب إضافة الويدجت إلى الشاشة الرئيسية';

  @override
  String get widgetPinUnsupported =>
      'اللانشر لا يدعم الإضافة التلقائية. أضف الويدجت يدويًا من قائمة الويدجت.';

  @override
  String get appearance => 'المظهر';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get themeSystem => 'النظام';

  @override
  String get colorTheme => 'سمة الألوان';

  @override
  String get amoledTitle => 'أسود كامل (AMOLED)';

  @override
  String get amoledSubtitle => 'يوفّر البطارية في شاشات OLED';

  @override
  String get appBackground => 'خلفية التطبيق';

  @override
  String get imagePickFailed => 'تعذر اختيار الصورة';

  @override
  String get dimImage => 'تعتيم الصورة لوضوح النص';

  @override
  String get changeImage => 'تغيير الصورة';

  @override
  String get tasksAndWeek => 'المهام والأسبوع';

  @override
  String get firstDayOfWeek => 'أول أيام الأسبوع';

  @override
  String get firstDayOfWeekSubtitle =>
      'يحدد بداية الأسبوع للمهام الأسبوعية والإحصائيات';

  @override
  String get startDayTitle => 'اليوم الظاهر عند فتح التطبيق';

  @override
  String get startDayAutoHint =>
      'تلقائي: اليوم نهارًا، والغد بعد الساعة 7 مساءً للتخطيط.';

  @override
  String get hideCompletedTasks => 'إخفاء المهام المكتملة';

  @override
  String get celebrateTitle => 'الاحتفال والأصوات';

  @override
  String get celebrateSubtitle =>
      'صوت عند إنجاز كل مهمة، واحتفال بصوت عند إنهاء مهام اليوم أو تحقيق هدف';

  @override
  String get reminders => 'التذكيرات';

  @override
  String get notificationsEnabled => 'الإشعارات مفعّلة';

  @override
  String get notificationsDisabled => 'الإشعارات غير مفعّلة';

  @override
  String get notificationsTapToGrant => 'اضغط لمنح الصلاحيات وتحديث المواعيد';

  @override
  String get followUpTitle => 'ذكّرني مجددًا إن لم أُنجز';

  @override
  String followUpSubtitle(String duration) {
    return 'بعد $duration من موعد المهمة';
  }

  @override
  String get planningTitle => 'تذكير مسائي لتخطيط الغد';

  @override
  String planningSubtitle(String time) {
    return 'يوميًا الساعة $time';
  }

  @override
  String get changeTime => 'تغيير الوقت';

  @override
  String get goalsReminderTitle => 'تحفيز أسبوعي بأهداف السنة';

  @override
  String get goalsReminderSubtitle => 'كل جمعة الساعة 10 صباحًا';

  @override
  String get homeWidgets => 'ويدجت الشاشة الرئيسية';

  @override
  String get todayWidget => 'ويدجت مهام اليوم';

  @override
  String get todayWidgetSubtitle => 'قائمة المهام مع التقدّم وإنجاز بلمسة';

  @override
  String get summaryWidget => 'ويدجت الملخّص';

  @override
  String get summaryWidgetSubtitle => 'نسبة الإنجاز والمهمة التالية';

  @override
  String get refreshWidgetNow => 'تحديث الويدجت الآن';

  @override
  String get widgetRefreshed => 'تم تحديث الويدجت';

  @override
  String get data => 'البيانات';

  @override
  String get saveBackup => 'حفظ نسخة احتياطية';

  @override
  String get saveBackupSubtitle => 'المهام والأهداف والسجل في ملف واحد';

  @override
  String get restoreFromBackup => 'استعادة من نسخة';

  @override
  String get restoreFromBackupSubtitle => 'السجل يُدمج ولا يُحذف أبدًا';

  @override
  String get about => 'حول التطبيق';

  @override
  String versionOffline(String version) {
    return 'الإصدار $version • يعمل بدون إنترنت';
  }

  @override
  String get backupDialogTitle => 'حفظ نسخة احتياطية';

  @override
  String get backupPickTitle => 'اختر ملف النسخة';

  @override
  String get backupInvalid => 'الملف ليس نسخة احتياطية صالحة';

  @override
  String get backupNotMongez => 'الملف ليس نسخة احتياطية من مُنجز';

  @override
  String get channelTasks => 'تذكير المهام';

  @override
  String get channelTasksDescription => 'تنبيه عند موعد المهمة';

  @override
  String get channelFollowUp => 'متابعة المهام غير المنجزة';

  @override
  String get channelFollowUpDescription =>
      'تذكير إضافي إذا لم تُنجز المهمة بعد موعدها';

  @override
  String get channelPlanning => 'تخطيط الغد';

  @override
  String get channelPlanningDescription => 'تذكير مسائي لتخطيط مهام الغد';

  @override
  String get channelGoals => 'تحفيز الأهداف';

  @override
  String get channelGoalsDescription => 'تذكير أسبوعي بأهداف السنة';

  @override
  String get notifTaskNormal => 'حان وقت مهمتك';

  @override
  String get notifTaskDaily => 'مهمتك اليومية';

  @override
  String get notifTaskWeekly => 'مهمة الأسبوع لم تُنجز بعد';

  @override
  String get notifFollowUpTitle => 'لم تُنجز بعد ⏳';

  @override
  String notifFollowUpBody(String title) {
    return '$title — ما زال أمامك وقت، ابدأ الآن.';
  }

  @override
  String get notifPlanTitle => 'خطّط لغدك 🌙';

  @override
  String get notifPlanEmpty =>
      'لم تضف مهام للغد بعد. دقيقتان الآن توفّر عليك يومًا مشتتًا.';

  @override
  String notifPlanCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'لديك $count مهام للغد. راجعها ورتّب أولوياتك.',
      one: 'لديك 1 مهمة للغد. راجعها ورتّب أولوياتك.',
    );
    return '$_temp0';
  }

  @override
  String notifGoalsTitle(int year) {
    return 'أهدافك لعام $year 🎯';
  }

  @override
  String notifGoalsAllDone(int done, int total, String quote) {
    return 'أنجزت كل أهدافك ($done/$total)! $quote';
  }

  @override
  String notifGoalsFocus(int done, int total, String goal, String quote) {
    return 'أنجزت $done من $total. ركّز هذا الأسبوع على: $goal\n$quote';
  }

  @override
  String get notifDoneAction => 'تم الإنجاز ✓';

  @override
  String get widgetTitle => 'مهام اليوم';

  @override
  String get widgetNoTasks => 'لا مهام';

  @override
  String get widgetEmptyDay => 'يومك فارغ';

  @override
  String get widgetAllDone => 'أنجزت كل شيء 🎉';

  @override
  String get widgetNoTasksToday => 'لا مهام اليوم';

  @override
  String widgetDoneOf(int done, int total) {
    return 'أنجزت $done من $total';
  }

  @override
  String get widgetNext => 'التالي';

  @override
  String get widgetEmptyList => 'لا مهام لليوم — اضغط + لإضافة مهمة';

  @override
  String get widgetAddTask => 'إضافة مهمة';

  @override
  String get widgetOpenApp => 'افتح مُنجز';

  @override
  String get usageAccessDisclosure =>
      'لعرض وقت الشاشة، يقرأ مُنجز من نظام أندرويد بيانات استخدام هاتفك: التطبيقات التي تفتحها، ومدة استخدام كل تطبيق، ومدة تشغيل الشاشة، وعدد مرات فتح القفل.\n\nتُقرأ هذه البيانات أثناء فتحك للتطبيق فقط (وليس في الخلفية)، وتُعرض لك في شاشة \"وقت الشاشة\"، وتبقى على جهازك: لا تُرسل ولا تُباع ولا تُشارك مع أي جهة. التطبيق لا يتصل بالإنترنت أصلًا.\n\nيمكنك إلغاء الصلاحية في أي وقت من إعدادات الهاتف.';

  @override
  String get privacySummaryTitle => 'الخلاصة';

  @override
  String get privacySummaryBody =>
      'مُنجز يعمل بالكامل على هاتفك. لا يوجد حساب، ولا إعلانات، ولا أدوات تتبّع أو تحليلات، والتطبيق لا يملك صلاحية الاتصال بالإنترنت. نحن لا نجمع أي بيانات عنك ولا نستقبلها.';

  @override
  String get privacyStoredTitle => 'البيانات المحفوظة على جهازك';

  @override
  String get privacyStoredBody =>
      'مهامك وملاحظاتها، سجل الإنجاز، أهدافك، إعدادات التطبيق، قائمة التطبيقات التي اخترت متابعتها وحدودها اليومية، وصورة الخلفية إن اخترت واحدة. كلها محفوظة في مساحة التطبيق الخاصة على الهاتف فقط.';

  @override
  String get privacyUsageTitle => 'بيانات استخدام الهاتف (وقت الشاشة)';

  @override
  String get privacyUsageIntro =>
      'هذه الميزة اختيارية ولا تعمل إلا إذا منحت التطبيق صلاحية \"الوصول إلى بيانات الاستخدام\" بنفسك من إعدادات الهاتف.';

  @override
  String get privacyPermissionsTitle => 'الصلاحيات الأخرى';

  @override
  String get privacyPermissionsBody =>
      '• الإشعارات والمنبّهات والتذكيرات: لإرسال تذكيرات المهام في موعدها.\n• التشغيل عند إقلاع الهاتف: لإعادة جدولة التذكيرات بعد إعادة التشغيل.\n• الاهتزاز: مع التذكيرات.\n• الصور: لا يطلب التطبيق صلاحية الصور؛ عند اختيار خلفية تُفتح أداة اختيار الصور الخاصة بالنظام ويحصل التطبيق على الصورة التي تختارها فقط.';

  @override
  String get privacyBackupTitle => 'النسخ الاحتياطي';

  @override
  String get privacyBackupBody =>
      'عند تصدير نسخة احتياطية يُنشأ ملف في المكان الذي تختاره أنت، وأنت من يتحكم فيه. قد ينسخ نظام أندرويد بيانات التطبيق ضمن النسخ الاحتياطي لحسابك في Google إذا كان مفعّلًا على هاتفك؛ هذا خاضع لإعدادات هاتفك وسياسة Google.';

  @override
  String get privacyDeleteTitle => 'حذف بياناتك';

  @override
  String get privacyDeleteBody =>
      'يمكنك حذف المهام والسجل من داخل التطبيق. ولحذف كل شيء: امسح بيانات التطبيق من إعدادات الهاتف أو أزل التطبيق.';

  @override
  String get privacyChildrenTitle => 'الأطفال';

  @override
  String get privacyChildrenBody =>
      'التطبيق أداة تنظيم عامة وغير موجّه للأطفال، ولا يجمع بيانات من أي مستخدم.';

  @override
  String get privacyChangesTitle => 'التغييرات والتواصل';

  @override
  String get privacyChangesBody =>
      'أي تغيير على هذه السياسة يُنشر مع تحديث التطبيق وفي صفحة المشروع. التطبيق مفتوح المصدر، وللأسئلة يمكنك فتح تذكرة في صفحة المشروع على GitHub.\n\nآخر تحديث: 10 نوفمبر 2026';

  @override
  String get privacyWebVersion => 'نسخة الويب (عربي / English)';
}

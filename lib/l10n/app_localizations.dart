import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Mongez'**
  String get appName;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @options.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get options;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @dayAfterTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Day after tomorrow'**
  String get dayAfterTomorrow;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicy;

  /// No description provided for @linkOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open the link'**
  String get linkOpenFailed;

  /// No description provided for @listSeparator.
  ///
  /// In en, this message translates to:
  /// **', '**
  String get listSeparator;

  /// No description provided for @dateFormatFull.
  ///
  /// In en, this message translates to:
  /// **'EEEE, MMMM d, yyyy'**
  String get dateFormatFull;

  /// No description provided for @dateFormatShort.
  ///
  /// In en, this message translates to:
  /// **'MMMM d'**
  String get dateFormatShort;

  /// No description provided for @dateFormatWeekdayDayMonth.
  ///
  /// In en, this message translates to:
  /// **'EEEE, MMMM d'**
  String get dateFormatWeekdayDayMonth;

  /// No description provided for @dateFormatMonthYear.
  ///
  /// In en, this message translates to:
  /// **'MMMM yyyy'**
  String get dateFormatMonthYear;

  /// No description provided for @timeAm.
  ///
  /// In en, this message translates to:
  /// **'AM'**
  String get timeAm;

  /// No description provided for @timePm.
  ///
  /// In en, this message translates to:
  /// **'PM'**
  String get timePm;

  /// No description provided for @weekdayMonday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get weekdayMonday;

  /// No description provided for @weekdayTuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get weekdayTuesday;

  /// No description provided for @weekdayWednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get weekdayWednesday;

  /// No description provided for @weekdayThursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get weekdayThursday;

  /// No description provided for @weekdayFriday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get weekdayFriday;

  /// No description provided for @weekdaySaturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get weekdaySaturday;

  /// No description provided for @weekdaySunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get weekdaySunday;

  /// No description provided for @greetingNight.
  ///
  /// In en, this message translates to:
  /// **'Quiet night'**
  String get greetingNight;

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get greetingEvening;

  /// No description provided for @durationLessThanMinute.
  ///
  /// In en, this message translates to:
  /// **'Less than a minute'**
  String get durationLessThanMinute;

  /// No description provided for @durationMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String durationMinutes(int minutes);

  /// No description provided for @durationHours.
  ///
  /// In en, this message translates to:
  /// **'{hours} h'**
  String durationHours(int hours);

  /// No description provided for @durationHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'{hours} h {minutes} min'**
  String durationHoursMinutes(int hours, int minutes);

  /// No description provided for @durationMinutesCompact.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m'**
  String durationMinutesCompact(int minutes);

  /// No description provided for @durationHoursCompact.
  ///
  /// In en, this message translates to:
  /// **'{hours}h'**
  String durationHoursCompact(String hours);

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'Device language'**
  String get languageSystem;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @navTasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get navTasks;

  /// No description provided for @navGoals.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get navGoals;

  /// No description provided for @navHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get navHistory;

  /// No description provided for @navScreenTime.
  ///
  /// In en, this message translates to:
  /// **'Screen time'**
  String get navScreenTime;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @typeNormal.
  ///
  /// In en, this message translates to:
  /// **'One-time'**
  String get typeNormal;

  /// No description provided for @typeDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get typeDaily;

  /// No description provided for @typeWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get typeWeekly;

  /// No description provided for @priorityNone.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get priorityNone;

  /// No description provided for @priorityMedium.
  ///
  /// In en, this message translates to:
  /// **'Important'**
  String get priorityMedium;

  /// No description provided for @priorityHigh.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get priorityHigh;

  /// No description provided for @weeklyReminderOnDays.
  ///
  /// In en, this message translates to:
  /// **'On the chosen days'**
  String get weeklyReminderOnDays;

  /// No description provided for @weeklyReminderEveryDay.
  ///
  /// In en, this message translates to:
  /// **'Every day until done'**
  String get weeklyReminderEveryDay;

  /// No description provided for @weeklyReminderLastDay.
  ///
  /// In en, this message translates to:
  /// **'On the last day of the week'**
  String get weeklyReminderLastDay;

  /// No description provided for @startPageAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get startPageAuto;

  /// No description provided for @paletteOcean.
  ///
  /// In en, this message translates to:
  /// **'Mongez'**
  String get paletteOcean;

  /// No description provided for @paletteEmerald.
  ///
  /// In en, this message translates to:
  /// **'Emerald'**
  String get paletteEmerald;

  /// No description provided for @paletteViolet.
  ///
  /// In en, this message translates to:
  /// **'Violet'**
  String get paletteViolet;

  /// No description provided for @paletteSunset.
  ///
  /// In en, this message translates to:
  /// **'Sunset'**
  String get paletteSunset;

  /// No description provided for @paletteRose.
  ///
  /// In en, this message translates to:
  /// **'Rose'**
  String get paletteRose;

  /// No description provided for @paletteTeal.
  ///
  /// In en, this message translates to:
  /// **'Teal'**
  String get paletteTeal;

  /// No description provided for @paletteAmber.
  ///
  /// In en, this message translates to:
  /// **'Sand'**
  String get paletteAmber;

  /// No description provided for @paletteRoyal.
  ///
  /// In en, this message translates to:
  /// **'Royal'**
  String get paletteRoyal;

  /// No description provided for @paletteGraphite.
  ///
  /// In en, this message translates to:
  /// **'Graphite'**
  String get paletteGraphite;

  /// No description provided for @backgroundPlain.
  ///
  /// In en, this message translates to:
  /// **'Plain'**
  String get backgroundPlain;

  /// No description provided for @backgroundSoft.
  ///
  /// In en, this message translates to:
  /// **'Soft'**
  String get backgroundSoft;

  /// No description provided for @backgroundAurora.
  ///
  /// In en, this message translates to:
  /// **'Aurora'**
  String get backgroundAurora;

  /// No description provided for @backgroundMesh.
  ///
  /// In en, this message translates to:
  /// **'Gradient'**
  String get backgroundMesh;

  /// No description provided for @backgroundDots.
  ///
  /// In en, this message translates to:
  /// **'Dots'**
  String get backgroundDots;

  /// No description provided for @backgroundWaves.
  ///
  /// In en, this message translates to:
  /// **'Waves'**
  String get backgroundWaves;

  /// No description provided for @backgroundGrid.
  ///
  /// In en, this message translates to:
  /// **'Grid'**
  String get backgroundGrid;

  /// No description provided for @backgroundStars.
  ///
  /// In en, this message translates to:
  /// **'Stars'**
  String get backgroundStars;

  /// No description provided for @backgroundCustom.
  ///
  /// In en, this message translates to:
  /// **'Your photo'**
  String get backgroundCustom;

  /// No description provided for @quote01.
  ///
  /// In en, this message translates to:
  /// **'Small steps, repeated, make big results.'**
  String get quote01;

  /// No description provided for @quote02.
  ///
  /// In en, this message translates to:
  /// **'Don\'t wait for motivation. Start, and it will come.'**
  String get quote02;

  /// No description provided for @quote03.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have to be great to start, but you have to start to be great.'**
  String get quote03;

  /// No description provided for @quote04.
  ///
  /// In en, this message translates to:
  /// **'Discipline is remembering what you really want.'**
  String get quote04;

  /// No description provided for @quote05.
  ///
  /// In en, this message translates to:
  /// **'Every day is a new chance to get one step closer to your goal.'**
  String get quote05;

  /// No description provided for @quote06.
  ///
  /// In en, this message translates to:
  /// **'What you do every day matters more than what you do once in a while.'**
  String get quote06;

  /// No description provided for @quote07.
  ///
  /// In en, this message translates to:
  /// **'Slow progress beats no progress.'**
  String get quote07;

  /// No description provided for @quote08.
  ///
  /// In en, this message translates to:
  /// **'Focus on getting 1% better every day.'**
  String get quote08;

  /// No description provided for @quote09.
  ///
  /// In en, this message translates to:
  /// **'Success is the sum of small efforts, repeated day in and day out.'**
  String get quote09;

  /// No description provided for @quote10.
  ///
  /// In en, this message translates to:
  /// **'Don\'t compare your beginning to someone else\'s end.'**
  String get quote10;

  /// No description provided for @quote11.
  ///
  /// In en, this message translates to:
  /// **'Make your goal bigger than your excuses.'**
  String get quote11;

  /// No description provided for @quote12.
  ///
  /// In en, this message translates to:
  /// **'A good habit starts with a decision and lasts through repetition.'**
  String get quote12;

  /// No description provided for @quote13.
  ///
  /// In en, this message translates to:
  /// **'A little done consistently beats a lot done once.'**
  String get quote13;

  /// No description provided for @quote14.
  ///
  /// In en, this message translates to:
  /// **'Plan your day before it plans you.'**
  String get quote14;

  /// No description provided for @quote15.
  ///
  /// In en, this message translates to:
  /// **'Do today what your future self will thank you for.'**
  String get quote15;

  /// No description provided for @quote16.
  ///
  /// In en, this message translates to:
  /// **'Time you enjoy wasting isn\'t wasted. Time you regret is.'**
  String get quote16;

  /// No description provided for @quote17.
  ///
  /// In en, this message translates to:
  /// **'The first step is the hardest, and you can take it.'**
  String get quote17;

  /// No description provided for @quote18.
  ///
  /// In en, this message translates to:
  /// **'It doesn\'t matter how slowly you go, as long as you don\'t stop.'**
  String get quote18;

  /// No description provided for @progressEmpty.
  ///
  /// In en, this message translates to:
  /// **'Empty day? Add your most important task and start with it.'**
  String get progressEmpty;

  /// No description provided for @progressNone.
  ///
  /// In en, this message translates to:
  /// **'Start with the easiest task; the rest will follow.'**
  String get progressNone;

  /// No description provided for @progressAll.
  ///
  /// In en, this message translates to:
  /// **'All done! What a day 🎉'**
  String get progressAll;

  /// No description provided for @progressStarted.
  ///
  /// In en, this message translates to:
  /// **'Nice start, keep going!'**
  String get progressStarted;

  /// No description provided for @progressHalf.
  ///
  /// In en, this message translates to:
  /// **'You\'re halfway there 💪'**
  String get progressHalf;

  /// No description provided for @progressAlmost.
  ///
  /// In en, this message translates to:
  /// **'Almost there, one or two tasks to go!'**
  String get progressAlmost;

  /// No description provided for @yearAllDone.
  ///
  /// In en, this message translates to:
  /// **'You achieved all this year\'s goals. Time for bigger dreams!'**
  String get yearAllDone;

  /// No description provided for @yearAhead.
  ///
  /// In en, this message translates to:
  /// **'You\'re ahead of schedule. Well done!'**
  String get yearAhead;

  /// No description provided for @yearClose.
  ///
  /// In en, this message translates to:
  /// **'Close to the track. A little push this week.'**
  String get yearClose;

  /// No description provided for @yearBehind.
  ///
  /// In en, this message translates to:
  /// **'There\'s still time. Pick one goal and work on it today.'**
  String get yearBehind;

  /// No description provided for @seedPlanTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Plan tomorrow\'s priorities'**
  String get seedPlanTomorrow;

  /// No description provided for @seedWater.
  ///
  /// In en, this message translates to:
  /// **'Drink 8 glasses of water'**
  String get seedWater;

  /// No description provided for @seedExercise.
  ///
  /// In en, this message translates to:
  /// **'20 minutes of light exercise'**
  String get seedExercise;

  /// No description provided for @previousWeek.
  ///
  /// In en, this message translates to:
  /// **'Previous week'**
  String get previousWeek;

  /// No description provided for @nextWeek.
  ///
  /// In en, this message translates to:
  /// **'Next week'**
  String get nextWeek;

  /// No description provided for @notificationsOffTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications are off'**
  String get notificationsOffTitle;

  /// No description provided for @notificationsOffMessage.
  ///
  /// In en, this message translates to:
  /// **'You won\'t get this task\'s reminder because Mongez notifications are off. Turn them on in Settings.'**
  String get notificationsOffMessage;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSettings;

  /// No description provided for @allowAlarmsTitle.
  ///
  /// In en, this message translates to:
  /// **'Allow alarms & reminders'**
  String get allowAlarmsTitle;

  /// No description provided for @allowAlarmsMessage.
  ///
  /// In en, this message translates to:
  /// **'To get reminders exactly on time, turn on \"Alarms & reminders\" for Mongez on the next page.'**
  String get allowAlarmsMessage;

  /// No description provided for @allow.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get allow;

  /// No description provided for @taskDoneThisWeek.
  ///
  /// In en, this message translates to:
  /// **'Done this week'**
  String get taskDoneThisWeek;

  /// No description provided for @taskOnceThisWeek.
  ///
  /// In en, this message translates to:
  /// **'Once this week'**
  String get taskOnceThisWeek;

  /// No description provided for @markDone.
  ///
  /// In en, this message translates to:
  /// **'Mark done'**
  String get markDone;

  /// No description provided for @markNotDone.
  ///
  /// In en, this message translates to:
  /// **'Mark not done'**
  String get markNotDone;

  /// No description provided for @allDoneSnack.
  ///
  /// In en, this message translates to:
  /// **'You finished all of today\'s tasks! 🎉 Keep it up'**
  String get allDoneSnack;

  /// No description provided for @taskDeletedKeepHistory.
  ///
  /// In en, this message translates to:
  /// **'Task deleted (its past completions stay in history)'**
  String get taskDeletedKeepHistory;

  /// No description provided for @taskDeleted.
  ///
  /// In en, this message translates to:
  /// **'Task deleted'**
  String get taskDeleted;

  /// No description provided for @deleteTaskAndHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete the task and its history?'**
  String get deleteTaskAndHistoryTitle;

  /// No description provided for @deleteTaskAndHistoryMessage.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" will be deleted along with {count, plural, =1{1 completion} other{{count} completions}} from history and counters.'**
  String deleteTaskAndHistoryMessage(String title, int count);

  /// No description provided for @taskAndHistoryDeleted.
  ///
  /// In en, this message translates to:
  /// **'Task and its history deleted'**
  String get taskAndHistoryDeleted;

  /// No description provided for @postponeToNextDay.
  ///
  /// In en, this message translates to:
  /// **'Postpone to the next day'**
  String get postponeToNextDay;

  /// No description provided for @postponedSnack.
  ///
  /// In en, this message translates to:
  /// **'Task postponed by a day'**
  String get postponedSnack;

  /// No description provided for @copyToTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Copy to tomorrow'**
  String get copyToTomorrow;

  /// No description provided for @copiedSnack.
  ///
  /// In en, this message translates to:
  /// **'A copy was added to the next day'**
  String get copiedSnack;

  /// No description provided for @deleteTask.
  ///
  /// In en, this message translates to:
  /// **'Delete task'**
  String get deleteTask;

  /// No description provided for @deleteTaskAndHistory.
  ///
  /// In en, this message translates to:
  /// **'Delete task and its history'**
  String get deleteTaskAndHistory;

  /// No description provided for @deletesCompletionsToo.
  ///
  /// In en, this message translates to:
  /// **'Also deletes {count, plural, =1{1 completion} other{{count} completions}} from history'**
  String deletesCompletionsToo(int count);

  /// No description provided for @sortedByTime.
  ///
  /// In en, this message translates to:
  /// **'Tasks sorted by time'**
  String get sortedByTime;

  /// No description provided for @sortedByPriority.
  ///
  /// In en, this message translates to:
  /// **'Tasks sorted by priority'**
  String get sortedByPriority;

  /// No description provided for @nothingToCarry.
  ///
  /// In en, this message translates to:
  /// **'No unfinished one-time tasks to move. Daily and weekly tasks repeat automatically.'**
  String get nothingToCarry;

  /// No description provided for @movedTasks.
  ///
  /// In en, this message translates to:
  /// **'Moved {count, plural, =1{1 task} other{{count} tasks}} to {target}'**
  String movedTasks(int count, String target);

  /// No description provided for @newTask.
  ///
  /// In en, this message translates to:
  /// **'New task'**
  String get newTask;

  /// No description provided for @tasksHeaderCount.
  ///
  /// In en, this message translates to:
  /// **'Tasks ({count})'**
  String tasksHeaderCount(int count);

  /// No description provided for @longPressToDrag.
  ///
  /// In en, this message translates to:
  /// **'Long-press to drag'**
  String get longPressToDrag;

  /// No description provided for @noTasksForDay.
  ///
  /// In en, this message translates to:
  /// **'No tasks for this day'**
  String get noTasksForDay;

  /// No description provided for @allDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'All done!'**
  String get allDoneTitle;

  /// No description provided for @noTasksMessage.
  ///
  /// In en, this message translates to:
  /// **'Start with your top 3 tasks. A short list gets done.'**
  String get noTasksMessage;

  /// No description provided for @completedHiddenMessage.
  ///
  /// In en, this message translates to:
  /// **'Completed tasks are hidden. You can show them from the menu.'**
  String get completedHiddenMessage;

  /// No description provided for @tasksCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 task} other{{count} tasks}}'**
  String tasksCount(int count);

  /// No description provided for @carryToToday.
  ///
  /// In en, this message translates to:
  /// **'today'**
  String get carryToToday;

  /// No description provided for @carryToTomorrow.
  ///
  /// In en, this message translates to:
  /// **'tomorrow'**
  String get carryToTomorrow;

  /// No description provided for @carryToDayAfter.
  ///
  /// In en, this message translates to:
  /// **'the day after tomorrow'**
  String get carryToDayAfter;

  /// No description provided for @carryToWeekday.
  ///
  /// In en, this message translates to:
  /// **'{weekday}'**
  String carryToWeekday(String weekday);

  /// No description provided for @sortTodayTasks.
  ///
  /// In en, this message translates to:
  /// **'Sort today\'s tasks'**
  String get sortTodayTasks;

  /// No description provided for @byTime.
  ///
  /// In en, this message translates to:
  /// **'By time'**
  String get byTime;

  /// No description provided for @byPriority.
  ///
  /// In en, this message translates to:
  /// **'By priority'**
  String get byPriority;

  /// No description provided for @showCompleted.
  ///
  /// In en, this message translates to:
  /// **'Show completed'**
  String get showCompleted;

  /// No description provided for @hideCompleted.
  ///
  /// In en, this message translates to:
  /// **'Hide completed'**
  String get hideCompleted;

  /// No description provided for @hiddenNow.
  ///
  /// In en, this message translates to:
  /// **'{tasks} hidden now'**
  String hiddenNow(String tasks);

  /// No description provided for @moveUnfinishedTo.
  ///
  /// In en, this message translates to:
  /// **'Move unfinished to {target}'**
  String moveUnfinishedTo(String target);

  /// No description provided for @oneTimeCount.
  ///
  /// In en, this message translates to:
  /// **'{tasks}, one-time'**
  String oneTimeCount(String tasks);

  /// No description provided for @noUnfinishedOneTime.
  ///
  /// In en, this message translates to:
  /// **'No unfinished one-time tasks'**
  String get noUnfinishedOneTime;

  /// No description provided for @swipeDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get swipeDone;

  /// No description provided for @swipeUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get swipeUndo;

  /// No description provided for @chooseWeeklyDay.
  ///
  /// In en, this message translates to:
  /// **'Pick at least one day for the weekly task'**
  String get chooseWeeklyDay;

  /// No description provided for @editTask.
  ///
  /// In en, this message translates to:
  /// **'Edit task'**
  String get editTask;

  /// No description provided for @taskTitleHint.
  ///
  /// In en, this message translates to:
  /// **'What do you want to get done?'**
  String get taskTitleHint;

  /// No description provided for @taskTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter the task name'**
  String get taskTitleRequired;

  /// No description provided for @noteHint.
  ///
  /// In en, this message translates to:
  /// **'Notes or details (optional)'**
  String get noteHint;

  /// No description provided for @addNote.
  ///
  /// In en, this message translates to:
  /// **'Add a note'**
  String get addNote;

  /// No description provided for @taskTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get taskTypeLabel;

  /// No description provided for @startsFrom.
  ///
  /// In en, this message translates to:
  /// **'Starts on'**
  String get startsFrom;

  /// No description provided for @otherDate.
  ///
  /// In en, this message translates to:
  /// **'Another date'**
  String get otherDate;

  /// No description provided for @timeAndReminder.
  ///
  /// In en, this message translates to:
  /// **'Time & reminder'**
  String get timeAndReminder;

  /// No description provided for @noTimeNoReminder.
  ///
  /// In en, this message translates to:
  /// **'No time (no reminder)'**
  String get noTimeNoReminder;

  /// No description provided for @reminderAt.
  ///
  /// In en, this message translates to:
  /// **'Reminder {time}'**
  String reminderAt(String time);

  /// No description provided for @removeTime.
  ///
  /// In en, this message translates to:
  /// **'Remove time'**
  String get removeTime;

  /// No description provided for @priority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get priority;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @addTask.
  ///
  /// In en, this message translates to:
  /// **'Add task'**
  String get addTask;

  /// No description provided for @weekStartsOn.
  ///
  /// In en, this message translates to:
  /// **'Week starts on'**
  String get weekStartsOn;

  /// No description provided for @onceAnyDay.
  ///
  /// In en, this message translates to:
  /// **'Once, on any day of the week'**
  String get onceAnyDay;

  /// No description provided for @availableDays.
  ///
  /// In en, this message translates to:
  /// **'Available days:'**
  String get availableDays;

  /// No description provided for @ifNotDoneRemindMe.
  ///
  /// In en, this message translates to:
  /// **'If it\'s not done, remind me'**
  String get ifNotDoneRemindMe;

  /// No description provided for @setTimeForReminders.
  ///
  /// In en, this message translates to:
  /// **'Set a time for the task to enable reminders.'**
  String get setTimeForReminders;

  /// No description provided for @goalAchievedSnack.
  ///
  /// In en, this message translates to:
  /// **'You achieved one of this year\'s goals! 🏆 We\'re proud of you'**
  String get goalAchievedSnack;

  /// No description provided for @deleteGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete goal?'**
  String get deleteGoalTitle;

  /// No description provided for @deleteGoalMessage.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" will be deleted.'**
  String deleteGoalMessage(String title);

  /// No description provided for @newGoal.
  ///
  /// In en, this message translates to:
  /// **'New goal'**
  String get newGoal;

  /// No description provided for @yearGoals.
  ///
  /// In en, this message translates to:
  /// **'This year\'s goals'**
  String get yearGoals;

  /// No description provided for @goalsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'What do you most want to achieve this year?'**
  String get goalsEmptyTitle;

  /// No description provided for @goalsEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Write only 3 to 5 goals and add your reason for each. We\'ll remind you of them every week.'**
  String get goalsEmptyMessage;

  /// No description provided for @quickSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Quick suggestions'**
  String get quickSuggestions;

  /// No description provided for @yourGoals.
  ///
  /// In en, this message translates to:
  /// **'Your goals'**
  String get yourGoals;

  /// No description provided for @goalsHeroStart.
  ///
  /// In en, this message translates to:
  /// **'Start your year with clarity'**
  String get goalsHeroStart;

  /// No description provided for @goalsHeroDone.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} achieved'**
  String goalsHeroDone(int done, int total);

  /// No description provided for @goalsHeroWritten.
  ///
  /// In en, this message translates to:
  /// **'Written goals are closer to coming true.'**
  String get goalsHeroWritten;

  /// No description provided for @yearElapsed.
  ///
  /// In en, this message translates to:
  /// **'{percent}% of {year} has passed'**
  String yearElapsed(int percent, int year);

  /// No description provided for @daysLeftInYear.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{1 day left} other{{days} days left}}'**
  String daysLeftInYear(int days);

  /// No description provided for @goalMarkAchieved.
  ///
  /// In en, this message translates to:
  /// **'Mark achieved'**
  String get goalMarkAchieved;

  /// No description provided for @goalUnmark.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get goalUnmark;

  /// No description provided for @decrease.
  ///
  /// In en, this message translates to:
  /// **'Decrease'**
  String get decrease;

  /// No description provided for @increase.
  ///
  /// In en, this message translates to:
  /// **'Increase'**
  String get increase;

  /// No description provided for @suggestionBooks.
  ///
  /// In en, this message translates to:
  /// **'Read 12 books'**
  String get suggestionBooks;

  /// No description provided for @suggestionBooksUnit.
  ///
  /// In en, this message translates to:
  /// **'books'**
  String get suggestionBooksUnit;

  /// No description provided for @suggestionFitness.
  ///
  /// In en, this message translates to:
  /// **'Exercise regularly'**
  String get suggestionFitness;

  /// No description provided for @suggestionFitnessUnit.
  ///
  /// In en, this message translates to:
  /// **'workouts'**
  String get suggestionFitnessUnit;

  /// No description provided for @suggestionMoney.
  ///
  /// In en, this message translates to:
  /// **'Save an emergency fund'**
  String get suggestionMoney;

  /// No description provided for @suggestionLanguage.
  ///
  /// In en, this message translates to:
  /// **'Learn a new language'**
  String get suggestionLanguage;

  /// No description provided for @suggestionStudy.
  ///
  /// In en, this message translates to:
  /// **'Finish a professional course'**
  String get suggestionStudy;

  /// No description provided for @suggestionFaith.
  ///
  /// In en, this message translates to:
  /// **'Memorize a part of the Quran'**
  String get suggestionFaith;

  /// No description provided for @suggestionTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel somewhere new'**
  String get suggestionTravel;

  /// No description provided for @suggestionCode.
  ///
  /// In en, this message translates to:
  /// **'Build a side project'**
  String get suggestionCode;

  /// No description provided for @newGoalForYear.
  ///
  /// In en, this message translates to:
  /// **'New goal for {year}'**
  String newGoalForYear(int year);

  /// No description provided for @editGoal.
  ///
  /// In en, this message translates to:
  /// **'Edit goal'**
  String get editGoal;

  /// No description provided for @goalTitleHint.
  ///
  /// In en, this message translates to:
  /// **'What do you want to achieve this year?'**
  String get goalTitleHint;

  /// No description provided for @goalTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter the goal'**
  String get goalTitleRequired;

  /// No description provided for @goalWhyHint.
  ///
  /// In en, this message translates to:
  /// **'Why does this goal matter to you? (We\'ll remind you when you slow down)'**
  String get goalWhyHint;

  /// No description provided for @goalIcon.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get goalIcon;

  /// No description provided for @numericGoal.
  ///
  /// In en, this message translates to:
  /// **'Measurable numeric goal'**
  String get numericGoal;

  /// No description provided for @numericGoalExample.
  ///
  /// In en, this message translates to:
  /// **'e.g. 12 books, 100 workouts'**
  String get numericGoalExample;

  /// No description provided for @goalTargetHint.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get goalTargetHint;

  /// No description provided for @wholeNumber.
  ///
  /// In en, this message translates to:
  /// **'Whole number'**
  String get wholeNumber;

  /// No description provided for @goalUnitHint.
  ///
  /// In en, this message translates to:
  /// **'Unit (books, km...)'**
  String get goalUnitHint;

  /// No description provided for @addGoal.
  ///
  /// In en, this message translates to:
  /// **'Add goal'**
  String get addGoal;

  /// No description provided for @deletedFromHistory.
  ///
  /// In en, this message translates to:
  /// **'Removed from history'**
  String get deletedFromHistory;

  /// No description provided for @deleteTaskCompletionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all of this task\'s completions?'**
  String get deleteTaskCompletionsTitle;

  /// No description provided for @deleteTaskCompletionsMessage.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 completion} other{{count} completions}} of \"{title}\" will be deleted from history and counters. The task itself won\'t be deleted.'**
  String deleteTaskCompletionsMessage(int count, String title);

  /// No description provided for @deletedCompletions.
  ///
  /// In en, this message translates to:
  /// **'Deleted {count, plural, =1{1 completion} other{{count} completions}}'**
  String deletedCompletions(int count);

  /// No description provided for @clearHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear all history?'**
  String get clearHistoryTitle;

  /// No description provided for @clearHistoryMessage.
  ///
  /// In en, this message translates to:
  /// **'All completions ({count}), counters and streaks will be deleted. Your tasks themselves won\'t be deleted.'**
  String clearHistoryMessage(int count);

  /// No description provided for @historyCleared.
  ///
  /// In en, this message translates to:
  /// **'History cleared'**
  String get historyCleared;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'History & stats'**
  String get historyTitle;

  /// No description provided for @historyOptions.
  ///
  /// In en, this message translates to:
  /// **'History options'**
  String get historyOptions;

  /// No description provided for @clearHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear all history'**
  String get clearHistory;

  /// No description provided for @totalCompletions.
  ///
  /// In en, this message translates to:
  /// **'Total completions'**
  String get totalCompletions;

  /// No description provided for @weekAndMonthCompletions.
  ///
  /// In en, this message translates to:
  /// **'This week {week} • This month {month}'**
  String weekAndMonthCompletions(int week, int month);

  /// No description provided for @streakDays.
  ///
  /// In en, this message translates to:
  /// **'Day streak'**
  String get streakDays;

  /// No description provided for @bestStreak.
  ///
  /// In en, this message translates to:
  /// **'Best: {count}'**
  String bestStreak(int count);

  /// No description provided for @countByType.
  ///
  /// In en, this message translates to:
  /// **'Completions by type'**
  String get countByType;

  /// No description provided for @typeTasks.
  ///
  /// In en, this message translates to:
  /// **'{type} tasks'**
  String typeTasks(String type);

  /// No description provided for @last7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get last7Days;

  /// No description provided for @mostCompleted.
  ///
  /// In en, this message translates to:
  /// **'Most completed'**
  String get mostCompleted;

  /// No description provided for @completionLog.
  ///
  /// In en, this message translates to:
  /// **'Completion log'**
  String get completionLog;

  /// No description provided for @tapToDelete.
  ///
  /// In en, this message translates to:
  /// **'Tap an entry to delete it'**
  String get tapToDelete;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All ({count})'**
  String filterAll(int count);

  /// No description provided for @noCompletionsTitle.
  ///
  /// In en, this message translates to:
  /// **'No completions yet'**
  String get noCompletionsTitle;

  /// No description provided for @noCompletionsMessage.
  ///
  /// In en, this message translates to:
  /// **'Every task you finish is logged here with its time, and the log is kept even if you delete the task.'**
  String get noCompletionsMessage;

  /// No description provided for @completedAt.
  ///
  /// In en, this message translates to:
  /// **'Completed {date} • {time}'**
  String completedAt(String date, String time);

  /// No description provided for @deleteThisCompletion.
  ///
  /// In en, this message translates to:
  /// **'Delete this entry from history'**
  String get deleteThisCompletion;

  /// No description provided for @deleteAllTaskCompletions.
  ///
  /// In en, this message translates to:
  /// **'Delete all of this task\'s completions ({count})'**
  String deleteAllTaskCompletions(int count);

  /// No description provided for @forDay.
  ///
  /// In en, this message translates to:
  /// **'for {date}'**
  String forDay(String date);

  /// No description provided for @dailyLimitFor.
  ///
  /// In en, this message translates to:
  /// **'Daily limit for {app}'**
  String dailyLimitFor(String app);

  /// No description provided for @noLimit.
  ///
  /// In en, this message translates to:
  /// **'No limit'**
  String get noLimit;

  /// No description provided for @notSupportedTitle.
  ///
  /// In en, this message translates to:
  /// **'Not supported'**
  String get notSupportedTitle;

  /// No description provided for @notSupportedMessage.
  ///
  /// In en, this message translates to:
  /// **'Screen time is only available on Android.'**
  String get notSupportedMessage;

  /// No description provided for @usageAccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Access to usage data'**
  String get usageAccessTitle;

  /// No description provided for @noThanks.
  ///
  /// In en, this message translates to:
  /// **'No, thanks'**
  String get noThanks;

  /// No description provided for @agreeContinue.
  ///
  /// In en, this message translates to:
  /// **'Agree and continue'**
  String get agreeContinue;

  /// No description provided for @screenTimeIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'See where your time goes'**
  String get screenTimeIntroTitle;

  /// No description provided for @screenTimeIntroMessage.
  ///
  /// In en, this message translates to:
  /// **'See how long your screen is on, how often you unlock, and the time spent in each app.'**
  String get screenTimeIntroMessage;

  /// No description provided for @screenTimePoint1.
  ///
  /// In en, this message translates to:
  /// **'Total screen time per day and week'**
  String get screenTimePoint1;

  /// No description provided for @screenTimePoint2.
  ///
  /// In en, this message translates to:
  /// **'Apps ranked by usage'**
  String get screenTimePoint2;

  /// No description provided for @screenTimePoint3.
  ///
  /// In en, this message translates to:
  /// **'Track chosen apps with a daily limit'**
  String get screenTimePoint3;

  /// No description provided for @screenTimePoint4.
  ///
  /// In en, this message translates to:
  /// **'Data stays on your phone and is never sent anywhere'**
  String get screenTimePoint4;

  /// No description provided for @screenTimeGrantHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the button, turn on \"Mongez\" in the \"Usage access\" list, then come back to the app.'**
  String get screenTimeGrantHint;

  /// No description provided for @grantUsageAccess.
  ///
  /// In en, this message translates to:
  /// **'Grant usage access'**
  String get grantUsageAccess;

  /// No description provided for @restrictedTitle.
  ///
  /// In en, this message translates to:
  /// **'Is the allow switch grey and not working?'**
  String get restrictedTitle;

  /// No description provided for @restrictedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'It says \"Controlled by restricted setting\" below it'**
  String get restrictedSubtitle;

  /// No description provided for @restrictedIntro.
  ///
  /// In en, this message translates to:
  /// **'Android locks this permission for apps installed from an APK file. Unlock it once like this:'**
  String get restrictedIntro;

  /// No description provided for @restrictedStep1.
  ///
  /// In en, this message translates to:
  /// **'Tap the grey allow switch once until the blocked message appears, then close it.'**
  String get restrictedStep1;

  /// No description provided for @restrictedStep2.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Open app info\" below.'**
  String get restrictedStep2;

  /// No description provided for @restrictedStep3.
  ///
  /// In en, this message translates to:
  /// **'Tap the three dots ⋮ at the top, then \"Allow restricted settings\", and confirm with your fingerprint or screen lock.'**
  String get restrictedStep3;

  /// No description provided for @restrictedStep4.
  ///
  /// In en, this message translates to:
  /// **'Come back here and tap \"Grant usage access\".'**
  String get restrictedStep4;

  /// No description provided for @restrictedNote.
  ///
  /// In en, this message translates to:
  /// **'The three dots only appear after step 1.'**
  String get restrictedNote;

  /// No description provided for @openAppInfo.
  ///
  /// In en, this message translates to:
  /// **'Open app info'**
  String get openAppInfo;

  /// No description provided for @screenOnTime.
  ///
  /// In en, this message translates to:
  /// **'Screen-on time'**
  String get screenOnTime;

  /// No description provided for @unlocksCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 unlock} other{{count} unlocks}}'**
  String unlocksCount(int count);

  /// No description provided for @appsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 app} other{{count} apps}}'**
  String appsCount(int count);

  /// No description provided for @belowAverage.
  ///
  /// In en, this message translates to:
  /// **'{duration} below your average'**
  String belowAverage(String duration);

  /// No description provided for @aboveAverage.
  ///
  /// In en, this message translates to:
  /// **'{duration} above your average'**
  String aboveAverage(String duration);

  /// No description provided for @averageLabel.
  ///
  /// In en, this message translates to:
  /// **'Average {duration}'**
  String averageLabel(String duration);

  /// No description provided for @trackedApps.
  ///
  /// In en, this message translates to:
  /// **'Apps I track'**
  String get trackedApps;

  /// No description provided for @durationToday.
  ///
  /// In en, this message translates to:
  /// **'{duration} today'**
  String durationToday(String duration);

  /// No description provided for @usageOfLimit.
  ///
  /// In en, this message translates to:
  /// **'{used} of {limit}'**
  String usageOfLimit(String used, String limit);

  /// No description provided for @overLimit.
  ///
  /// In en, this message translates to:
  /// **' — over the limit!'**
  String get overLimit;

  /// No description provided for @editDailyLimit.
  ///
  /// In en, this message translates to:
  /// **'Edit daily limit'**
  String get editDailyLimit;

  /// No description provided for @stopTracking.
  ///
  /// In en, this message translates to:
  /// **'Stop tracking'**
  String get stopTracking;

  /// No description provided for @mostUsedApps.
  ///
  /// In en, this message translates to:
  /// **'Most used apps'**
  String get mostUsedApps;

  /// No description provided for @tapToTrack.
  ///
  /// In en, this message translates to:
  /// **'Tap to track an app'**
  String get tapToTrack;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @noDataForDay.
  ///
  /// In en, this message translates to:
  /// **'No data for this day.'**
  String get noDataForDay;

  /// No description provided for @notificationsEnabledUpdated.
  ///
  /// In en, this message translates to:
  /// **'Notifications are on and reminders were updated'**
  String get notificationsEnabledUpdated;

  /// No description provided for @notificationsNotGranted.
  ///
  /// In en, this message translates to:
  /// **'Notification permission wasn\'t granted'**
  String get notificationsNotGranted;

  /// No description provided for @backupSaved.
  ///
  /// In en, this message translates to:
  /// **'Backup saved'**
  String get backupSaved;

  /// No description provided for @backupSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save the backup: {error}'**
  String backupSaveFailed(String error);

  /// No description provided for @fileReadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t read the file'**
  String get fileReadFailed;

  /// No description provided for @restoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore backup?'**
  String get restoreTitle;

  /// No description provided for @restoreMessage.
  ///
  /// In en, this message translates to:
  /// **'Your current tasks ({tasks}) and goals ({goals}) will be replaced. History won\'t be deleted; the backup\'s entries ({history}) will be merged into it.'**
  String restoreMessage(int tasks, int goals, int history);

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @restoreDone.
  ///
  /// In en, this message translates to:
  /// **'Restored successfully'**
  String get restoreDone;

  /// No description provided for @widgetPinRequested.
  ///
  /// In en, this message translates to:
  /// **'Request sent to add the widget to the home screen'**
  String get widgetPinRequested;

  /// No description provided for @widgetPinUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Your launcher doesn\'t support adding widgets automatically. Add it manually from the widgets list.'**
  String get widgetPinUnsupported;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @colorTheme.
  ///
  /// In en, this message translates to:
  /// **'Color theme'**
  String get colorTheme;

  /// No description provided for @amoledTitle.
  ///
  /// In en, this message translates to:
  /// **'Pure black (AMOLED)'**
  String get amoledTitle;

  /// No description provided for @amoledSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Saves battery on OLED screens'**
  String get amoledSubtitle;

  /// No description provided for @appBackground.
  ///
  /// In en, this message translates to:
  /// **'App background'**
  String get appBackground;

  /// No description provided for @imagePickFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t pick the image'**
  String get imagePickFailed;

  /// No description provided for @dimImage.
  ///
  /// In en, this message translates to:
  /// **'Dim the photo so text stays readable'**
  String get dimImage;

  /// No description provided for @changeImage.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get changeImage;

  /// No description provided for @tasksAndWeek.
  ///
  /// In en, this message translates to:
  /// **'Tasks & week'**
  String get tasksAndWeek;

  /// No description provided for @firstDayOfWeek.
  ///
  /// In en, this message translates to:
  /// **'First day of the week'**
  String get firstDayOfWeek;

  /// No description provided for @firstDayOfWeekSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sets the start of the week for weekly tasks and stats'**
  String get firstDayOfWeekSubtitle;

  /// No description provided for @startDayTitle.
  ///
  /// In en, this message translates to:
  /// **'Day shown when the app opens'**
  String get startDayTitle;

  /// No description provided for @startDayAutoHint.
  ///
  /// In en, this message translates to:
  /// **'Auto: today during the day, tomorrow after 7 PM for planning.'**
  String get startDayAutoHint;

  /// No description provided for @hideCompletedTasks.
  ///
  /// In en, this message translates to:
  /// **'Hide completed tasks'**
  String get hideCompletedTasks;

  /// No description provided for @celebrateTitle.
  ///
  /// In en, this message translates to:
  /// **'Celebrations & sounds'**
  String get celebrateTitle;

  /// No description provided for @celebrateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A sound for each finished task, and a celebration when you finish the day\'s tasks or achieve a goal'**
  String get celebrateSubtitle;

  /// No description provided for @reminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminders;

  /// No description provided for @notificationsEnabled.
  ///
  /// In en, this message translates to:
  /// **'Notifications are on'**
  String get notificationsEnabled;

  /// No description provided for @notificationsDisabled.
  ///
  /// In en, this message translates to:
  /// **'Notifications are off'**
  String get notificationsDisabled;

  /// No description provided for @notificationsTapToGrant.
  ///
  /// In en, this message translates to:
  /// **'Tap to grant permissions and update reminders'**
  String get notificationsTapToGrant;

  /// No description provided for @followUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Remind me again if I haven\'t finished'**
  String get followUpTitle;

  /// No description provided for @followUpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{duration} after the task time'**
  String followUpSubtitle(String duration);

  /// No description provided for @planningTitle.
  ///
  /// In en, this message translates to:
  /// **'Evening reminder to plan tomorrow'**
  String get planningTitle;

  /// No description provided for @planningSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Daily at {time}'**
  String planningSubtitle(String time);

  /// No description provided for @changeTime.
  ///
  /// In en, this message translates to:
  /// **'Change time'**
  String get changeTime;

  /// No description provided for @goalsReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly motivation from this year\'s goals'**
  String get goalsReminderTitle;

  /// No description provided for @goalsReminderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Every Friday at 10 AM'**
  String get goalsReminderSubtitle;

  /// No description provided for @homeWidgets.
  ///
  /// In en, this message translates to:
  /// **'Home screen widgets'**
  String get homeWidgets;

  /// No description provided for @todayWidget.
  ///
  /// In en, this message translates to:
  /// **'Today\'s tasks widget'**
  String get todayWidget;

  /// No description provided for @todayWidgetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Task list with progress and one-tap completion'**
  String get todayWidgetSubtitle;

  /// No description provided for @summaryWidget.
  ///
  /// In en, this message translates to:
  /// **'Summary widget'**
  String get summaryWidget;

  /// No description provided for @summaryWidgetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Completion rate and the next task'**
  String get summaryWidgetSubtitle;

  /// No description provided for @refreshWidgetNow.
  ///
  /// In en, this message translates to:
  /// **'Refresh widgets now'**
  String get refreshWidgetNow;

  /// No description provided for @widgetRefreshed.
  ///
  /// In en, this message translates to:
  /// **'Widgets refreshed'**
  String get widgetRefreshed;

  /// No description provided for @data.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get data;

  /// No description provided for @saveBackup.
  ///
  /// In en, this message translates to:
  /// **'Save a backup'**
  String get saveBackup;

  /// No description provided for @saveBackupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tasks, goals and history in one file'**
  String get saveBackupSubtitle;

  /// No description provided for @restoreFromBackup.
  ///
  /// In en, this message translates to:
  /// **'Restore from a backup'**
  String get restoreFromBackup;

  /// No description provided for @restoreFromBackupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'History is merged, never deleted'**
  String get restoreFromBackupSubtitle;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @versionOffline.
  ///
  /// In en, this message translates to:
  /// **'Version {version} • Works offline'**
  String versionOffline(String version);

  /// No description provided for @backupDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Save a backup'**
  String get backupDialogTitle;

  /// No description provided for @backupPickTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the backup file'**
  String get backupPickTitle;

  /// No description provided for @backupInvalid.
  ///
  /// In en, this message translates to:
  /// **'This file isn\'t a valid backup'**
  String get backupInvalid;

  /// No description provided for @backupNotMongez.
  ///
  /// In en, this message translates to:
  /// **'This file isn\'t a Mongez backup'**
  String get backupNotMongez;

  /// No description provided for @channelTasks.
  ///
  /// In en, this message translates to:
  /// **'Task reminders'**
  String get channelTasks;

  /// No description provided for @channelTasksDescription.
  ///
  /// In en, this message translates to:
  /// **'Alert at the task\'s time'**
  String get channelTasksDescription;

  /// No description provided for @channelFollowUp.
  ///
  /// In en, this message translates to:
  /// **'Unfinished task follow-ups'**
  String get channelFollowUp;

  /// No description provided for @channelFollowUpDescription.
  ///
  /// In en, this message translates to:
  /// **'An extra reminder if a task isn\'t done after its time'**
  String get channelFollowUpDescription;

  /// No description provided for @channelPlanning.
  ///
  /// In en, this message translates to:
  /// **'Plan tomorrow'**
  String get channelPlanning;

  /// No description provided for @channelPlanningDescription.
  ///
  /// In en, this message translates to:
  /// **'Evening reminder to plan tomorrow\'s tasks'**
  String get channelPlanningDescription;

  /// No description provided for @channelGoals.
  ///
  /// In en, this message translates to:
  /// **'Goal motivation'**
  String get channelGoals;

  /// No description provided for @channelGoalsDescription.
  ///
  /// In en, this message translates to:
  /// **'Weekly reminder of this year\'s goals'**
  String get channelGoalsDescription;

  /// No description provided for @notifTaskNormal.
  ///
  /// In en, this message translates to:
  /// **'Time for your task'**
  String get notifTaskNormal;

  /// No description provided for @notifTaskDaily.
  ///
  /// In en, this message translates to:
  /// **'Your daily task'**
  String get notifTaskDaily;

  /// No description provided for @notifTaskWeekly.
  ///
  /// In en, this message translates to:
  /// **'This week\'s task isn\'t done yet'**
  String get notifTaskWeekly;

  /// No description provided for @notifFollowUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Not done yet ⏳'**
  String get notifFollowUpTitle;

  /// No description provided for @notifFollowUpBody.
  ///
  /// In en, this message translates to:
  /// **'{title} — there\'s still time, start now.'**
  String notifFollowUpBody(String title);

  /// No description provided for @notifPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan your tomorrow 🌙'**
  String get notifPlanTitle;

  /// No description provided for @notifPlanEmpty.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t added tasks for tomorrow yet. Two minutes now saves you a scattered day.'**
  String get notifPlanEmpty;

  /// No description provided for @notifPlanCount.
  ///
  /// In en, this message translates to:
  /// **'You have {count, plural, =1{1 task} other{{count} tasks}} for tomorrow. Review them and set your priorities.'**
  String notifPlanCount(int count);

  /// No description provided for @notifGoalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your goals for {year} 🎯'**
  String notifGoalsTitle(int year);

  /// No description provided for @notifGoalsAllDone.
  ///
  /// In en, this message translates to:
  /// **'You achieved all your goals ({done}/{total})! {quote}'**
  String notifGoalsAllDone(int done, int total, String quote);

  /// No description provided for @notifGoalsFocus.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} achieved. This week, focus on: {goal}\n{quote}'**
  String notifGoalsFocus(int done, int total, String goal, String quote);

  /// No description provided for @notifDoneAction.
  ///
  /// In en, this message translates to:
  /// **'Done ✓'**
  String get notifDoneAction;

  /// No description provided for @widgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s tasks'**
  String get widgetTitle;

  /// No description provided for @widgetNoTasks.
  ///
  /// In en, this message translates to:
  /// **'No tasks'**
  String get widgetNoTasks;

  /// No description provided for @widgetEmptyDay.
  ///
  /// In en, this message translates to:
  /// **'Your day is empty'**
  String get widgetEmptyDay;

  /// No description provided for @widgetAllDone.
  ///
  /// In en, this message translates to:
  /// **'All done 🎉'**
  String get widgetAllDone;

  /// No description provided for @widgetNoTasksToday.
  ///
  /// In en, this message translates to:
  /// **'No tasks today'**
  String get widgetNoTasksToday;

  /// No description provided for @widgetDoneOf.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} done'**
  String widgetDoneOf(int done, int total);

  /// No description provided for @widgetNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get widgetNext;

  /// No description provided for @widgetEmptyList.
  ///
  /// In en, this message translates to:
  /// **'No tasks today — tap + to add one'**
  String get widgetEmptyList;

  /// No description provided for @widgetAddTask.
  ///
  /// In en, this message translates to:
  /// **'Add task'**
  String get widgetAddTask;

  /// No description provided for @widgetOpenApp.
  ///
  /// In en, this message translates to:
  /// **'Open Mongez'**
  String get widgetOpenApp;

  /// No description provided for @usageAccessDisclosure.
  ///
  /// In en, this message translates to:
  /// **'To show screen time, Mongez reads your phone\'s usage data from Android: the apps you open, how long each app is used, how long the screen is on, and how many times you unlock it.\n\nThis data is read only while you have the app open (never in the background), is shown to you on the \"Screen time\" tab, and stays on your device: it is not sent, sold or shared with anyone. The app doesn\'t connect to the internet at all.\n\nYou can revoke the permission at any time in your phone\'s settings.'**
  String get usageAccessDisclosure;

  /// No description provided for @privacySummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get privacySummaryTitle;

  /// No description provided for @privacySummaryBody.
  ///
  /// In en, this message translates to:
  /// **'Mongez works entirely on your phone. There is no account, no ads, and no tracking or analytics tools, and the app doesn\'t have permission to connect to the internet. We don\'t collect or receive any data about you.'**
  String get privacySummaryBody;

  /// No description provided for @privacyStoredTitle.
  ///
  /// In en, this message translates to:
  /// **'Data stored on your device'**
  String get privacyStoredTitle;

  /// No description provided for @privacyStoredBody.
  ///
  /// In en, this message translates to:
  /// **'Your tasks and their notes, your completion history, your goals, app settings, the list of apps you chose to track with their daily limits, and the background photo if you picked one. All of it is kept in the app\'s private storage on your phone only.'**
  String get privacyStoredBody;

  /// No description provided for @privacyUsageTitle.
  ///
  /// In en, this message translates to:
  /// **'Phone usage data (Screen time)'**
  String get privacyUsageTitle;

  /// No description provided for @privacyUsageIntro.
  ///
  /// In en, this message translates to:
  /// **'This feature is optional and only works if you grant the app \"Usage access\" yourself in your phone\'s settings.'**
  String get privacyUsageIntro;

  /// No description provided for @privacyPermissionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Other permissions'**
  String get privacyPermissionsTitle;

  /// No description provided for @privacyPermissionsBody.
  ///
  /// In en, this message translates to:
  /// **'• Notifications, alarms & reminders: to show task reminders on time.\n• Run at startup: to reschedule reminders after the phone restarts.\n• Vibrate: with reminders.\n• Photos: the app doesn\'t request photo access; when you pick a background, the system photo picker opens and the app receives only the photo you choose.'**
  String get privacyPermissionsBody;

  /// No description provided for @privacyBackupTitle.
  ///
  /// In en, this message translates to:
  /// **'Backups'**
  String get privacyBackupTitle;

  /// No description provided for @privacyBackupBody.
  ///
  /// In en, this message translates to:
  /// **'When you export a backup, a file is created where you choose, and you control it. Android may include the app\'s data in your Google account\'s backup if that is turned on on your phone; that is governed by your phone\'s settings and Google\'s policy.'**
  String get privacyBackupBody;

  /// No description provided for @privacyDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Deleting your data'**
  String get privacyDeleteTitle;

  /// No description provided for @privacyDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'You can delete tasks and history inside the app. To delete everything, clear the app\'s data in your phone\'s settings or uninstall the app.'**
  String get privacyDeleteBody;

  /// No description provided for @privacyChildrenTitle.
  ///
  /// In en, this message translates to:
  /// **'Children'**
  String get privacyChildrenTitle;

  /// No description provided for @privacyChildrenBody.
  ///
  /// In en, this message translates to:
  /// **'The app is a general organizing tool, isn\'t directed at children, and collects no data from any user.'**
  String get privacyChildrenBody;

  /// No description provided for @privacyChangesTitle.
  ///
  /// In en, this message translates to:
  /// **'Changes and contact'**
  String get privacyChangesTitle;

  /// No description provided for @privacyChangesBody.
  ///
  /// In en, this message translates to:
  /// **'Any change to this policy is published with an app update and on the project page. The app is open source; for questions, you can open an issue on the project\'s GitHub page.\n\nLast updated: November 10, 2026'**
  String get privacyChangesBody;

  /// No description provided for @privacyWebVersion.
  ///
  /// In en, this message translates to:
  /// **'Web version (English / عربي)'**
  String get privacyWebVersion;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

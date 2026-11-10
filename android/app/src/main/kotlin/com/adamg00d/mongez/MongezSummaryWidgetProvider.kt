package com.adamg00d.mongez

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

/** Compact widget: today's completion percentage and the next task. */
class MongezSummaryWidgetProvider : HomeWidgetProvider() {
  override fun onUpdate(
      context: Context,
      appWidgetManager: AppWidgetManager,
      appWidgetIds: IntArray,
      widgetData: SharedPreferences,
  ) {
    WidgetCommon.refreshIfStale(context, widgetData)
    val done = WidgetCommon.int(widgetData, "widget_done_count")
    val total = WidgetCommon.int(widgetData, "widget_total_count")
    val progress = WidgetCommon.int(widgetData, "widget_progress")
    val nextTitle = WidgetCommon.string(widgetData, "widget_next_title", "افتح مُنجز")
    val nextTime = WidgetCommon.string(widgetData, "widget_next_time")
    val allDone = total > 0 && done == total

    appWidgetIds.forEach { widgetId ->
      val views = RemoteViews(context.packageName, R.layout.mongez_summary_widget)
      views.setOnClickPendingIntent(R.id.summary_root, WidgetCommon.openApp(context))
      views.setOnClickPendingIntent(R.id.summary_add, WidgetCommon.addTask(context))
      views.setTextViewText(R.id.summary_percent, "$progress%")
      views.setTextViewText(
          R.id.summary_counter,
          if (total == 0) "لا مهام اليوم" else "أنجزت $done من $total")
      views.setProgressBar(R.id.summary_progress, 100, progress, false)
      views.setViewVisibility(
          R.id.summary_next_label, if (total == 0 || allDone) View.GONE else View.VISIBLE)
      views.setTextViewText(
          R.id.summary_next, if (nextTime.isNotEmpty()) "$nextTitle • $nextTime" else nextTitle)
      appWidgetManager.updateAppWidget(widgetId, views)
    }
  }
}

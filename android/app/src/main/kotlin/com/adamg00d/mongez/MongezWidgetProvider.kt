package com.adamg00d.mongez

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.net.Uri
import android.os.Build
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

/** Today's task list with one-tap completion. */
class MongezWidgetProvider : HomeWidgetProvider() {
  override fun onUpdate(
      context: Context,
      appWidgetManager: AppWidgetManager,
      appWidgetIds: IntArray,
      widgetData: SharedPreferences,
  ) {
    WidgetCommon.refreshIfStale(context, widgetData)
    appWidgetManager.notifyAppWidgetViewDataChanged(appWidgetIds, R.id.widget_task_list)

    appWidgetIds.forEach { widgetId ->
      val views = RemoteViews(context.packageName, R.layout.mongez_widget)
      try {
        val open = WidgetCommon.openApp(context)
        views.setOnClickPendingIntent(R.id.widget_header, open)
        views.setOnClickPendingIntent(R.id.widget_empty, open)
        views.setOnClickPendingIntent(R.id.widget_add, WidgetCommon.addTask(context))

        views.setTextViewText(
            R.id.widget_title, WidgetCommon.string(widgetData, "widget_title", "مهام اليوم"))
        views.setTextViewText(
            R.id.widget_subtitle, WidgetCommon.string(widgetData, "widget_subtitle"))
        views.setTextViewText(
            R.id.widget_counter, WidgetCommon.string(widgetData, "widget_counter", "0/0"))
        val total = WidgetCommon.int(widgetData, "widget_total_count")
        views.setProgressBar(
            R.id.widget_progress, 100, WidgetCommon.int(widgetData, "widget_progress"), false)
        views.setViewVisibility(R.id.widget_progress, if (total == 0) View.GONE else View.VISIBLE)

        val serviceIntent =
            Intent(context, MongezWidgetService::class.java).apply {
              putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, widgetId)
              data = Uri.parse(toUri(Intent.URI_INTENT_SCHEME))
            }
        views.setRemoteAdapter(R.id.widget_task_list, serviceIntent)
        views.setEmptyView(R.id.widget_task_list, R.id.widget_empty)
        views.setPendingIntentTemplate(R.id.widget_task_list, toggleTemplate(context))
      } catch (_: Exception) {
        // Fall back to the static layout rather than a broken widget.
      }
      appWidgetManager.updateAppWidget(widgetId, views)
    }
  }

  private fun toggleTemplate(context: Context): PendingIntent {
    val intent =
        Intent(context, MongezWidgetBackgroundReceiver::class.java).apply {
          action = "es.antonborri.home_widget.action.BACKGROUND"
        }
    var flags = PendingIntent.FLAG_UPDATE_CURRENT
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
      flags = flags or PendingIntent.FLAG_MUTABLE
    }
    return PendingIntent.getBroadcast(context, 9041, intent, flags)
  }
}

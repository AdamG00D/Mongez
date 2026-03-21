package com.adamg00d.mongez

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Build
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class MongezWidgetProvider : HomeWidgetProvider() {
  override fun onUpdate(
      context: Context,
      appWidgetManager: AppWidgetManager,
      appWidgetIds: IntArray,
      widgetData: SharedPreferences,
  ) {
    appWidgetManager.notifyAppWidgetViewDataChanged(appWidgetIds, R.id.widget_task_list)

    appWidgetIds.forEach { widgetId ->
      try {
        val views = RemoteViews(context.packageName, R.layout.mongez_widget).apply {
          val launchIntent = HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
          setOnClickPendingIntent(R.id.widget_title, launchIntent)
          setOnClickPendingIntent(R.id.widget_subtitle, launchIntent)
          setOnClickPendingIntent(R.id.widget_brand, launchIntent)

          val title = widgetData.getString("widget_title", "مهام اليوم")
          val subtitle = widgetData.getString("widget_subtitle", "")
          setTextViewText(R.id.widget_title, title)
          setTextViewText(R.id.widget_subtitle, subtitle)

          val serviceIntent =
              Intent(context, MongezWidgetService::class.java).apply {
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, widgetId)
                data = android.net.Uri.parse(toUri(Intent.URI_INTENT_SCHEME))
              }

          setRemoteAdapter(R.id.widget_task_list, serviceIntent)
          setEmptyView(R.id.widget_task_list, R.id.widget_empty)
          setPendingIntentTemplate(R.id.widget_task_list, backgroundTemplate(context))
        }

        appWidgetManager.updateAppWidget(widgetId, views)
      } catch (_: Exception) {
        val fallback = RemoteViews(context.packageName, R.layout.mongez_widget)
        appWidgetManager.updateAppWidget(widgetId, fallback)
      }
    }
  }

  private fun backgroundTemplate(context: Context): PendingIntent {
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

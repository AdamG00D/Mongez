package com.adamg00d.mongez

import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

internal object WidgetCommon {
  private const val REFRESH_THROTTLE_MS = 10L * 60 * 1000
  private const val LAST_REFRESH_KEY = "mongez_last_day_refresh"

  fun todayKey(): String = SimpleDateFormat("yyyy-MM-dd", Locale.US).format(Date())

  fun int(prefs: SharedPreferences, key: String, fallback: Int = 0): Int =
      (prefs.all[key] as? Number)?.toInt() ?: fallback

  fun string(prefs: SharedPreferences, key: String, fallback: String = ""): String =
      prefs.getString(key, fallback) ?: fallback

  fun openApp(context: Context) =
      HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java, Uri.parse("mongez://open"))

  fun addTask(context: Context) =
      HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java, Uri.parse("mongez://add"))

  /**
   * The widget data is computed by Dart for a specific day. After midnight it
   * is stale, so ask the Dart background callback to recompute it.
   */
  fun refreshIfStale(context: Context, prefs: SharedPreferences): Boolean {
    val stored = prefs.getString("widget_date_key", null)
    if (stored == todayKey()) return false
    val now = System.currentTimeMillis()
    val internal = context.getSharedPreferences("MongezWidgetInternal", Context.MODE_PRIVATE)
    if (now - internal.getLong(LAST_REFRESH_KEY, 0L) < REFRESH_THROTTLE_MS) return true
    internal.edit().putLong(LAST_REFRESH_KEY, now).apply()
    try {
      MongezWidgetBackgroundReceiver.dispatch(context, Uri.parse("mongez://refresh?action=refresh"))
    } catch (_: Exception) {}
    return true
  }
}

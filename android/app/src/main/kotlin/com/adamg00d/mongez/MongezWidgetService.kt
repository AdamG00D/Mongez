package com.adamg00d.mongez

import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.Paint
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import es.antonborri.home_widget.HomeWidgetPlugin
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import org.json.JSONArray

class MongezWidgetService : RemoteViewsService() {
  override fun onGetViewFactory(intent: Intent): RemoteViewsFactory {
    return MongezWidgetFactory(applicationContext)
  }
}

private data class WidgetTaskItem(
    val id: String,
    val title: String,
    val isDone: Boolean,
    val time: String,
    val priority: Int,
)

private class MongezWidgetFactory(
    private val context: Context,
) : RemoteViewsService.RemoteViewsFactory {
  private val tasks = mutableListOf<WidgetTaskItem>()
  private var dateKey: String = todayDateKey()

  override fun onCreate() {
    loadTasks()
  }

  override fun onDataSetChanged() {
    loadTasks()
  }

  override fun onDestroy() {
    tasks.clear()
  }

  override fun getCount(): Int = tasks.size

  override fun getViewAt(position: Int): RemoteViews? {
    if (position < 0 || position >= tasks.size) {
      return null
    }

    val task = tasks[position]
    val views = RemoteViews(context.packageName, R.layout.mongez_widget_list_item)
    views.setImageViewResource(
        R.id.widget_task_check,
        if (task.isDone) R.drawable.ic_widget_checked else R.drawable.ic_widget_unchecked,
    )
    views.setTextViewText(R.id.widget_task_title, task.title)
    views.setTextViewText(R.id.widget_task_time, task.time)
    views.setViewVisibility(
        R.id.widget_task_time, if (task.time.isEmpty()) View.GONE else View.VISIBLE)

    val textColor = context.getColor(R.color.widget_text)
    val mutedColor = context.getColor(R.color.widget_muted)
    views.setTextColor(R.id.widget_task_title, if (task.isDone) mutedColor else textColor)
    views.setInt(
        R.id.widget_task_title,
        "setPaintFlags",
        if (task.isDone) Paint.STRIKE_THRU_TEXT_FLAG or Paint.ANTI_ALIAS_FLAG
        else Paint.ANTI_ALIAS_FLAG,
    )

    val priorityColor =
        when (task.priority) {
          2 -> Color.parseColor("#EF4444")
          1 -> Color.parseColor("#F59E0B")
          else -> 0
        }
    if (priorityColor != 0 && !task.isDone) {
      views.setViewVisibility(R.id.widget_task_priority, View.VISIBLE)
      views.setInt(R.id.widget_task_priority, "setColorFilter", priorityColor)
    } else {
      views.setViewVisibility(R.id.widget_task_priority, View.GONE)
    }

    val uri =
        Uri.parse("mongez://toggle")
            .buildUpon()
            .appendQueryParameter("action", "toggle")
            .appendQueryParameter("taskId", task.id)
            .appendQueryParameter("date", dateKey)
            .appendQueryParameter("row", (position + 1).toString())
            .build()

    val fillInIntent = Intent().apply { data = uri }
    fillInIntent.putExtra("action", "toggle")
    fillInIntent.putExtra("taskId", task.id)
    fillInIntent.putExtra("date", dateKey)
    views.setOnClickFillInIntent(R.id.widget_task_row, fillInIntent)
    return views
  }

  override fun getLoadingView(): RemoteViews? = null

  override fun getViewTypeCount(): Int = 1

  override fun getItemId(position: Int): Long {
    if (position < 0 || position >= tasks.size) {
      return position.toLong()
    }
    return tasks[position].id.hashCode().toLong()
  }

  override fun hasStableIds(): Boolean = true

  private fun loadTasks() {
    tasks.clear()
    val widgetData = HomeWidgetPlugin.getData(context)
    dateKey = widgetData.getString("widget_date_key", todayDateKey()) ?: todayDateKey()
    val rawTasks = widgetData.getString("widget_tasks_json", "[]") ?: "[]"

    try {
      val array = JSONArray(rawTasks)
      for (index in 0 until array.length()) {
        val item = array.optJSONObject(index) ?: continue
        val id = item.optString("id").trim()
        val title = item.optString("title").trim()
        if (id.isEmpty() || title.isEmpty()) {
          continue
        }

        tasks.add(
            WidgetTaskItem(
                id = id,
                title = title,
                isDone = item.optBoolean("done", false),
                time = item.optString("time", ""),
                priority = item.optInt("priority", 0),
            ),
        )
      }
    } catch (_: Exception) {
      tasks.clear()
    }
  }

  private fun todayDateKey(): String {
    return SimpleDateFormat("yyyy-MM-dd", Locale.US).format(Date())
  }
}

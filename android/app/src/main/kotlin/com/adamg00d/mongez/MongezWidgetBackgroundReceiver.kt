package com.adamg00d.mongez

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.util.Log
import es.antonborri.home_widget.HomeWidgetBackgroundWorker
import io.flutter.FlutterInjector

class MongezWidgetBackgroundReceiver : BroadcastReceiver() {
  companion object {
    private const val TAG = "MongezWidgetBg"

    /** Runs the Dart widget callback with [uri] (e.g. a day-change refresh). */
    fun dispatch(context: Context, uri: Uri) {
      ensureFlutter(context)
      val intent = Intent("es.antonborri.home_widget.action.BACKGROUND").apply { data = uri }
      HomeWidgetBackgroundWorker.enqueueWork(context, intent)
    }

    private fun ensureFlutter(context: Context) {
      val flutterLoader = FlutterInjector.instance().flutterLoader()
      flutterLoader.startInitialization(context.applicationContext)
      flutterLoader.ensureInitializationComplete(context.applicationContext, null)
    }
  }

  override fun onReceive(context: Context, intent: Intent) {
    ensureFlutter(context)

    val normalizedIntent = Intent(intent)
    if (normalizedIntent.dataString.isNullOrBlank()) {
      extractUriFromIntent(intent)?.let { normalizedIntent.data = it }
    }

    Log.d(
        TAG,
        "onReceive action=${intent.action} rawData=${intent.dataString} normalizedData=${normalizedIntent.dataString} extras=${intent.extras?.keySet()}",
    )

    HomeWidgetBackgroundWorker.enqueueWork(context, normalizedIntent)
  }

  private fun extractUriFromIntent(intent: Intent): Uri? {
    val taskId = intent.getStringExtra("taskId")?.trim()
    if (taskId.isNullOrEmpty()) {
      return null
    }

    val date = intent.getStringExtra("date")?.trim().orEmpty()
    val action = intent.getStringExtra("action")?.trim().takeUnless { it.isNullOrEmpty() } ?: "toggle"

    val builder =
        Uri.parse("mongez://toggle")
            .buildUpon()
            .appendQueryParameter("action", action)
            .appendQueryParameter("taskId", taskId)
    if (date.isNotEmpty()) {
      builder.appendQueryParameter("date", date)
    }

    return builder.build()
  }
}

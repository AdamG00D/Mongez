package com.adamg00d.mongez

import android.app.AppOpsManager
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.Process
import android.provider.Settings
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.util.concurrent.Executors

/**
 * Reads device usage via UsageStatsManager events. Requires the user to grant
 * "Usage access" (PACKAGE_USAGE_STATS) from system settings. All data stays
 * on the device.
 */
class ScreenTimeChannel(private val context: Context) : MethodChannel.MethodCallHandler {
  companion object {
    const val NAME = "mongez/screen_time"
    private const val LOOKBACK_MS = 6L * 60 * 60 * 1000
    private const val ICON_PX = 96
    private const val MAX_APPS = 40

    // Event constants (some are API 28+ but are plain ints).
    private const val ACTIVITY_RESUMED = 1
    private const val ACTIVITY_PAUSED = 2
    private const val SCREEN_INTERACTIVE = 15
    private const val SCREEN_NON_INTERACTIVE = 16
    private const val KEYGUARD_HIDDEN = 18
    private const val ACTIVITY_STOPPED = 23
    private const val DEVICE_SHUTDOWN = 26
  }

  private val executor = Executors.newSingleThreadExecutor()
  private val main = Handler(Looper.getMainLooper())
  private val iconCache = HashMap<String, ByteArray?>()
  private val labelCache = HashMap<String, String?>()

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (call.method) {
      "hasPermission" -> result.success(hasPermission())
      "openSettings" -> {
        openSettings()
        result.success(null)
      }
      "getUsage" -> {
        if (!hasPermission()) {
          result.error("NO_PERMISSION", "Usage access not granted", null)
          return
        }
        val start = (call.argument<Number>("start"))?.toLong() ?: 0L
        val end = (call.argument<Number>("end"))?.toLong() ?: System.currentTimeMillis()
        val includeApps = call.argument<Boolean>("includeApps") ?: true
        executor.execute {
          try {
            val data = computeUsage(start, end, includeApps)
            main.post { result.success(data) }
          } catch (e: Exception) {
            main.post { result.error("USAGE_ERROR", e.message, null) }
          }
        }
      }
      else -> result.notImplemented()
    }
  }

  private fun hasPermission(): Boolean {
    val appOps = context.getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
    val mode =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
          appOps.unsafeCheckOpNoThrow(
              AppOpsManager.OPSTR_GET_USAGE_STATS, Process.myUid(), context.packageName)
        } else {
          @Suppress("DEPRECATION")
          appOps.checkOpNoThrow(
              AppOpsManager.OPSTR_GET_USAGE_STATS, Process.myUid(), context.packageName)
        }
    return mode == AppOpsManager.MODE_ALLOWED
  }

  private fun openSettings() {
    val withPackage =
        Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS).apply {
          data = Uri.parse("package:${context.packageName}")
          addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
    try {
      context.startActivity(withPackage)
    } catch (_: Exception) {
      try {
        context.startActivity(
            Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
      } catch (_: Exception) {
        context.startActivity(
            Intent(Settings.ACTION_SETTINGS).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
      }
    }
  }

  private fun overlap(from: Long, to: Long, start: Long, end: Long): Long {
    val a = maxOf(from, start)
    val b = minOf(to, end)
    return if (b > a) b - a else 0L
  }

  private fun computeUsage(start: Long, requestedEnd: Long, includeApps: Boolean): Map<String, Any> {
    val end = minOf(requestedEnd, System.currentTimeMillis())
    val usm = context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
    val events = usm.queryEvents(start - LOOKBACK_MS, end)
    val event = UsageEvents.Event()

    val excluded = HashSet<String>().apply {
      add("com.android.systemui")
      defaultLauncher()?.let { add(it) }
    }

    var screenOnSince: Long? = null
    var screenMs = 0L
    var sawScreenEvents = false
    var unlocks = 0

    // Foreground sessions keyed by "package/class".
    val openSessions = HashMap<String, Long>()
    val appMs = HashMap<String, Long>()
    val launches = HashMap<String, Int>()
    var lastForegroundPackage: String? = null

    fun closeSession(key: String, at: Long) {
      val since = openSessions.remove(key) ?: return
      val pkg = key.substringBefore('/')
      val ms = overlap(since, at, start, end)
      if (ms > 0) appMs[pkg] = (appMs[pkg] ?: 0L) + ms
    }

    fun closeAll(at: Long) {
      for (key in openSessions.keys.toList()) closeSession(key, at)
    }

    while (events.hasNextEvent()) {
      events.getNextEvent(event)
      val t = event.timeStamp
      val pkg = event.packageName ?: continue
      when (event.eventType) {
        SCREEN_INTERACTIVE -> {
          sawScreenEvents = true
          if (screenOnSince == null) screenOnSince = t
        }
        SCREEN_NON_INTERACTIVE -> {
          sawScreenEvents = true
          // If we never saw the screen turn on, it was on since before the window.
          val since = screenOnSince ?: (start - LOOKBACK_MS)
          screenMs += overlap(since, t, start, end)
          screenOnSince = null
          closeAll(t)
        }
        KEYGUARD_HIDDEN -> if (t >= start) unlocks++
        ACTIVITY_RESUMED -> {
          val key = "$pkg/${event.className}"
          if (!openSessions.containsKey(key)) openSessions[key] = t
          if (t >= start && pkg != lastForegroundPackage && !excluded.contains(pkg)) {
            launches[pkg] = (launches[pkg] ?: 0) + 1
          }
          lastForegroundPackage = pkg
        }
        ACTIVITY_PAUSED, ACTIVITY_STOPPED -> closeSession("$pkg/${event.className}", t)
        DEVICE_SHUTDOWN -> {
          screenOnSince?.let { screenMs += overlap(it, t, start, end) }
          screenOnSince = null
          closeAll(t)
        }
      }
    }
    screenOnSince?.let { screenMs += overlap(it, end, start, end) }
    closeAll(end)

    for (pkg in excluded) appMs.remove(pkg)
    val appsTotal = appMs.values.sum()
    // Devices/versions without screen events: fall back to app foreground time.
    if (!sawScreenEvents || screenMs < appsTotal / 2) {
      screenMs = maxOf(screenMs, appsTotal)
    }

    val result = HashMap<String, Any>()
    result["screenOnMs"] = screenMs
    result["unlocks"] = unlocks

    if (includeApps) {
      val apps = ArrayList<Map<String, Any?>>()
      appMs.entries
          .filter { it.value >= 1000L }
          .sortedByDescending { it.value }
          .take(MAX_APPS)
          .forEach { (pkg, ms) ->
            val label = labelFor(pkg) ?: return@forEach // skip invisible system packages
            apps.add(
                hashMapOf(
                    "package" to pkg,
                    "label" to label,
                    "ms" to ms,
                    "launches" to (launches[pkg] ?: 0),
                    "icon" to iconFor(pkg),
                ))
          }
      result["apps"] = apps
    }
    return result
  }

  private fun defaultLauncher(): String? {
    return try {
      val intent = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_HOME)
      context.packageManager
          .resolveActivity(intent, PackageManager.MATCH_DEFAULT_ONLY)
          ?.activityInfo
          ?.packageName
    } catch (_: Exception) {
      null
    }
  }

  private fun labelFor(pkg: String): String? {
    if (labelCache.containsKey(pkg)) return labelCache[pkg]
    val label =
        try {
          val pm = context.packageManager
          pm.getApplicationLabel(pm.getApplicationInfo(pkg, 0)).toString()
        } catch (_: Exception) {
          null
        }
    labelCache[pkg] = label
    return label
  }

  private fun iconFor(pkg: String): ByteArray? {
    if (iconCache.containsKey(pkg)) return iconCache[pkg]
    val bytes =
        try {
          val drawable = context.packageManager.getApplicationIcon(pkg)
          val bitmap = Bitmap.createBitmap(ICON_PX, ICON_PX, Bitmap.Config.ARGB_8888)
          val canvas = Canvas(bitmap)
          drawable.setBounds(0, 0, ICON_PX, ICON_PX)
          drawable.draw(canvas)
          val out = ByteArrayOutputStream()
          bitmap.compress(Bitmap.CompressFormat.PNG, 100, out)
          bitmap.recycle()
          out.toByteArray()
        } catch (_: Exception) {
          null
        }
    iconCache[pkg] = bytes
    return bytes
  }
}

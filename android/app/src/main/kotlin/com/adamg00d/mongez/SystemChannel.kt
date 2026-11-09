package com.adamg00d.mongez

import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.SoundPool
import android.net.Uri
import android.os.Build
import android.provider.Settings
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Small platform helpers that don't justify a plugin:
 *  - `playSound` plays the bundled completion / celebration sounds.
 *  - `openNotificationSettings` opens this app's notification settings page.
 */
class SystemChannel(private val context: Context) : MethodChannel.MethodCallHandler {
  companion object {
    const val NAME = "mongez/system"
  }

  private val soundPool: SoundPool =
      SoundPool.Builder()
          .setMaxStreams(2)
          .setAudioAttributes(
              AudioAttributes.Builder()
                  // Sonification follows the system/notification volume and is
                  // silenced when the phone is on silent.
                  .setUsage(AudioAttributes.USAGE_ASSISTANCE_SONIFICATION)
                  .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                  .build())
          .build()

  private val loaded = mutableSetOf<Int>()
  private val pending = mutableSetOf<Int>()

  init {
    soundPool.setOnLoadCompleteListener { pool, sampleId, status ->
      if (status == 0) {
        loaded.add(sampleId)
        if (pending.remove(sampleId)) pool.play(sampleId, 1f, 1f, 1, 0, 1f)
      }
    }
  }

  private val sounds: Map<String, Int> =
      mapOf(
          "done" to soundPool.load(context, R.raw.sound_done, 1),
          "celebrate" to soundPool.load(context, R.raw.sound_celebrate, 1),
      )

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (call.method) {
      "playSound" -> {
        val id = sounds[call.argument<String>("name") ?: "done"]
        if (id != null) {
          if (loaded.contains(id)) soundPool.play(id, 1f, 1f, 1, 0, 1f) else pending.add(id)
        }
        result.success(null)
      }
      "openNotificationSettings" -> {
        result.success(openNotificationSettings())
      }
      else -> result.notImplemented()
    }
  }

  private fun openNotificationSettings(): Boolean {
    val intent =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
          Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS)
              .putExtra(Settings.EXTRA_APP_PACKAGE, context.packageName)
        } else {
          Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
              .setData(Uri.fromParts("package", context.packageName, null))
        }
    return try {
      context.startActivity(intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
      true
    } catch (_: Exception) {
      false
    }
  }

  fun dispose() {
    soundPool.release()
  }
}

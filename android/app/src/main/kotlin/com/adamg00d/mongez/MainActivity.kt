package com.adamg00d.mongez

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
  private var systemChannel: SystemChannel? = null

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, ScreenTimeChannel.NAME)
        .setMethodCallHandler(ScreenTimeChannel(applicationContext))
    val system = SystemChannel(applicationContext)
    systemChannel = system
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SystemChannel.NAME)
        .setMethodCallHandler(system)
  }

  override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
    systemChannel?.dispose()
    systemChannel = null
    super.cleanUpFlutterEngine(flutterEngine)
  }
}

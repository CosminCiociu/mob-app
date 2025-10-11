package com.ovo_meet.ovo

import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.ovo_meet.ovo/config"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getGoogleApiKey" -> {
                    val apiKey = getGoogleApiKey()
                    if (apiKey != null) {
                        result.success(apiKey)
                    } else {
                        result.error("UNAVAILABLE", "Google API key not available", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun getGoogleApiKey(): String? {
        return try {
            val ai: ApplicationInfo = packageManager.getApplicationInfo(packageName, PackageManager.GET_META_DATA)
            val bundle = ai.metaData
            bundle?.getString("com.google.android.geo.API_KEY")
        } catch (e: PackageManager.NameNotFoundException) {
            null
        }
    }
}

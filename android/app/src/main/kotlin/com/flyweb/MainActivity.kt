package com.mawaqit.androidtv

import io.flutter.embedding.android.FlutterActivity
import android.content.pm.PackageManager
import androidx.annotation.NonNull
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor.DartEntrypoint
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity() {
    private val CHANNEL = "nativeMethodsChannel"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "isPackageInstalled") {
                val packageName = call.argument<String>("packageName")
                val isInstalled = isPackageInstalled(packageName)
                result.success(isInstalled)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun isPackageInstalled(packageName: String?): Boolean {
        val packageManager = applicationContext.packageManager
        return try {
            packageManager.getPackageInfo(packageName!!, PackageManager.GET_ACTIVITIES)
            true
        } catch (e: PackageManager.NameNotFoundException) {
            false
        }
    }
}

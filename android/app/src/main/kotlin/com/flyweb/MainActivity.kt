package com.mawaqit.androidtv

import io.flutter.embedding.android.FlutterActivity
import android.content.pm.PackageManager
import androidx.annotation.NonNull
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor.DartEntrypoint
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import android.hardware.Camera;

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
            }  else if (call.method == "hasSystemFeature") {
                val feature = call.argument<String>("feature")
 if (feature != null) {
        val pm = applicationContext.packageManager
        val hasFeature = pm.hasSystemFeature(feature)
        result.success(hasFeature)
    } else {
        result.error("InvalidArgument", "Feature argument is null", null)
    }
            }
            
            else {
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

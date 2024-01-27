package com.mawaqit.androidtv

import android.content.Intent
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
  private val CHANNEL = "com.mawaqit.androidTv/update_apk"

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)

    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
      if (call.method == "installApk") {
        val apkPath = call.argument<String>("apkPath")
        apkPath?.let {
          updateApk(it)
        }
      } else {
        result.notImplemented()
      }
    }
  }


  private fun updateApk(apkPath: String) {
    val file = File(apkPath)

    val uri = FileProvider.getUriForFile(this, "${applicationContext.packageName}.provider", file)

    val intent = Intent(Intent.ACTION_VIEW)
    intent.setDataAndType(uri, "application/vnd.android.package-archive")
    intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
    startActivity(intent)
  }
}

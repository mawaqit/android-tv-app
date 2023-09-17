package com.mawaqit.androidtv

import android.content.Intent
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity: FlutterActivity() {
  private val CHANNEL = "com.mawaqit.androidTv/updater"

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)

    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler{
      cal, result ->
          if(cal.method == "UPDATE_APK"){
            updateApk();
            result.success(true);
          }
    }
  }


  fun updateApk(){
    val file = File(context.cacheDir,  "mawaqit.apk")

    val uri = FileProvider.getUriForFile(context, "${context.packageName}.provider", file)

    /// start a setup intent
    val intent =  Intent(Intent.ACTION_VIEW)
    intent.setDataAndType(uri, "application/vnd.android.package-archive")
    intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
    context.startActivity(intent)
  }
}

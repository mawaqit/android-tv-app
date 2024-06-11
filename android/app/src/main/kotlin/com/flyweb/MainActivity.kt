package com.mawaqit.androidtv

import android.os.AsyncTask
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.BufferedReader
import java.io.DataOutputStream
import java.io.InputStreamReader
import android.content.pm.PackageManager
import android.os.Bundle
import android.provider.Settings
import android.content.Intent
import android.net.Uri
import java.io.File
import android.content.Context
import android.content.ComponentName
import android.os.Build.VERSION
import android.os.Build.VERSION_CODES
import android.app.admin.DevicePolicyManager
import java.io.IOException
class MainActivity : FlutterActivity() {
private lateinit var mAdminComponentName: ComponentName
  private lateinit var mDevicePolicyManager: DevicePolicyManager

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "nativeMethodsChannel")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "setDeviceTimezone" -> setDeviceTimezone(call, result)
                    "connectToWifi" -> connectToWifi(call, result)
                    "isPackageInstalled" -> {
                            val packageName = call.argument<String>("packageName")
                            if (packageName != null) {
                                val isInstalled = isPackageInstalled(packageName)
                                result.success(isInstalled)
                            } else {
                                result.error("INVALID_ARGUMENT", "Package name is null", null)
                            }
                        }  
                        "checkRoot"->checkRoot(result)
                        "clearAppData"->{
                            val isSuccess = clearDataRestart()
        result.success(isSuccess)
                        }
           
                             else -> result.notImplemented()
                }
            }
    }
private fun checkRoot(result: MethodChannel.Result) {
    try {
        val p = Runtime.getRuntime().exec("su")
        val os = DataOutputStream(p.outputStream)
        os.writeBytes("echo \"Do I have root?\" >/data/LandeRootCheck.txt\n")
        os.writeBytes("exit\n")
        os.flush()
        try {
            p.waitFor()
            if (p.exitValue() == 0) {
                result.success(true)
            } else {
                result.success(false)
            }
        } catch (e: InterruptedException) {
            result.error("InterruptedException", "Interrupted exception occurred", null)
        }
    } catch (e: IOException) {
        result.error("IOException", "I/O exception occurred", null)
    }
}
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        var REQUEST_OVERLAY_PERMISSIONS = 100
        if (isRootAvailable() && !Settings.canDrawOverlays(getApplicationContext())) {
             try {
        val command = "appops set com.mawaqit.androidtv SYSTEM_ALERT_WINDOW allow"
        val process = Runtime.getRuntime().exec(arrayOf("su", "-c", command))
        val outputStream = DataOutputStream(process.outputStream)
        outputStream.writeBytes(command + "\n")
        outputStream.flush()
        outputStream.close()
        process.waitFor()
        return
    } catch (e: Exception) {
        e.printStackTrace()
    }
            
        }
    }

    private fun isRootAvailable(): Boolean {
        System.getenv("PATH")?.split(":")?.forEach { pathDir ->
            if (File(pathDir, "su").exists()) {
                return true
            }
        }
        return false
    }
  
 private fun setDeviceTimezone(call: MethodCall, result: MethodChannel.Result) {
    AsyncTask.execute {
        try {
            val timezone = call.argument<String>("timezone")
            executeCommand("service call alarm 3 s16 $timezone", result)
        } catch (e: Exception) {
            handleCommandException(e, result)
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
private fun connectToWifi(call: MethodCall, result: MethodChannel.Result) {
    AsyncTask.execute {
        try {
            val ssid = call.argument<String>("ssid")
            val password = call.argument<String>("password")
            val security = if (password.isNullOrEmpty()) "open" else "wpa2"

            Log.i("SU_COMMAND", "Wifi Command output: cmd wifi connect-network $ssid $security $password")

            executeCommand("cmd wifi connect-network $ssid $security $password", result)

        } catch (e: Exception) {
            handleCommandException(e, result)
        }
    }
}
    private fun executeCommand(command: String, result: MethodChannel.Result) {
        try {
            val suProcess = Runtime.getRuntime().exec("su")
            val os = DataOutputStream(suProcess.outputStream)

            os.writeBytes(command + "\n")
            os.flush()
            os.close()

            val output = BufferedReader(InputStreamReader(suProcess.inputStream)).readText()
            val error = BufferedReader(InputStreamReader(suProcess.errorStream)).readText()

            Log.i("SU_COMMAND", "Command output: $output")
            Log.e("SU_COMMAND", "Command error: $error")

            val exitCode = suProcess.waitFor()

            if (exitCode != 0) {
                Log.e("SU_COMMAND", "Command failed with exit code $exitCode.")
                                result.success(false)

            } else {
                Log.i("SU_COMMAND", "Command executed successfully.")
                result.success(true)
            }
        } catch (e: Exception) {
            handleCommandException(e, result)
        }
    }

    private fun handleCommandException(e: Exception, result: MethodChannel.Result) {
        Log.e("SU_COMMAND", "Exception while executing command: ${e.message}")
        result.error("CMD_ERROR", "Exception while executing command", null)
    }
      private fun clearDataRestart(): Boolean {
    try {
      val processBuilder = ProcessBuilder()
      processBuilder.command("sh", "-c", """
            pm clear com.mawaqit.androidtv
        """.trimIndent())
      val process = processBuilder.start()
      val exitCode = process.waitFor()
      if (exitCode == 0) {
        return true
      }
      return false
    } catch (e: IOException) {
      e.printStackTrace()
      return false
    } catch (e: InterruptedException) {
      e.printStackTrace()
      return false
    }
  }
}

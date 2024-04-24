package com.mawaqit.androidtv

import io.flutter.embedding.android.FlutterActivity
import android.content.pm.PackageManager
import androidx.annotation.NonNull
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor.DartEntrypoint
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import java.io.IOException
import android.app.Activity
import android.content.Intent
import android.app.KeyguardManager
import android.content.Context
import java.io.BufferedReader
import java.io.DataOutputStream
import java.io.InputStreamReader
import android.os.AsyncTask
import android.util.Log
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
      } else if (call.method == "clearAppData") {

        val isSuccess = clearDataRestart()
        result.success(isSuccess)
      } else if (call.method == "hasSystemFeature") {
        val feature = call.argument<String>("feature")
        if (feature != null) {
          val pm = applicationContext.packageManager
          val hasFeature = pm.hasSystemFeature(feature)
          result.success(hasFeature)
        } else {
          result.error("InvalidArgument", "Feature argument is null", null)
        }
      } else if (call.method == "toggleScreen") {
       toggleScreen(call, result)
      }
       else if (call.method == "grantDumpSysPermission") {
    grantDumpSysPermission(call, result)
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

  private fun grantDumpSysPermission(call: MethodCall, result: MethodChannel.Result) {
    AsyncTask.execute {
        try {
        
                executeCommand(listOf("pm grant com.mawaqit.androidtv android.permission.DUMP"), result) // Lock the device
            
        } catch (e: Exception) {
            handleCommandException(e, result)
        }
    }}


private fun toggleScreen(call: MethodCall, result: MethodChannel.Result) {
    AsyncTask.execute {
        try {
            val isDeviceLocked = isDeviceLocked()
            if (!isDeviceLocked) {
                  val commands = listOf(
                    "input keyevent 82",
                    "am start -W -n com.mawaqit.androidtv/.MainActivity"
                )
                                executeCommand(commands, result) // Lock the device

            } else {
                executeCommand(listOf("input keyevent 26"), result) // Lock the device
            }
        } catch (e: Exception) {
            handleCommandException(e, result)
        }
    }
}

private fun isDeviceLocked(): Boolean {
    try {
        val process = Runtime.getRuntime().exec("dumpsys power | grep \"mWakefulness=\"")
        val reader = BufferedReader(InputStreamReader(process.inputStream))
        val output = reader.use { it.readText() }

        // Check if the output contains "mWakefulness=Awake"
        val isAwake = output.contains("mWakefulness=Awake")

        return isAwake
    } catch (e: IOException) {
        e.printStackTrace()
        return false
    }
}


private fun executeCommand(commands: List<String>, result: MethodChannel.Result) {
    try {
        Log.d("SU_COMMAND", "Executing commands: ${commands.joinToString(separator = " && ")}")

        val suProcess = Runtime.getRuntime().exec("su")
        val os = DataOutputStream(suProcess.outputStream)

        val command = commands.joinToString(separator = " && ") + "\n"
        Log.d("SU_COMMAND", "Writing command to DataOutputStream: $command")
        os.writeBytes(command)
        os.flush()
        os.close()

        val output = BufferedReader(InputStreamReader(suProcess.inputStream)).readText()
        val error = BufferedReader(InputStreamReader(suProcess.errorStream)).readText()

        Log.i("SU_COMMAND", "Command output: $output")
        Log.e("SU_COMMAND", "Command error: $error")

        val exitCode = suProcess.waitFor()
        Log.d("SU_COMMAND", "Exit code: $exitCode")

        if (exitCode != 0) {
            Log.e("SU_COMMAND", "Command failed with exit code $exitCode.")
            result.error("CMD_ERROR", "Command failed", null)
        } else {
            Log.i("SU_COMMAND", "Command executed successfully.")
            result.success("Command executed successfully.")
        }
    } catch (e: Exception) {
        Log.e("SU_COMMAND", "Exception occurred: ${e.message}")
        handleCommandException(e, result)
    }
}

private fun handleCommandException(e: Exception, result: MethodChannel.Result) {
    result.error("Exception", "An exception occurred: $e", null)
}

}
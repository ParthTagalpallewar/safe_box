package com.example.safe_box

import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import com.example.safe_box.AppInfoHelper
import android.content.Intent
import android.net.Uri
import android.provider.Settings

class MainActivity : FlutterActivity() {
    private val CHANNEL = "app_info_channel"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            val appInfoHelper = AppInfoHelper(this)
            when (call.method) {
                "getInstalledApps" -> {
                    val appsData = appInfoHelper.getInstalledAppsWithPermissions()
                    result.success(appsData)
                }

                "openAppSettings" -> {
                    val packageName = call.argument<String>("packageName")
                    if (packageName != null) {
                        val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                            data = Uri.parse("package:$packageName")
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        }
                        startActivity(intent)
                        result.success("opened")
                    } else {
                        result.error("INVALID_PACKAGE", "Package name required", null)
                    }
                }


                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}




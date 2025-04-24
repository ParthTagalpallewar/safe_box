


package com.example.safe_box

import android.content.Context
import android.content.pm.ApplicationInfo
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.BitmapShader
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.Shader
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.util.Base64
import android.util.Log
import org.json.JSONArray
import org.json.JSONObject
import java.io.ByteArrayOutputStream

class AppInfoHelper(private val context: Context) {

    private fun isSystemApp(app: ApplicationInfo): Boolean {
        return (app.flags and ApplicationInfo.FLAG_SYSTEM) != 0
    }

    private fun isLaunchableApp(pm: PackageManager, packageName: String): Boolean {
        return pm.getLaunchIntentForPackage(packageName) != null
    }

    fun getInstalledAppsWithPermissions(): String {
        val packageManager = context.packageManager
        val installedApps = packageManager.getInstalledApplications(PackageManager.GET_META_DATA)

        val appsArray = JSONArray()

        for (app in installedApps) {
            if (isSystemApp(app) || !isLaunchableApp(packageManager, app.packageName)) {
                continue
            }

            val permissions = getAppPermissions(packageManager, app.packageName)
            val riskScore = calculateRiskScore(packageManager, app, permissions)

            val appObject = JSONObject().apply {
                put("appName", app.loadLabel(packageManager).toString())
                put("packageName", app.packageName)
                put("permissions", JSONArray(permissions))
                put("riskScore", riskScore)
                put("icon", getAppIconBase64(packageManager, app.packageName))
            }

            appsArray.put(appObject)
        }

        return appsArray.toString()
    }

    fun getAppPermissionsOnly(packageName: String): List<String> {
        val packageManager = context.packageManager
        return getAppPermissions(packageManager, packageName)
    }

    fun getRiskScoreForApp(packageName: String): Int {
        val packageManager = context.packageManager
        val appInfo = packageManager.getApplicationInfo(packageName, 0)
        val permissions = getAppPermissions(packageManager, packageName)
        return calculateRiskScore(packageManager, appInfo, permissions)
    }

    private fun getAppPermissions(packageManager: PackageManager, packageName: String): List<String> {
        return try {
            val packageInfo: PackageInfo = packageManager.getPackageInfo(packageName, PackageManager.GET_PERMISSIONS)
            packageInfo.requestedPermissions?.toList() ?: emptyList()
        } catch (e: PackageManager.NameNotFoundException) {
            emptyList()
        }
    }

    private fun getAppIconBase64(packageManager: PackageManager, packageName: String): String {
        return try {
            val drawable: Drawable = packageManager.getApplicationIcon(packageName)
            val bitmap: Bitmap = if (drawable is BitmapDrawable) {
                drawable.bitmap
            } else {
                val bitmap = Bitmap.createBitmap(
                    drawable.intrinsicWidth,
                    drawable.intrinsicHeight,
                    Bitmap.Config.ARGB_8888
                )
                val canvas = Canvas(bitmap)
                drawable.setBounds(0, 0, canvas.width, canvas.height)
                drawable.draw(canvas)
                bitmap
            }

            val outputStream = ByteArrayOutputStream()
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, outputStream)
            val byteArray = outputStream.toByteArray()
            Base64.encodeToString(byteArray, Base64.NO_WRAP)
        } catch (e: Exception) {
            Log.e("AppInfoHelper", "Error getting app icon: ${e.message}")
            ""
        }
    }


    private fun calculateRiskScore(
        packageManager: PackageManager,
        appInfo: ApplicationInfo,
        permissions: List<String>
    ): Int {
        val dangerousPermissions = listOf(
            "android.permission.READ_CONTACTS",
            "android.permission.ACCESS_FINE_LOCATION",
            "android.permission.RECORD_AUDIO",
            "android.permission.CAMERA",
            "android.permission.SEND_SMS",
            "android.permission.READ_SMS",
            "android.permission.READ_PHONE_STATE",
            "android.permission.WRITE_EXTERNAL_STORAGE"
        )

        var score = 0

        if ("android.permission.INTERNET" in permissions) {
            score += 15
        }

        score += permissions.size * 2

        val dangerousCount = permissions.count { it in dangerousPermissions }
        score += dangerousCount * 10

        if (!appInfo.packageName.startsWith("com.") && !appInfo.packageName.startsWith("org.")) {
            score += 10
        }

        if ((appInfo.flags and ApplicationInfo.FLAG_SYSTEM) == 0) {
            score += 5
        }

        return score
    }
}


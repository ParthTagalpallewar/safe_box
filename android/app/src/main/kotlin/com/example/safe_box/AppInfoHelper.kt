

package com.example.safe_box

import android.content.Context
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.drawable.BitmapDrawable
import android.util.Base64
import org.json.JSONArray
import org.json.JSONObject
import java.io.ByteArrayOutputStream

class AppInfoHelper(private val context: Context) {

    fun getInstalledAppsWithPermissions(): String {
        val packageManager = context.packageManager
        val installedApps = packageManager.getInstalledApplications(PackageManager.GET_META_DATA)

        val appsArray = JSONArray()

        for (app in installedApps) {

            if ((app.flags and android.content.pm.ApplicationInfo.FLAG_SYSTEM) != 0) {
                continue
            }
            val appObject = JSONObject()
            appObject.put("appName", app.loadLabel(packageManager).toString())
            appObject.put("packageName", app.packageName)
            appObject.put("permissions", JSONArray(getAppPermissions(packageManager, app.packageName)))
            appObject.put("icon", getAppIconBase64(packageManager, app.packageName)) // Adding the icon

            appsArray.put(appObject)
        }

        return appsArray.toString()
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
            val drawable = packageManager.getApplicationIcon(packageName)
            val bitmap = (drawable as BitmapDrawable).bitmap
            val outputStream = ByteArrayOutputStream()
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, outputStream)
            val byteArray = outputStream.toByteArray()
            Base64.encodeToString(byteArray, Base64.NO_WRAP)
        } catch (e: Exception) {
            ""
        }
    }
}



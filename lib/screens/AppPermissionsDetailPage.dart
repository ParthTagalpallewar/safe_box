import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppPermissionsDetailPage extends StatefulWidget {
  final Map<String, dynamic> app;
  const AppPermissionsDetailPage({super.key, required this.app});

  @override
  State<AppPermissionsDetailPage> createState() => _AppPermissionsDetailPageState();
}

class _AppPermissionsDetailPageState extends State<AppPermissionsDetailPage> {
  static const platform = MethodChannel('app_info_channel');

  String selectedRiskLevel = 'high';

  @override
  Widget build(BuildContext context) {
    final String appName = widget.app['appName'] ?? 'Unknown App';
    final String packageName = widget.app['packageName'] ?? 'N/A';
    final double riskScore = (widget.app['riskScore'] ?? 0.0).toDouble();
    final List<dynamic> permissions = widget.app['permissions'] ?? [];
    final String? iconBase64 = widget.app['icon'];

    const List<dynamic> highRiskPermissions = [
      'READ_SMS', 'SEND_SMS', 'RECEIVE_SMS',
      'READ_CONTACTS', 'READ_CALL_LOG',
      'RECORD_AUDIO', 'ACCESS_FINE_LOCATION',
      'CAMERA'
    ];
    const List<dynamic> mediumRiskPermissions = [
      'INTERNET', 'ACCESS_COARSE_LOCATION',
      'READ_EXTERNAL_STORAGE', 'WRITE_EXTERNAL_STORAGE',
      'USE_SIP'
    ];

    String getPermissionName(dynamic permission) {
      return permission.toString().split('.').last;
    }

    final List<dynamic> highRisk = permissions.where((p) =>
        highRiskPermissions.contains(getPermissionName(p))).toList();

    final List<dynamic> mediumRisk = permissions.where((p) =>
    mediumRiskPermissions.contains(getPermissionName(p)) && !highRisk.contains(p)).toList();

    final List<dynamic> lowRisk = permissions.where((p) =>
    !highRisk.contains(p) && !mediumRisk.contains(p)).toList();

    List<dynamic> getFilteredPermissions() {
      if (selectedRiskLevel == 'high') return highRisk;
      if (selectedRiskLevel == 'medium') return mediumRisk;
      if (selectedRiskLevel == 'low') return lowRisk;
      return permissions;
    }

    Color getButtonColor(String level) {
      if (selectedRiskLevel == level) {
        if (level == 'high') return Colors.red;
        if (level == 'medium') return Colors.orange;
        if (level == 'low') return Colors.green;
      }
      return Colors.grey;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(appName, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF150050),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color(0xFF1A1A40),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipOval(
                  child: iconBase64 != null && iconBase64.isNotEmpty
                      ? Image.memory(base64Decode(iconBase64), width: 60, height: 60, fit: BoxFit.cover)
                      : const Icon(Icons.android, size: 60, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(appName, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(packageName, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Text(
              "Risk Score: ${riskScore.toStringAsFixed(1)}",
              style: TextStyle(
                color: riskScore > 200 ? Colors.red : riskScore >= 100 ? Colors.orange : Colors.green,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: () async {
                try {
                  await platform.invokeMethod('openAppSettings', {'packageName': packageName});
                } on PlatformException catch (e) {
                  debugPrint("Failed to open app settings: ${e.message}");
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.settings, color: Colors.white),
              label: const Text("Manage Permissions", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
            const SizedBox(height: 16),

            const Text("Permissions:", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),


            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                  child: ElevatedButton(
                    onPressed: () => setState(() => selectedRiskLevel = 'high'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedRiskLevel == 'high' ? Colors.red : Colors.transparent,
                      foregroundColor: selectedRiskLevel == 'high' ? Colors.white : Colors.white70,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                      side: BorderSide(
                        color: Colors.red,
                        width: 1.2,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 12),
                    ),
                    child: Text("High (${highRisk.length})", overflow: TextOverflow.ellipsis),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: ElevatedButton(
                    onPressed: () => setState(() => selectedRiskLevel = 'medium'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedRiskLevel == 'medium' ? Colors.orange : Colors.transparent,
                      foregroundColor: selectedRiskLevel == 'medium' ? Colors.white : Colors.white70,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                      side: BorderSide(
                        color: Colors.orange,
                        width: 1.2,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 12),
                    ),
                    child: Text("Medium (${mediumRisk.length})", overflow: TextOverflow.ellipsis),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: ElevatedButton(
                    onPressed: () => setState(() => selectedRiskLevel = 'low'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedRiskLevel == 'low' ? Colors.green : Colors.transparent,
                      foregroundColor: selectedRiskLevel == 'low' ? Colors.white : Colors.white70,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                      side: BorderSide(
                        color: Colors.green,
                        width: 1.2,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 12),
                    ),
                    child: Text("Low (${lowRisk.length})", overflow: TextOverflow.ellipsis),
                  ),
                ),
              ],
            ),

            Expanded(
              child: getFilteredPermissions().isEmpty
                  ? const Center(child: Text("No permissions found.", style: TextStyle(color: Colors.white70)))
                  : ListView.builder(
                itemCount: getFilteredPermissions().length,
                itemBuilder: (context, index) {
                  final permission = getFilteredPermissions()[index];
                  final permissionName = getPermissionName(permission);
                  IconData icon;
                  Color bg;
                  if (highRisk.contains(permission)) {
                    icon = Icons.warning_amber_rounded;
                    bg = Colors.red.withOpacity(0.23);
                  } else if (mediumRisk.contains(permission)) {
                    icon = Icons.security;
                    bg = Colors.orange.withOpacity(0.23);
                  } else {
                    icon = Icons.check_circle;
                    bg = Colors.green.withOpacity(0.23);
                  }
                  return Card(
                    color: bg,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: Icon(icon, color: Colors.white),
                      title: Text(permissionName, style: const TextStyle(color: Colors.white)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}



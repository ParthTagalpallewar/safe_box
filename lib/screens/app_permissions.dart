
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/theme.dart';
class AppPermissionsPage extends StatefulWidget {
  @override
  _AppPermissionsPageState createState() => _AppPermissionsPageState();
}

class _AppPermissionsPageState extends State<AppPermissionsPage> {
  static const platform = MethodChannel("app_info_channel");
  List<Map<String, dynamic>> _apps = [];

  @override
  void initState() {
    super.initState();
    _fetchInstalledApps();
  }

  Future<void> _fetchInstalledApps() async {
    try {
      final String result = await platform.invokeMethod("getInstalledApps");
      final List<dynamic> jsonData = json.decode(result);

      setState(() {
        _apps = jsonData.map((app) => Map<String, dynamic>.from(app)).toList();
      });
    } catch (e) {
      print("Failed to fetch apps: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF150050), // Background color
      appBar: AppBar(
        title: const Text(
          "Installed Apps",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        backgroundColor: Color(0xFF150050), // Matching background
        elevation: 0, // Removes shadow under the AppBar
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: _apps.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        // Left-right margin
        child: ListView.builder(
          itemCount: _apps.length,
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          itemBuilder: (context, index) {
            final app = _apps[index];

            return Container(
              margin: const EdgeInsets.only(bottom: 12), // Space between tiles
              decoration: BoxDecoration(
                color: const Color(0xFF3E1F92),
                // Tile background color
                borderRadius: BorderRadius.circular(12),
                // Rounded corners
                border: Border.all(color: Colors.white54, width: 1),
                // Border color
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                leading: ClipOval(
                  child: app['icon'] != null && app['icon'].isNotEmpty
                      ? Image.memory(
                    base64Decode(app['icon']),
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  )
                      : const Icon(
                      Icons.android, size: 40, color: Colors.white),
                ),
                title: Text(
                  app['appName'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Text color
                  ),
                  maxLines: 1, // Restrict to a single line
                  overflow: TextOverflow.ellipsis, // Show "..." if it overflows
                ),
                subtitle: Text(
                  app['packageName'],
                  style: const TextStyle(
                      color: Colors.white70), // Subtitle color
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios, // Forward arrow icon
                  color: Colors.white,
                  size: 16, // Smaller size
                ),
                onTap: () {
                  // Add navigation or action if needed
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
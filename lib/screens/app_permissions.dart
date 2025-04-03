
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
        title: Text(
          "Installed Apps & Permissions",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF150050), // Matching background
        elevation: 0, // Removes shadow under the AppBar
      ),
      body: _apps.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: EdgeInsets.symmetric(horizontal: 16), // Left-right margin
        child: ListView.builder(
          itemCount: _apps.length,
          padding: EdgeInsets.only(top: 10, bottom: 10),
          itemBuilder: (context, index) {
            final app = _apps[index];

            return Container(
              margin: EdgeInsets.only(bottom: 12), // Space between tiles
              decoration: BoxDecoration(
                color: Color(0xFF3E1F92), // Tile background color
                borderRadius: BorderRadius.circular(12), // Rounded corners
                border: Border.all(color: Colors.white54, width: 1), // Border color
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: ExpansionTile(
                iconColor: Colors.white, // Arrow icon color when expanded
                collapsedIconColor: Colors.white, // Arrow icon color when collapsed
                leading: ClipOval(
                  child: app['icon'] != null && app['icon'].isNotEmpty
                      ? Image.memory(
                    base64Decode(app['icon']),
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  )
                      : Icon(Icons.android, size: 40, color: Colors.white),
                ),
                title: Text(
                  app['appName'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Text color
                  ),
                ),
                subtitle: Text(
                  app['packageName'],
                  style: TextStyle(color: Colors.white70), // Subtitle color
                ),
                children: (app['permissions'] as List)
                    .map<Widget>((perm) => ListTile(
                  title: Text(
                    perm,
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ))
                    .toList(),
              ),
            );
          },
        ),
      ),
    );
  }
}





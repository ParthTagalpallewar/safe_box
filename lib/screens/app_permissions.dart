import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/theme.dart';

class AppPermissionsPage extends StatefulWidget {
  final List<Map<String, dynamic>>? filteredApps;

  const AppPermissionsPage({Key? key, this.filteredApps}) : super(key: key);

  @override
  _AppPermissionsPageState createState() => _AppPermissionsPageState();
}

class _AppPermissionsPageState extends State<AppPermissionsPage> {
  static const platform = MethodChannel("app_info_channel");
  List<Map<String, dynamic>> _apps = [];

  @override
  void initState() {
    super.initState();
    if (widget.filteredApps != null) {
      _apps = widget.filteredApps!;
    } else {
      _fetchInstalledApps();
    }
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
      backgroundColor: const Color(0xFF150050),
      appBar: AppBar(
        title: const Text(
          "Installed Apps",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        backgroundColor: const Color(0xFF150050),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _apps.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                itemCount: _apps.length,
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                itemBuilder: (context, index) {
                  final app = _apps[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3E1F92),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white54, width: 1),
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
                            : const Icon(Icons.android,
                                size: 40, color: Colors.white),
                      ),
                      title: Text(
                        app['appName'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        app['packageName'],
                        style: const TextStyle(color: Colors.white70),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 16,
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

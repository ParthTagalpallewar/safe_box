import 'package:flutter/material.dart';
import '../theme/theme.dart';
import './app_permissions.dart';
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        backgroundColor: AppColors.primary,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const SizedBox(
              height: 200,
            ),
            const Divider(
              color: AppColors.secondary,
            ),
            ListTile(
              title:
                  const Text('All Apps', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AppPermissionsPage()),
                );
              },
            ),
            ListTile(
              title: const Text('Notification',
                  style: TextStyle(color: Colors.white)),
              onTap: () {},
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: AppColors.secondary),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      body: Container(
        color: AppColors.primary,
        width: double.infinity,
        child: const Center(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: "Hello! ",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

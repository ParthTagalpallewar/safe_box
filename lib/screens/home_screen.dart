import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        backgroundColor: Colors.deepPurple[900],
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Colors.deepPurple[700]),
              accountName: const Text("Profile Name",
                  style: TextStyle(color: Colors.white)),
              accountEmail: null,
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white24,
                child: const Text("Profile Picture",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.white)),
              ),
            ),
            ListTile(
              title:
                  const Text('All Apps', style: TextStyle(color: Colors.white)),
              onTap: () {},
            ),
            ListTile(
              title:
                  const Text('All Apps', style: TextStyle(color: Colors.white)),
              onTap: () {},
            ),
            ListTile(
              title:
                  const Text('All Apps', style: TextStyle(color: Colors.white)),
              onTap: () {},
            ),
            ListTile(
              title:
                  const Text('All Apps', style: TextStyle(color: Colors.white)),
              onTap: () {},
            ),
            const Divider(color: Colors.white54),
            ListTile(
              title:
                  const Text('Settings', style: TextStyle(color: Colors.white)),
              onTap: () {},
            ),
            ListTile(
              title:
                  const Text('Logout', style: TextStyle(color: Colors.white)),
              onTap: () {},
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple[900],
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.yellow),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.campaign, color: Colors.yellow),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        color: Colors.deepPurple[900],
        width: double.infinity,
        height: double.infinity,
        child: const Center(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                    text: "Hello!, ",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.yellow)),
                TextSpan(
                    text: "Name",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

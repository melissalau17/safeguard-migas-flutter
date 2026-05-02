
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              color: Colors.red.shade900,
              child: const ListTile(
                title: Text("Global Risk Status"),
                subtitle: Text("CRITICAL"),
              ),
            ),
            const SizedBox(height: 16),
            const ListTile(
              title: Text("Fault 4 - Reactor Cooling"),
              trailing: Text("87%"),
            ),
            const ListTile(
              title: Text("Fault 11 - Feed Loss"),
              trailing: Text("61%"),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      children: [
        // Profile Section
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: colorScheme.primary,
                child: Text(
                  user?.username.substring(0, 1).toUpperCase() ?? 'U',
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.username ?? '',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      user?.email ?? '',
                      style: TextStyle(
                        color: colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(),

        // Settings List
        Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return ListTile(
              leading: Icon(
                themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              ),
              title: const Text('Dark Mode'),
              trailing: Switch(
                value: themeProvider.isDarkMode,
                onChanged: (value) {
                  themeProvider.toggleTheme();
                },
              ),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.notifications),
          title: const Text('Notifications'),
          trailing: Switch(
            value: true,
            onChanged: (value) {
              // TODO: Implement notifications

            },
          ),
        ),
        ListTile(
          leading: const Icon(Icons.language),
          title: const Text('Language'),
          trailing: const Text('English'),
          onTap: () {
            // TODO: Implement language selection
          },
        ),
        ListTile(
          leading: const Icon(Icons.info),
          title: const Text('About'),
          onTap: () {
            showAboutDialog(
              context: context,
              applicationName: 'Task & Weather App',
              applicationVersion: '1.0.0',
              applicationLegalese: '© 2025 quocbao.dev',
            );
          },
        ),
        const Divider(),

        // Logout Button
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Logout'),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Logout'),
                content: const Text('Are you sure you want to logout?'),
                actions: [
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  TextButton(
                    child: const Text('Logout'),
                    onPressed: () {
                      context.read<AuthProvider>().logout();
                      Navigator.pop(context);
                      //
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

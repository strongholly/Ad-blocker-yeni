import 'package:flutter/material.dart';

class SettingsSheet extends StatelessWidget {
  final VoidCallback onReset;

  const SettingsSheet({super.key, required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Ayarlar',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('İstatistikleri Sıfırla'),
            onTap: () {
              onReset();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('İstatistikler sıfırlandı')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Hakkında'),
            subtitle: const Text('Pro Ad Blocker v1.0'),
            onTap: () {
              Navigator.pop(context);
              showAboutDialog(
                context: context,
                applicationName: 'Pro Ad Blocker',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2025 - Güçlü reklam engelleme',
              );
            },
          ),
        ],
      ),
    );
  }
}

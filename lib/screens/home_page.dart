// lib/screens/home_page.dart
import 'package:flutter/material.dart';
import '../services/ad_blocker_service.dart';
import '../services/storage_services.dart';
import '../widgets/search_bar.dart';
import '../widgets/settings_sheet.dart';
import '../widgets/stats_dialog.dart';
import 'browser_view.dart';
import 'welcome_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final AdBlockerService _adBlocker = AdBlockerService();
  final StorageService _storage = StorageService();

  bool _showBrowser = false;
  String _currentUrl = '';
  int _sessionBlockedCount = 0;

  void _onSearch(String query) {
    if (query.isEmpty) return;
    String url = query.startsWith('http') 
        ? query 
        : query.contains('.') ? 'https://$query' 
        : 'https://www.google.com/search?q=${Uri.encodeComponent(query)}';
    setState(() {
      _showBrowser = true;
      _currentUrl = url;
    });
  }

  void _showStats() => showDialog(
    context: context,
    builder: (_) => StatsDialog(adBlocker: _adBlocker, sessionCount: _sessionBlockedCount),
  );

  void _showSettings() => showModalBottomSheet(
    context: context,
    builder: (_) => SettingsSheet(
      onReset: () async {
        await _storage.clearAll();
        await _adBlocker.initialize();
        setState(() => _sessionBlockedCount = 0);
      },
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pro Ad Blocker'),
        actions: [
          IconButton(icon: const Icon(Icons.bar_chart), onPressed: _showStats),
          Row(
            children: [
              const Text('Engelle', style: TextStyle(fontSize: 13)),
              Switch(
                value: _adBlocker.isEnabled,
                onChanged: (value) async {
                  await _adBlocker.setEnabled(value);
                  setState(() {});
                },
              ),
            ],
          ),
          IconButton(icon: const Icon(Icons.settings), onPressed: _showSettings),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          SearchBarWidget(
            controller: _searchController,
            onSearch: _onSearch,
          ),
          Expanded(
            child: _showBrowser
                ? BrowserView(
                    url: _currentUrl,
                    adBlocker: _adBlocker,
                    onBlocked: () => setState(() => _sessionBlockedCount++),
                    onHomePressed: () => setState(() => _showBrowser = false),
                  )
                : WelcomeView(adBlocker: _adBlocker),
          ),
        ],
      ),
    );
  }
}

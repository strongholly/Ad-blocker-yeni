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
  String? _selectedBrowser;

  @override
  void initState() {
    super.initState();
    _loadSavedBrowser();
  }

  Future<void> _loadSavedBrowser() async {
    final saved = await _storage.getSelectedBrowser();
    if (saved != null && mounted) {
      setState(() => _selectedBrowser = saved);
    }
  }

// 🔹 Arama yapıldığında
void _onSearch(String query) {
  // ✅ Tarayıcıya göre ana sayfa belirle
  String defaultHome;
  switch (_selectedBrowser) {
    case 'Opera':
      defaultHome = 'https://www.opera.com';
      break;
    case 'Yandex':
      defaultHome = 'https://yandex.com';
      break;
    case 'Tor':
      defaultHome = 'https://check.torproject.org';
      break;
    default:
      defaultHome = 'https://www.google.com';
  }

  // ✅ Boş aramada ilgili tarayıcının ana sayfasına git
  if (query.isEmpty) {
    setState(() {
      _showBrowser = true;
      _currentUrl = defaultHome;
    });
    return;
  }

  // ✅ Normal arama davranışı
  String url = query.startsWith('http')
      ? query
      : query.contains('.')
          ? 'https://$query'
          : 'https://www.google.com/search?q=${Uri.encodeComponent(query)}';

  setState(() {
    _showBrowser = true;
    _currentUrl = url;
  });
}


  // 🔹 Tarayıcı seçimi butonları
  Widget _buildBrowserSelector() {
    final browsers = ['Chrome', 'Opera', 'Yandex', 'Tor'];
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      children: browsers.map((browser) {
        final selected = _selectedBrowser == browser;
        return ChoiceChip(
          label: Text(browser),
          selected: selected,
          selectedColor: Colors.green.shade300,
          onSelected: (_) async {
            setState(() => _selectedBrowser = browser);
            await _storage.saveSelectedBrowser(browser);
          },
        );
      }).toList(),
    );
  }

  void _showStats() => showDialog(
        context: context,
        builder: (_) => StatsDialog(
          adBlocker: _adBlocker,
          sessionCount: _sessionBlockedCount,
        ),
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
        title: Text('Pro Ad Blocker ${_selectedBrowser != null ? "(${_selectedBrowser!})" : ""}'),
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
          const SizedBox(height: 8),
          _buildBrowserSelector(),
          const SizedBox(height: 8),
          SearchBarWidget(
            controller: _searchController,
            onSearch: _onSearch,
          ),
          Expanded(
            child: _showBrowser
                ? BrowserView(
                    url: _currentUrl,
                    adBlocker: _adBlocker,
                    selectedBrowser: _selectedBrowser, // 👈 önemli kısım
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

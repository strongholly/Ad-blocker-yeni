import 'package:flutter/material.dart';
import '../services/ad_blocker_service.dart';
import '../services/storage_services.dart';
import '../widgets/search_bar.dart';
import '../widgets/settings_sheet.dart';
import '../widgets/stats_dialog.dart';
import '../services/browser_service.dart';
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
    if (mounted) {
      setState(() {
        _selectedBrowser = saved ?? 'Chrome';
      });
      if (saved == null) {
        await _storage.saveSelectedBrowser('Chrome');
      }
    }
  }

      // 🆕 Tarayıcıya göre ana sayfa döndür
String _getDefaultHome(String? browser) {
  switch (browser) {
    case 'Yandex':
      return 'https://yandex.com.tr';
    case 'Brave':
      return 'https://search.brave.com/';
    case 'DuckDuckGo':
      return 'https://duckduckgo.com/?q=';
    default:
      return 'https://www.google.com';
  }
}



     // 🆕 Tarayıcıya göre arama motoru döndür
String _getSearchEngine(String? browser) {
  switch (browser) {
    case 'Yandex':
      return 'https://yandex.com.tr/search/?text=';
    case 'Brave':
      return 'https://search.brave.com/search?q=';
    case 'DuckDuckGo':
      return 'https://duckduckgo.com/?q=';
    default:
      return 'https://www.google.com/search?q=';
  }
}


  void _onSearch(String query) {
    String defaultHome = _getDefaultHome(_selectedBrowser);
    String searchEngine = _getSearchEngine(_selectedBrowser);

    if (query.trim().isEmpty) {
      setState(() {
        _showBrowser = true;
        _currentUrl = defaultHome;
      });
      return;
    }

    String url;
    if (query.startsWith('http')) {
      url = query;
    } else if (query.contains('.') && !query.contains(' ')) {
      url = 'https://$query';
    } else {
      url = '$searchEngine${Uri.encodeComponent(query)}';
    }

    setState(() {
      _showBrowser = true;
      _currentUrl = url;
    });
  }

  Widget _buildBrowserSelector() {
    final browserService = BrowserService();
    final browsers = browserService.browsers;

    return SizedBox(
      height: 90,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        children: browsers.entries.map((entry) {
          final browser = entry.key;
          final info = entry.value;
          final selected = _selectedBrowser == browser;

          return GestureDetector(
            onTap: () async {
              // 🆕 Önce browser'ı kapat
              setState(() => _showBrowser = false);
              
              // 🆕 Tarayıcıyı değiştir
              setState(() => _selectedBrowser = browser);
              await _storage.saveSelectedBrowser(browser);
              
              // 🆕 Yeni tarayıcının ana sayfasını URL olarak ayarla
              String newHome = _getSearchEngine(browser);
              setState(() => _currentUrl = newHome);
              
              // 🆕 Kısa bir gecikme sonra tekrar aç
              await Future.delayed(const Duration(milliseconds: 100));
              
              // 🆕 Yeni tarayıcıyla aç
              if (mounted) {
                setState(() => _showBrowser = true);
              }
            },
           child: Container(
            width: 90,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: selected ? info.color.withOpacity(0.2) : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? info.color : Colors.transparent,
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 🔹 Eğer özel iconWidget varsa onu göster, yoksa Icon widget’ı kullan
                if (info.iconWidget != null)
                  SizedBox(
                    height: 32,
                    width: 32,
                    child: info.iconWidget,
                  )
                else if (info.icon != null)
                  Icon(
                    info.icon,
                    size: 32,
                    color: info.color,
                  ),
                const SizedBox(height: 6),
                Text(
                  info.name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    color: selected ? info.color : Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )


          );
        }).toList(),
      ),
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
    final browserService = BrowserService();
    final selectedBrowserInfo = _selectedBrowser != null
        ? browserService.browsers[_selectedBrowser!]
        : null;
    final browserColor = selectedBrowserInfo?.color ?? Colors.grey;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: browserColor.withOpacity(0.15),
        title: Text(
          'Pro Ad Blocker ${_selectedBrowser != null ? "($_selectedBrowser!)" : ""}',
        ),
        actions: [
          IconButton(icon: const Icon(Icons.bar_chart), onPressed: _showStats),
          Row(
            children: [
              const Text('Engelle', style: TextStyle(fontSize: 13)),
              Switch(
                value: _adBlocker.isEnabled,
                activeColor: browserColor,
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
          Container(
            color: browserColor.withOpacity(0.15),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                _buildBrowserSelector(),
                const SizedBox(height: 8),
                SearchBarWidget(
                  controller: _searchController,
                  onSearch: _onSearch,
                ),
              ],
            ),
          ),

          Expanded(
            child: _showBrowser
                ? BrowserView(
                    key: ValueKey('${_selectedBrowser}_$_currentUrl'), // 🆕 Hem browser hem URL ile key
                    url: _currentUrl,
                    adBlocker: _adBlocker,
                    selectedBrowser: _selectedBrowser,
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
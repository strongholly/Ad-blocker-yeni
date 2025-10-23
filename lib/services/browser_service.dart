import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class BrowserService {
  static final BrowserService _instance = BrowserService._internal();
  factory BrowserService() => _instance;
  BrowserService._internal();

  // 🔹 Tarayıcı bilgileri
// 🔹 Tarayıcı bilgileri
// 🔹 Tarayıcı bilgileri
// Tarayıcı bilgileri (gerçek logolu)


// 🔹 Tarayıcı bilgileri (SVG ikonlara renk veriyoruz)
Map<String, BrowserInfo> get browsers => {
  'Chrome': BrowserInfo(
    name: 'Chrome',
    color: const Color(0xFF4285F4), // 🔵 Chrome Mavisi
    iconWidget: SvgPicture.asset(
      'assets/icons/googlechrome.svg',
      colorFilter: const ColorFilter.mode(Color(0xFF4285F4), BlendMode.srcIn),
    ),
  ),
  'DuckDuckGo': BrowserInfo(
    name: 'DuckDuckGo',
    color: const Color(0xFFFF6600), // 🟠 DuckDuckGo turuncusu
    iconWidget: SvgPicture.asset(
      'assets/icons/duckduckgo.svg',
      colorFilter: const ColorFilter.mode(Color(0xFFFF6600), BlendMode.srcIn),
    ),
  ),
  'Brave': BrowserInfo(
    name: 'Brave',
    color: const Color(0xFFFB542B), // 🦁 Brave turuncusu
    iconWidget: SvgPicture.asset(
      'assets/icons/brave.svg',
      colorFilter: const ColorFilter.mode(Color(0xFFFB542B), BlendMode.srcIn),
    ),
  ),
  'Yandex': BrowserInfo(
    name: 'Yandex',
    color: Colors.amber.shade400, // 🟡 Yandex sarısı
    iconWidget: SvgPicture.asset(
      'assets/icons/yandexcloud.svg',
      colorFilter: ColorFilter.mode(Colors.amber.shade400, BlendMode.srcIn),
    ),
  ),
};





  InAppWebViewSettings getSettings(String browser) {
    String userAgent = _getUserAgent(browser);
    bool incognito = browser == "Tor";
    ForceDark darkMode = browser == "Tor" ? ForceDark.ON : ForceDark.OFF;

    return InAppWebViewSettings(
      userAgent: userAgent,
      incognito: incognito,
      forceDark: darkMode,
      javaScriptEnabled: true,
      mediaPlaybackRequiresUserGesture: false,
      // 🔹 Tor için ek güvenlik ayarları
      cacheEnabled: browser != "Tor",
      clearCache: browser == "Tor",
    );
  }

  String _getUserAgent(String browser) {
    switch (browser) {
      case "Chrome":
        return "Mozilla/5.0 (Linux; Android 11; Pixel 5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.5735.130 Mobile Safari/537.36";
      case "Operaa":
        return "Mozilla/5.0 (Linux; Android 10; VOG-L29) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.101 Mobile Safari/537.36 OPR/61.1.3076.56625";
      case "Yandex":
        return "Mozilla/5.0 (Linux; Android 12; CPH2205) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 YaBrowser/23.3.3.86.00 Mobile Safari/537.36";
      case "Tor":
        return "Mozilla/5.0 (Windows NT 10.0; rv:102.0) Gecko/20100101 Firefox/102.0";
      default:
        return "Mozilla/5.0 (Linux; Android 11) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114 Mobile Safari/537.36";
    }
  }
}

class BrowserInfo {
  final String name;
  final Color color;
  final IconData? icon;       // Material Icons fallback
  final Widget? iconWidget;   // SVG veya resim logolar

  BrowserInfo({
    required this.name,
    required this.color,
    this.icon,
    this.iconWidget,
  });
}

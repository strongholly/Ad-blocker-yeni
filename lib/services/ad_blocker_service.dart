// lib/services/ad_blocker_service.dart

import '../models/filter_rule.dart';
import '../models/blocked_request.dart';
import '../utils/constants.dart';
import '../services//storage_services.dart';

class AdBlockerService {
  final StorageService _storage = StorageService();
  
  List<FilterRule> _filterRules = [];
  List<String> _whitelist = [];
  BlockedStats _stats = BlockedStats();
  bool _isEnabled = true;

  // Singleton pattern
  static final AdBlockerService _instance = AdBlockerService._internal();
  factory AdBlockerService() => _instance;
  AdBlockerService._internal();

  // Initialize
  Future<void> initialize() async {
    _isEnabled = await _storage.getAdBlockerEnabled();
    _stats = await _storage.getStats();
    _whitelist = await _storage.getWhitelist();
    _loadFilterRules();
  }

  void _loadFilterRules() {
    _filterRules.clear();

    // Domain bazlı filtreler
    for (var domain in AdBlockerConstants.getAllAdDomains()) {
      _filterRules.add(FilterRule(
        pattern: domain,
        type: FilterType.domain,
        description: 'Ad domain: $domain',
      ));
    }

    // Keyword bazlı filtreler
    final keywords = [
      '/ads/',
      '/ad/',
      '/advert/',
      '/banner/',
      '/sponsor/',
      'advertisement',
      'reklam',
      'reklamlar',
    ];

    for (var keyword in keywords) {
      _filterRules.add(FilterRule(
        pattern: keyword,
        type: FilterType.keyword,
        description: 'Keyword: $keyword',
      ));
    }

    // Regex patterns
    _filterRules.add(FilterRule(
      pattern: r'/ad[sx]?[0-9]*/i',
      type: FilterType.regex,
      description: 'Ad pattern with numbers',
    ));
  }

  // URL engellenmeli mi kontrol et
  bool shouldBlockUrl(String url, String sourceUrl) {
    if (!_isEnabled) return false;

    // Whitelist kontrolü
    for (var whitelistDomain in _whitelist) {
      if (sourceUrl.contains(whitelistDomain)) {
        return false;
      }
    }

    // Filter rules kontrolü
    for (var rule in _filterRules) {
      if (rule.matches(url)) {
        _recordBlockedRequest(url, sourceUrl, rule.description);
        return true;
      }
    }

    return false;
  }

  void _recordBlockedRequest(String url, String sourceUrl, String reason) {
    // İstatistikleri güncelle
    String domain = _extractDomain(url);
    _stats.addBlockedRequest(domain);
    _storage.saveStats(_stats);
  }

  String _extractDomain(String url) {
    try {
      Uri uri = Uri.parse(url);
      return uri.host;
    } catch (e) {
      return 'unknown';
    }
  }
String getAdBlockingScript() {
  return """
  (function() {
    // --- CSS tabanlı hızlı gizleme ---
    const style = document.createElement('style');
    style.innerHTML = \`
      /* Genel reklam sınıfları */
      iframe[src*="ads"],
      iframe[src*="adservice"],
      iframe[src*="doubleclick"],
      iframe[src*="googlesyndication"],
      iframe[src*="adform"],
      iframe[src*="adnxs"],
      iframe[src*="googleads"],
    iframe[src*="doubleclick"],
    iframe[src*="googlesyndication"],
    iframe[src*="banner"],
    iframe[src*="reklam"],
    iframe[src*="adservice"],
    ins.adsbygoogle,
    div[id*="google_ads"],
    div[class*="google_ads"],
    div[id*="bannerReklam"],
    div[class*="bannerReklam"],
    div[id*="adzone"],
    div[class*="adzone"],
    div[id*="reklamAlan"],
    div[class*="reklamAlan"] {
      display: none !important;
      visibility: hidden !important;
      height: 0 !important;
      width: 0 !important;
      opacity: 0 !important;

      div[class*="ad-"],
      div[id*="ad-"],
      div[class*="advert"],
      div[id*="advert"],
      div[class*="sponsor"],
      div[id*="sponsor"],
      div[class*="banner"],
      div[id*="banner"],
      .adsbygoogle,
      .sponsored,
      .reklam,
      [id*="reklam"],
      [class*="reklam"],
      [id*="ad_container"],
      [class*="ad_container"],
      ytd-display-ad-renderer,
      ytd-promoted-sparkles-web-renderer,
      ytd-action-companion-ad-renderer,
      ytd-companion-slot-renderer,
      ytd-promoted-video-renderer {
        display: none !important;
        visibility: hidden !important;
        height: 0 !important;
        width: 0 !important;
        pointer-events: none !important;
        opacity: 0 !important;
      }

      /* Türk haber siteleri */
      .reklam-kutu, .ad-widget, .adBox, .bannerReklam, .ad_area, .adzone, .ad-slot, 
      .commercial-banner, .right-banner, .left-banner, .sticky-ads {
        display: none !important;
      }

      /* Popup ve katman reklamlar */
      .popup-ad, .overlay-ad, .fullscreen-ad, #adblock-popup, .ad-overlay, .ads-popup {
        display: none !important;
      }

      /* Boş alan temizleme */
      body:has(div[class*="reklam"], div[id*="ad-"], iframe[src*="ads"]) {
        padding: 0 !important;
        margin: 0 !important;
      }
    \`;
    document.head.appendChild(style);

    // --- Aktif temizlik fonksiyonu ---
    function removeAds() {
      // YouTube özel
      if (location.hostname.includes('youtube.com')) {
        try {
          const skip = document.querySelector('.ytp-ad-skip-button, .ytp-skip-ad-button, .ytp-ad-skip-button-modern');
          if (skip) skip.click();

          const overlays = document.querySelectorAll('.ytp-ad-overlay-container, .ytp-ad-text-overlay');
          overlays.forEach(e => e.remove());

          const adModules = document.querySelectorAll(
            'ytd-display-ad-renderer, ytd-promoted-sparkles-web-renderer, ytd-action-companion-ad-renderer'
          );
          adModules.forEach(e => e.remove());

          const video = document.querySelector('video');
          const adOverlay = document.querySelector('.ytp-ad-player-overlay');
          if (video && adOverlay) {
            video.playbackRate = 16;
            video.currentTime = video.duration;
          }
        } catch (e) {}
      }

      // Genel reklam seçiciler
      const selectors = [
        '[class*="ad-"]', '[id*="ad-"]',
        '[class*="advert"]', '[id*="advert"]',
        '[class*="banner"]', '[id*="banner"]',
        '[class*="sponsor"]', '[id*="sponsor"]',
        '[class*="reklam"]', '[id*="reklam"]',
        '[class*="popup"]', '[id*="popup"]',
        '.overlay-ad', '.fullscreen-ad'
      ];

      selectors.forEach(selector => {
        try {
          document.querySelectorAll(selector).forEach(el => {
            if (el.offsetHeight > 40 || el.offsetWidth > 40) el.remove();
          });
        } catch(e){}
      });

      // iframe reklamları
      document.querySelectorAll('iframe').forEach(iframe => {
        const src = iframe.src || '';
        const adWords = ['ads', 'doubleclick', 'googlesyndication', 'banner', 'reklam', 'adservice'];
        if (adWords.some(w => src.includes(w))) iframe.remove();
      });

      // Boş kalan container’ları kaldır
      document.querySelectorAll('div').forEach(div => {
        if (div.children.length === 0 && (div.id + div.className).match(/ad|reklam|banner|sponsor/i)) {
          div.remove();
        }
      });
    }

    // --- İlk temizlik ---
    removeAds();

    // --- Sürekli izleme ---
    setInterval(removeAds, 300); // daha sık çalışsın
    document.addEventListener('visibilitychange', function() {
      if (!document.hidden) {
        removeAds(); // sekmeye geri dönünce tekrar temizle
      }
    });

    const observer = new MutationObserver(() => removeAds());
    observer.observe(document.body, { childList: true, subtree: true });

  })();
  """;
}


  // Getters
  bool get isEnabled => _isEnabled;
  BlockedStats get stats => _stats;
  
  // Setters
  Future<void> setEnabled(bool enabled) async {
    _isEnabled = enabled;
    await _storage.setAdBlockerEnabled(enabled);
  }

  Future<void> addToWhitelist(String domain) async {
    if (!_whitelist.contains(domain)) {
      _whitelist.add(domain);
      await _storage.saveWhitelist(_whitelist);
    }
  }

  Future<void> removeFromWhitelist(String domain) async {
    _whitelist.remove(domain);
    await _storage.saveWhitelist(_whitelist);
  }

  List<String> get whitelist => _whitelist;
}
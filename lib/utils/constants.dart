// lib/utils/constants.dart

class AdBlockerConstants {
  // Türkiye'deki reklam ağları
  static const List<String> turkishAdNetworks = [
    // Türk reklam ağları
    'adform.net',
    'serving-sys.com',
    'adocean.pl',
    'gemius.pl',
    'reklamz.com',
    'adtoma.com',
    'pozitron.com',
    'adverticum.net',
    'reklamstore.com',
    'admatic.com.tr',
    'netvent.com.tr',
    'admixer.net',
    'adnext.fr',
    'criteo.com',
    'criteo.net',
    'taboola.com',
    'outbrain.com',
    'mgid.com',
    'revcontent.com',
    'smartadserver.com',
    'appnexus.com',
    'adtech.de',
    'advertising.com',
    'casalemedia.com',
    'contextweb.com',
    'emxdgt.com',
    'indexww.com',
    'openx.net',
    'pubmatic.com',
    'rhythmone.com',
    'rubiconproject.com',
    'sharethrough.com',
    'teads.tv',
    'undertone.com',
    'yieldmo.com',
    'adcolony.com',
  ];

  // Google reklam servisleri
  static const List<String> googleAds = [
    'doubleclick.net',
    'googlesyndication.com',
    'googleadservices.com',
    'google-analytics.com',
    'googletagmanager.com',
    'googletagservices.com',
    'googlesyndication.com',
    'ad.doubleclick.net',
    'static.doubleclick.net',
    'pagead2.googlesyndication.com',
    'tpc.googlesyndication.com',
    'video-stats.l.google.com',
    'adservice.google.com',
  ];

  // Facebook ve sosyal medya tracking
  static const List<String> socialTracking = [
    'facebook.com/tr',
    'facebook.net',
    'connect.facebook.net',
    'pixel.facebook.com',
    'analytics.facebook.com',
    'twitter.com/i/adsct',
    'ads-twitter.com',
    't.co/i/adsct',
    'analytics.twitter.com',
    'static.ads-twitter.com',
    'linkedin.com/px',
    'snap.licdn.com',
    'ads.linkedin.com',
  ];

  // Genel reklam domainleri
  static const List<String> generalAdDomains = [
    'ads.',
    'ad.',
    'adservice.',
    'advertising.',
    'adserver.',
    'adclick.',
    'adbrite.',
    'admob.',
    'adsystem.',
    'adtech.',
    'advert.',
    'ad-',
    'banner',
    'popup',
    'sponsor',
    '/ads/',
    '/ad/',
    'pagead',
    'adsbygoogle',
    'advertisement',
    'banners/',
    '/banner/',
    'adimg',
    'adimage',
  ];

  // YouTube reklam selektörleri
  static const List<String> youtubeAdSelectors = [
    '.video-ads',
    '.ytp-ad-module',
    '.ytp-ad-overlay-container',
    '.ytp-ad-text-overlay',
    'ytd-display-ad-renderer',
    'ytd-promoted-sparkles-web-renderer',
    'ytd-ad-slot-renderer',
    'ytd-player-legacy-desktop-watch-ads-renderer',
    'ytd-in-feed-ad-layout-renderer',
    'ytd-banner-promo-renderer',
    'ytd-video-masthead-ad-v3-renderer',
    '.ytd-compact-promoted-item-renderer',
    '.ytd-promoted-video-renderer',
    '#player-ads',
    '.ytp-ad-player-overlay',
    '.ytp-ad-skip-button-container',
  ];

  // Türk haber siteleri için özel selektörler
  static const List<String> turkishNewsSiteSelectors = [
    // Sahibinden.com
    '.classified-detail-banner',
    '#bannerTop',
    '#bannerBottom',
    '.banner-container',
    
    // Genel haber siteleri
    '.advertisement',
    '.adv',
    '.reklam',
    '.rek',
    '[class*="reklam"]',
    '[id*="reklam"]',
    '[class*="advertisement"]',
    '[id*="advertisement"]',
    '[class*="banner"]',
    '[id*="banner"]',
    '.sponsored',
    '[class*="sponsored"]',
    '.native-ad',
    '[class*="native-ad"]',
    '.promoted',
    '[class*="promoted"]',
    
    // Hürriyet
    '.ads-space',
    '.advertisement-zone',
    
    // Sözcü
    '.adv-container',
    
    // Milliyet
    '.box-ads',
    
    // Sabah
    '.adbox',
    
    // Habertürk
    '.ads-area',
  ];

  // CSS için kombinasyonlar
  static String getCSSSelectors() {
    return youtubeAdSelectors.join(',\n') + 
           ',\n' + 
           turkishNewsSiteSelectors.join(',\n');
  }

  // Tüm domainleri birleştir
  static List<String> getAllAdDomains() {
    return [
      ...turkishAdNetworks,
      ...googleAds,
      ...socialTracking,
      ...generalAdDomains,
    ];
  }
}
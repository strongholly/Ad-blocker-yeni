// lib/models/blocked_request.dart

class BlockedRequest {
  final String url;
  final DateTime timestamp;
  final String sourceUrl;
  final String reason;

  BlockedRequest({
    required this.url,
    required this.timestamp,
    required this.sourceUrl,
    required this.reason,
  });

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'timestamp': timestamp.toIso8601String(),
      'sourceUrl': sourceUrl,
      'reason': reason,
    };
  }

  factory BlockedRequest.fromJson(Map<String, dynamic> json) {
    return BlockedRequest(
      url: json['url'],
      timestamp: DateTime.parse(json['timestamp']),
      sourceUrl: json['sourceUrl'],
      reason: json['reason'],
    );
  }
}

class BlockedStats {
  int totalBlocked;
  int blockedToday;
  int blockedThisWeek;
  Map<String, int> blockedByDomain;

  BlockedStats({
    this.totalBlocked = 0,
    this.blockedToday = 0,
    this.blockedThisWeek = 0,
    Map<String, int>? blockedByDomain,
  }) : blockedByDomain = blockedByDomain ?? {};

  void addBlockedRequest(String domain) {
    totalBlocked++;
    blockedToday++;
    blockedThisWeek++;
    blockedByDomain[domain] = (blockedByDomain[domain] ?? 0) + 1;
  }

  void resetDaily() {
    blockedToday = 0;
  }

  void resetWeekly() {
    blockedThisWeek = 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'totalBlocked': totalBlocked,
      'blockedToday': blockedToday,
      'blockedThisWeek': blockedThisWeek,
      'blockedByDomain': blockedByDomain,
    };
  }

  factory BlockedStats.fromJson(Map<String, dynamic> json) {
    return BlockedStats(
      totalBlocked: json['totalBlocked'] ?? 0,
      blockedToday: json['blockedToday'] ?? 0,
      blockedThisWeek: json['blockedThisWeek'] ?? 0,
      blockedByDomain: Map<String, int>.from(json['blockedByDomain'] ?? {}),
    );
  }
}
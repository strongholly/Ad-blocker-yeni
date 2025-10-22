// lib/models/filter_rule.dart

enum FilterType {
  domain,      // Domain bazlı engelleme
  keyword,     // Kelime bazlı engelleme
  regex,       // Regex pattern
  cssSelector, // CSS seçici
}

class FilterRule {
  final String pattern;
  final FilterType type;
  final bool isEnabled;
  final String description;

  FilterRule({
    required this.pattern,
    required this.type,
    this.isEnabled = true,
    this.description = '',
  });

  bool matches(String url) {
    if (!isEnabled) return false;

    switch (type) {
      case FilterType.domain:
        return url.contains(pattern);
      
      case FilterType.keyword:
        return url.toLowerCase().contains(pattern.toLowerCase());
      
      case FilterType.regex:
        try {
          return RegExp(pattern).hasMatch(url);
        } catch (e) {
          return false;
        }
      
      case FilterType.cssSelector:
        return false; // CSS selectors are handled differently
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'pattern': pattern,
      'type': type.toString(),
      'isEnabled': isEnabled,
      'description': description,
    };
  }

  factory FilterRule.fromJson(Map<String, dynamic> json) {
    return FilterRule(
      pattern: json['pattern'],
      type: FilterType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => FilterType.domain,
      ),
      isEnabled: json['isEnabled'] ?? true,
      description: json['description'] ?? '',
    );
  }
}
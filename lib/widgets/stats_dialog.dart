import 'package:flutter/material.dart';
import '../services/ad_blocker_service.dart';

class StatsDialog extends StatelessWidget {
  final AdBlockerService adBlocker;
  final int sessionCount;

  const StatsDialog({
    super.key,
    required this.adBlocker,
    required this.sessionCount,
  });

  @override
  Widget build(BuildContext context) {
    final stats = adBlocker.stats;
    final domains = stats.blockedByDomain.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return AlertDialog(
      title: const Text('📊 Reklam Engelleme İstatistikleri'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _row('Bu oturumda', sessionCount.toString()),
          _row('Bugün', stats.blockedToday.toString()),
          _row('Bu hafta', stats.blockedThisWeek.toString()),
          _row('Toplam', stats.totalBlocked.toString()),
          const Divider(),
          const Text('En çok engellenen:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          ...domains.take(5).map((e) => Text('${e.key}: ${e.value}')),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Kapat')),
      ],
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(label), Text(value, style: const TextStyle(color: Colors.blue))],
        ),
      );
}

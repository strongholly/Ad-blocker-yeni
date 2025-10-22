import 'package:flutter/material.dart';
import '../services/ad_blocker_service.dart';
import '../widgets/stat_card.dart';
import '../widgets/feature_item.dart';

class WelcomeView extends StatelessWidget {
  final AdBlockerService adBlocker;
  const WelcomeView({super.key, required this.adBlocker});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shield_outlined,
              size: 100,
              color: adBlocker.isEnabled ? Colors.green : Colors.grey[400],
            ),
            const SizedBox(height: 24),
            const Text(
              'Pro Ad Blocker',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Türkiye\'nin en güçlü reklam engelleyicisi'),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                StatCard(
                  label: 'Bugün',
                  value: adBlocker.stats.blockedToday.toString(),
                  icon: Icons.today,
                  color: Colors.blue,
                ),
                StatCard(
                  label: 'Toplam',
                  value: adBlocker.stats.totalBlocked.toString(),
                  icon: Icons.block,
                  color: Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 32),
            _statusCard(adBlocker),
            const SizedBox(height: 32),
            const FeatureItem(text: '✅ YouTube reklam engelleme'),
            const FeatureItem(text: '✅ Türk haber sitelerinde çalışır'),
            const FeatureItem(text: '✅ Banner ve popup engelleme'),
            const FeatureItem(text: '✅ Otomatik reklam atlama'),
            const FeatureItem(text: '✅ Detaylı istatistikler'),
          ],
        ),
      ),
    );
  }

  Widget _statusCard(AdBlockerService adBlocker) {
    final active = adBlocker.isEnabled;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: active ? Colors.green[50] : Colors.red[50],
        border: Border.all(color: active ? Colors.green : Colors.red, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(active ? Icons.verified_user : Icons.shield_outlined,
              color: active ? Colors.green : Colors.red, size: 32),
          const SizedBox(width: 16),
          Text(
            active ? 'Koruma Aktif ✓' : 'Koruma Kapalı ✗',
            style: TextStyle(
              color: active ? Colors.green[900] : Colors.red[900],
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}

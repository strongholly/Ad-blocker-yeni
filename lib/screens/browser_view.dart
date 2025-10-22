import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../services/ad_blocker_service.dart';
import '../services/browser_service.dart';

class BrowserView extends StatefulWidget {
  final String url;
  final AdBlockerService adBlocker;
  final VoidCallback onBlocked;
  final VoidCallback onHomePressed;
  final String? selectedBrowser; // 🔹 eklendi

  const BrowserView({
    super.key,
    required this.url,
    required this.adBlocker,
    required this.onBlocked,
    required this.onHomePressed,
    this.selectedBrowser, // 🔹 eklendi
  });

  @override
  State<BrowserView> createState() => _BrowserViewState();
}

class _BrowserViewState extends State<BrowserView> {
  InAppWebViewController? _controller;
  double _progress = 0;

  @override
  Widget build(BuildContext context) {
    final browserSettings = widget.selectedBrowser != null
        ? BrowserService().getSettings(widget.selectedBrowser!)
        : InAppWebViewSettings(javaScriptEnabled: true);

    return Stack(
      children: [
        InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri(widget.url)),
          initialSettings: browserSettings, // 👈 tarayıcı moduna göre ayar
          onWebViewCreated: (controller) => _controller = controller,
          onLoadStart: (controller, url) {
            setState(() => _progress = 0);
          },
          onProgressChanged: (controller, progress) async {
            setState(() => _progress = progress / 100);
            if (widget.adBlocker.isEnabled && progress > 40) {
              await controller.evaluateJavascript(
                source: widget.adBlocker.getAdBlockingScript(),
              );
            }
          },
          onLoadStop: (controller, url) async {
            if (widget.adBlocker.isEnabled) {
              await Future.delayed(const Duration(milliseconds: 800));
              await controller.evaluateJavascript(
                source: widget.adBlocker.getAdBlockingScript(),
              );
            }
          },
        ),

        if (_progress < 1)
          LinearProgressIndicator(
            value: _progress,
            backgroundColor: Colors.grey[200],
            valueColor:
                const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
          ),

        // 🔹 Navigasyon butonları
        Positioned(
          bottom: 16,
          right: 16,
          child: Column(
            children: [
              _navBtn(Icons.arrow_back, () async {
                if (await _controller?.canGoBack() ?? false) {
                  await _controller?.goBack();
                }
              }),
              const SizedBox(height: 8),
              _navBtn(Icons.arrow_forward, () async {
                if (await _controller?.canGoForward() ?? false) {
                  await _controller?.goForward();
                }
              }),
              const SizedBox(height: 8),
              _navBtn(Icons.refresh, () => _controller?.reload()),
              const SizedBox(height: 8),
              _navBtn(Icons.home, widget.onHomePressed, color: Colors.green),
            ],
          ),
        ),
      ],
    );
  }

  Widget _navBtn(IconData icon, VoidCallback onTap, {Color? color}) {
    return FloatingActionButton(
      heroTag: icon.toString(),
      mini: true,
      backgroundColor: color ?? Colors.blue,
      onPressed: onTap,
      child: Icon(icon),
    );
  }
}

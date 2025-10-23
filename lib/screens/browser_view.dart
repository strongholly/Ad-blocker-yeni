import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../services/ad_blocker_service.dart';
import '../services/browser_service.dart';

class BrowserView extends StatefulWidget {
  final String url;
  final AdBlockerService adBlocker;
  final VoidCallback onBlocked;
  final VoidCallback onHomePressed;
  final String? selectedBrowser;

  const BrowserView({
    super.key,
    required this.url,
    required this.adBlocker,
    required this.onBlocked,
    required this.onHomePressed,
    this.selectedBrowser,
  });

  @override
  State<BrowserView> createState() => _BrowserViewState();
}

class _BrowserViewState extends State<BrowserView> {
  InAppWebViewController? _controller;
  double _progress = 0;
  String? _currentUrl;

  @override
  void didUpdateWidget(BrowserView oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 🆕 URL değiştiyse yeni URL'e git
    if (oldWidget.url != widget.url && _controller != null) {
      _controller!.loadUrl(
        urlRequest: URLRequest(url: WebUri(widget.url)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final browserService = BrowserService();
    final browserInfo = widget.selectedBrowser != null 
        ? browserService.browsers[widget.selectedBrowser!]
        : null;

    final browserSettings = widget.selectedBrowser != null
        ? browserService.getSettings(widget.selectedBrowser!)
        : InAppWebViewSettings(javaScriptEnabled: true);

    return Stack(
      children: [
        InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri(widget.url)),
          initialSettings: browserSettings,
          onWebViewCreated: (controller) => _controller = controller,
          onLoadStart: (controller, url) {
            setState(() {
              _progress = 0;
              _currentUrl = url?.toString();
            });
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
            setState(() => _currentUrl = url?.toString());
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
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
          ),

        Positioned(
          top: 8,
          left: 8,
          right: 80,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                if (browserInfo != null) ...[
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: browserInfo.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      browserInfo.icon,
                      color: browserInfo.color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    browserInfo.name,
                    style: TextStyle(
                      color: browserInfo.color,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 1,
                    height: 20,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(width: 12),
                ],
                
                Expanded(
                  child: Text(
                    _getDisplayUrl(_currentUrl ?? widget.url),
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
                if (_currentUrl?.startsWith('https://') ?? false)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Icon(
                      Icons.lock,
                      size: 14,
                      color: Colors.green[700],
                    ),
                  ),
              ],
            ),
          ),
        ),

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

  String _getDisplayUrl(String url) {
    try {
      final uri = Uri.parse(url);
      String domain = uri.host;
      
      if (domain.startsWith('www.')) {
        domain = domain.substring(4);
      }
      
      if (uri.path.isNotEmpty && uri.path != '/') {
        String path = uri.path;
        if (path.length > 20) {
          path = '${path.substring(0, 17)}...';
        }
        return '$domain$path';
      }
      
      return domain;
    } catch (e) {
      return url;
    }
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
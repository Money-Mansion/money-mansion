import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../services/privacy_service.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  late WebViewController _webViewController;
  late Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
    _loadFuture = _loadPrivacyPolicy();
  }

  void _initializeWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            print('Privacy policy loaded');
          },
          onWebResourceError: (WebResourceError error) {
            print('WebView error: ${error.description}');
            _retryLoad();
          },
          onNavigationRequest: (NavigationRequest request) {
            // Prevent navigation to external links
            if (!request.url.startsWith('about:')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..setUserAgent('Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36');
  }

  Future<void> _loadPrivacyPolicy() async {
    try {
      final htmlContent = await PrivacyService.getPrivacyPolicyHtml();
      if (mounted) {
        _webViewController.loadHtmlString(htmlContent);
      }
    } catch (e) {
      print('Error loading privacy policy: $e');
      if (mounted) {
        _retryLoad();
      }
    }
  }

  void _retryLoad() {
    setState(() {
      _loadFuture = _loadPrivacyPolicy();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        elevation: 0,
      ),
      body: FutureBuilder<void>(
        future: _loadFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return Stack(
            fit: StackFit.expand,
            children: [
              WebViewWidget(
                controller: _webViewController,
              ),
              if (snapshot.hasError)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading Privacy Policy',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _retryLoad,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

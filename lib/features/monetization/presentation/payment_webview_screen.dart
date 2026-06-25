import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final String checkoutUrl;
  final String successRedirectUrl;
  final String title;
  final Function(String) onSuccess;

  const PaymentWebViewScreen({
    required this.checkoutUrl,
    required this.successRedirectUrl,
    required this.title,
    required this.onSuccess,
    super.key,
  });

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    
    // Initialize modern WebView controller matching webview_flutter 4.x
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            _checkUrlRedirect(url);
          },
          onNavigationRequest: (NavigationRequest request) {
            _checkUrlRedirect(request.url);
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  void _checkUrlRedirect(String url) {
    if (url.contains(widget.successRedirectUrl)) {
      // Execute success callback and close WebView page
      Navigator.of(context).pop();
      widget.onSuccess(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}

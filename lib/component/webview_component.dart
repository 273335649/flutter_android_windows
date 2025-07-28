import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebViewComponent extends StatefulWidget {
  final String initialUrl;
  const WebViewComponent({Key? key, required this.initialUrl}) : super(key: key);

  @override
  State<WebViewComponent> createState() => _WebViewComponentState();
}

class _WebViewComponentState extends State<WebViewComponent> {
  InAppWebViewController? _webViewController;

  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(widget.initialUrl)),
      onWebViewCreated: (controller) {
        _webViewController = controller;
      },
    );
  }
} 
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:solution/components/loader.dart';
import 'package:solution/config/strings.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  bool isLoading = true;

  _loadHtmlFromAssets() async {
    final futures = await Future.wait([
      rootBundle.loadString('assets/app.html'),
      _controller.future,
    ]);

    String fileText = futures[0] as String;
    WebViewController controller = futures[1] as WebViewController;

    Uri url = Uri.dataFromString(fileText,
        mimeType: 'text/html', encoding: Encoding.getByName('utf-8'));

    controller.loadUrl(url.toString());
  }

  void _onWebViewCreated(WebViewController webViewController) {
    _controller.complete(webViewController);
    _loadHtmlFromAssets();
  }

  void _onProgress(int progress) {
    if (progress >= 100) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(APP_TITLE),
        actions: [
          if (isLoading)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Loader(),
            )
        ],
      ),
      body: WebView(
        onWebViewCreated: _onWebViewCreated,
        onProgress: _onProgress,
      ),
    );
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:solution/components/loader.dart';
import 'package:solution/config/strings.dart';
import 'package:solution/models/trade.dart';
import 'package:solution/services/finhub.service.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _finhubService = FinhubService();
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

  void _sendUpdateToWebview(Trade trade) async {
    WebViewController controller = await _controller.future;
    final date = DateTime.fromMillisecondsSinceEpoch(trade.timestamp);
    final formattedDate = DateFormat('MM/dd/yyyy - hh:mm a').format(date);

    controller.evaluateJavascript('''
      nativeMessageHandler({
        action: 'APP_UPDATE_DATA',
        data: [
          {
            lastPrice: ${trade.price},
            name: "${trade.symbol}",
            timestamp: "$formattedDate",
            volume: ${trade.volume},
          }
        ]
      })
      ''');
  }

  JavascriptChannel _appMessageHandler(BuildContext context) {
    return JavascriptChannel(
      name: 'appMessageHandler',
      onMessageReceived: (JavascriptMessage message) {
        //TODO: handle resetState(): message.action APP_STATE_RESET;
      },
    );
  }

  _initWebsocketChannel() {
    _finhubService.subscribe('BINANCE:BTCUSDT');

    _finhubService.stream.listen((event) {
      dynamic message = jsonDecode(event);

      if (message['type'] == 'trade') {
        for (var item in message['data']) {
          Trade trade = Trade.fromMap(item);
          _sendUpdateToWebview(trade);
        }
      }
    });
  }

  void _onProgress(int progress) {
    if (progress >= 100) {
      setState(() {
        isLoading = false;
      });

      _initWebsocketChannel();
    }
  }

  @override
  void dispose() {
    _finhubService.unsubscribe('BINANCE:BTCUSDT');
    _finhubService.close();
    super.dispose();
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
        javascriptMode: JavascriptMode.unrestricted,
        javascriptChannels: <JavascriptChannel>{
          _appMessageHandler(context),
        },
      ),
    );
  }
}

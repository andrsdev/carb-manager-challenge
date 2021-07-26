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
  final _controller = Completer<WebViewController>();
  final _symbols = [
    'BINANCE:BTCUSDT',
    'BINANCE:ETHUSDT',
    'AAPL',
    'AMZN',
    'TSLA'
  ];

  List<Trade> _trades = [];
  bool isLoading = true;

  /// Completes the webview controller
  void _onWebViewCreated(WebViewController webViewController) {
    _controller.complete(webViewController);
    _loadHtmlFromAssets();
  }

  /// Loads the webview url from the assets html file.
  void _loadHtmlFromAssets() async {
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

  /// Constructs and executes the script to update the webview with the list
  /// of [trades].
  Future _sendUpdateToWebview(List<Trade> trades) async {
    WebViewController controller = await _controller.future;
    String script = "";

    for (var trade in trades) {
      final date = DateTime.fromMillisecondsSinceEpoch(trade.timestamp);
      final formattedDate = DateFormat('MM/dd/yyyy - hh:mm a').format(date);
      script += '''
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
        });
      ''';
    }

    controller.evaluateJavascript(script);
  }

  /// Subscribes the websocket to multiple symbols, listen to events and
  /// stores trades messages in memory.
  void _initWebsocketSubscriptions() {
    for (var item in _symbols) {
      _finhubService.subscribe(item);
    }

    _finhubService.stream.listen((event) {
      dynamic message = jsonDecode(event);

      if (message['type'] == 'trade') {
        setState(() {
          for (var item in message['data']) {
            Trade trade = Trade.fromMap(item);
            _trades.add(trade);
          }
        });
      }
    });
  }

  /// Initializes the websocket subscriptions when the webview completes loading.
  void _onProgress(int progress) {
    if (progress >= 100) {
      setState(() {
        isLoading = false;
      });

      _initWebsocketSubscriptions();
    }
  }

  /// Cleans the previous data from the webview, calls the update of
  /// new data and clears the existing trade items saved in memory.
  void _onRefersh() async {
    WebViewController controller = await _controller.future;
    controller.evaluateJavascript('''
      nativeMessageHandler({
        action: 'APP_RESET',
      })
      ''');

    await _sendUpdateToWebview(_trades);

    setState(() {
      _trades.clear();
    });
  }

  @override
  void dispose() {
    /// Cleaning websocket subscriptions and closing it.
    for (var item in _symbols) {
      _finhubService.unsubscribe(item);
    }
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onRefersh,
        label: Text('New: ${_trades.length}'),
        icon: Icon(
          Icons.refresh,
        ),
      ),
    );
  }
}

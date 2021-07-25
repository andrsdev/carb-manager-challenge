import 'dart:async';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class FinhubService {
  WebSocketChannel? _channel;
  final String baseUrl = 'wss://ws.finnhub.io';
  final String apiKey = dotenv.env['FINHUB_API_KEY']!;

  FinhubService() {
    this._channel =
        WebSocketChannel.connect(Uri.parse('$baseUrl?token=$apiKey'));
  }

  void subscribe(String symbol) {
    _channel!.sink.add('{"type":"subscribe","symbol":"$symbol"}');
  }

  void unsubscribe(String symbol) {
    _channel!.sink.add('{"type":"unsubscribe","symbol":"$symbol"}');
  }

  void close() {
    _channel!.sink.close();
  }

  Stream<dynamic> get stream {
    return _channel!.stream;
  }
}

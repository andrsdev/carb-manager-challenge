import 'dart:async';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Service that works as wrapper for https://finnhub.io/docs/api/websocket-trades.
/// Contains the basic functionality to interact with the websocket,
/// including initalizing the connection and subscribing to symbols.
class FinhubService {
  WebSocketChannel? _channel;
  final String baseUrl = 'wss://ws.finnhub.io';
  final String apiKey = dotenv.env['FINHUB_API_KEY']!;

  FinhubService() {
    this._channel =
        WebSocketChannel.connect(Uri.parse('$baseUrl?token=$apiKey'));
  }

  /// Subscribes the service to the given [symbol]
  void subscribe(String symbol) {
    _channel!.sink.add('{"type":"subscribe","symbol":"$symbol"}');
  }

  /// Unsubscribes the service to the given [symbol]
  void unsubscribe(String symbol) {
    _channel!.sink.add('{"type":"unsubscribe","symbol":"$symbol"}');
  }

  /// Closes the websocket connection.
  void close() {
    _channel!.sink.close();
  }

  /// Exposes the websocket channel stream.
  Stream<dynamic> get stream {
    return _channel!.stream;
  }
}

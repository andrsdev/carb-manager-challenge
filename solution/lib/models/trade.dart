class Trade {
  String symbol;
  double price;
  int timestamp;
  double volume;

  Trade({
    required this.symbol,
    required this.price,
    required this.timestamp,
    required this.volume,
  });

  Map<String, dynamic> toMap() {
    return {
      'symbol': this.symbol,
      'price': this.price,
      'timestamp': this.timestamp,
      'volume': this.volume,
    };
  }

  factory Trade.fromMap(Map<String, dynamic> data) {
    return Trade(
      symbol: data['s'],
      price: data['p']?.toDouble(),
      timestamp: data['t']?.toInt(),
      volume: data['v']?.toDouble(),
    );
  }
}

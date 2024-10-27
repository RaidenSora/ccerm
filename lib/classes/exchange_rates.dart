class ExchangeRates {
  final bool success;
  final int timestamp;
  final String base;
  final String date;
  final Map<String, double> rates;

  ExchangeRates({
    required this.success,
    required this.timestamp,
    required this.base,
    required this.date,
    required this.rates,
  });

  factory ExchangeRates.fromJson(Map<String, dynamic> json) {
    return ExchangeRates(
      success: json['success'],
      timestamp: json['timestamp'],
      base: json['base'],
      date: json['date'],
      rates: (json['rates'] as Map<String, dynamic>).map(
        (key, value) =>
            MapEntry(key, (value is int) ? value.toDouble() : value as double),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'timestamp': timestamp,
      'base': base,
      'date': date,
      'rates': rates,
    };
  }
}

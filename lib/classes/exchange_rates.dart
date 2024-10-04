//Exchange rates class para magkaron ng structure yung data galing sa API
class ExchangeRates {
  final Meta meta;
  final Map<String, Currency> data;

  ExchangeRates({required this.meta, required this.data});

  factory ExchangeRates.fromJson(Map<String, dynamic> json) {
    return ExchangeRates(
      meta: Meta.fromJson(json['meta']),
      data: (json['data'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, Currency.fromJson(value)),
      ),
    );
  }
}

//Meta class para sa meta data galing sa api
class Meta {
  final String lastUpdatedAt;

  Meta({required this.lastUpdatedAt});

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      lastUpdatedAt: json['last_updated_at'],
    );
  }
}

//Currency class para sa currency data like value and code galing sa api
class Currency {
  final String code;
  final double value;

  Currency({required this.code, required this.value});

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      code: json['code'],
      value: double.parse(json['value'].toString()),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:currency/classes/exchange_rates.dart';
import 'package:currency/env/env.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CCERM',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'CCERM Home page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<ExchangeRates> futureExchangeRates;

  @override
  void initState() {
    super.initState();
    futureExchangeRates = fetchExchangeRates();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(),
    );
  }

  Future<ExchangeRates> fetchExchangeRates() async {
    final response = await http.get(Uri.parse(
        'https://api.currencyapi.com/v3/latest?apikey=${Env.apiKey}'));

    if (response.statusCode == 200) {
      return ExchangeRates.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to load convertions');
    }
  }
}

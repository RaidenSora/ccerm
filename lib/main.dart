import 'dart:convert';
import 'dart:async';

import 'package:currency/classes/exchange_rates.dart';
import 'package:currency/env/env.dart';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:workmanager/workmanager.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:country_flags/country_flags.dart';
import 'package:intl/intl.dart';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) {
    print("Native called background task: $task");
    return Future.value(true);
  });
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().initialize(callbackDispatcher, isInDebugMode: true);

  Workmanager().registerPeriodicTask(
    "periodic-task-identifier",
    "fetchExchangeRatePeriodicTask",
    frequency: const Duration(minutes: 15),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
  Timer? _debouncer;
  String? selectedValue1 = "PHP";
  String? selectedValue2 = "USD";
  TextEditingController amountTextField1 = TextEditingController();
  TextEditingController amountTextField2 = TextEditingController();
  final List<DropdownMenuItem<String>> items = [
    DropdownMenuItem(
      value: 'PHP',
      child: Row(
        children: [
          CountryFlag.fromCountryCode(
            'PH',
            shape: const RoundedRectangle(3),
            height: 23,
            width: 35,
          ),
          Container(
            margin: const EdgeInsets.only(left: 10),
            child: Text(
              "PHP",
              style: GoogleFonts.poppins(),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 5),
            child: Text(
              "- Philippine Peso",
              style: GoogleFonts.poppins(
                color: const Color(0xff636363),
              ),
            ),
          ),
        ],
      ),
    ),
    DropdownMenuItem(
      value: 'USD',
      child: Row(
        children: [
          CountryFlag.fromCountryCode(
            'US',
            shape: const RoundedRectangle(3),
            height: 23,
            width: 35,
          ),
          Container(
            margin: const EdgeInsets.only(left: 10),
            child: Text(
              "USD",
              style: GoogleFonts.poppins(),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 5),
            child: Text(
              "- US Dollar",
              style: GoogleFonts.poppins(
                color: const Color(0xff636363),
              ),
            ),
          ),
        ],
      ),
    ),
    DropdownMenuItem(
      value: 'CAD',
      child: Row(
        children: [
          CountryFlag.fromCountryCode(
            'CAD',
            shape: const RoundedRectangle(3),
            height: 23,
            width: 35,
          ),
          Container(
            margin: const EdgeInsets.only(left: 10),
            child: Text(
              "CAD",
              style: GoogleFonts.poppins(),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 5),
            child: Text(
              "- Canadian Dollar",
              style: GoogleFonts.poppins(
                color: const Color(0xff636363),
              ),
            ),
          ),
        ],
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();
    amountTextField1.text = "${getCurrency(selectedValue1!)} 0.00";
    amountTextField2.text = "${getCurrency(selectedValue2!)} 0.00";
    futureExchangeRates = fetchExchangeRates();
  }

  @override
  void dispose() {
    super.dispose();
    _debouncer?.cancel();
  }

  _debounce(String unFormattedAmount, String have, String want,
      int fromTextField) async {
    if (_debouncer?.isActive ?? false) _debouncer?.cancel();
    _debouncer = Timer(const Duration(milliseconds: 500), () {
      unFormattedAmount = unFormattedAmount.trim();
      if (unFormattedAmount.length >= 2) {
        String formattedAmount = unFormattedAmount.substring(1);

        futureExchangeRates.then((onValue) {
          double? amount = double.parse(formattedAmount);
          double? haveRate = onValue.data[have]?.value;
          double? wantRate = onValue.data[want]?.value;
          double haveAmount, wantAmount;
          haveAmount = amount / haveRate!;
          wantAmount = haveAmount * wantRate!;
          if (fromTextField == 1) {
            amountTextField2.text =
                "${getCurrency(want)} ${wantAmount.toStringAsFixed(2)}";
          } else {
            amountTextField1.text =
                "${getCurrency(want)} ${wantAmount.toStringAsFixed(2)}";
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * .45,
                color: const Color.fromARGB(255, 48, 44, 159),
              ),
            ],
          ),
          SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.fromLTRB(40, 50, 40, 40),
              child: Column(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "CCERM",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 25,
                              ),
                            ),
                            Text(
                              "Currency Converter and\nExchange Rate Monitor",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.settings,
                            weight: 10,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.07),
                            spreadRadius: 5,
                            blurRadius: 40,
                            offset: const Offset(0, 0),
                          ),
                        ]),
                    margin: const EdgeInsets.only(top: 70),
                    padding: const EdgeInsets.all(25),
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            "Currency\nConverter",
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                              height: 1,
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 10),
                          padding: const EdgeInsets.symmetric(
                              vertical: 0, horizontal: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFFE7E7E7),
                            ),
                          ),
                          width: MediaQuery.of(context).size.width,
                          child: DropdownButton(
                            underline: Container(),
                            iconSize: 24,
                            isExpanded: true,
                            onChanged: (value) {
                              setState(() {
                                selectedValue1 = value;
                                amountTextField1.text =
                                    "${getCurrency(value!)} ";
                                ;
                              });
                            },
                            value: selectedValue1,
                            items: items,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 10),
                          padding: const EdgeInsets.symmetric(
                              vertical: 0, horizontal: 20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: const Color(0xffF5F5F5),
                            border: Border.all(
                              color: const Color(0xFFE7E7E7),
                            ),
                          ),
                          width: MediaQuery.of(context).size.width,
                          child: TextField(
                            enableInteractiveSelection: false,
                            onChanged: (value) {
                              setState(() {
                                if (value.isNotEmpty &&
                                    value[0] != getCurrency(selectedValue1!)) {
                                  amountTextField1.clear();
                                  amountTextField1.text =
                                      "${getCurrency(selectedValue1!)} $value";
                                }
                              });

                              _debounce(
                                  value, selectedValue1!, selectedValue2!, 1);
                            },
                            controller: amountTextField1,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 10),
                          padding: const EdgeInsets.symmetric(
                              vertical: 0, horizontal: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFFE7E7E7),
                            ),
                          ),
                          width: MediaQuery.of(context).size.width,
                          child: DropdownButton(
                            underline: Container(),
                            iconSize: 24,
                            isExpanded: true,
                            onChanged: (value) {
                              setState(() {
                                selectedValue2 = value;
                                amountTextField2.text =
                                    "${getCurrency(value!)} ";
                              });
                            },
                            value: selectedValue2,
                            items: items,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 10),
                          padding: const EdgeInsets.symmetric(
                              vertical: 0, horizontal: 20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: const Color(0xffF5F5F5),
                            border: Border.all(
                              color: const Color(0xFFE7E7E7),
                            ),
                          ),
                          width: MediaQuery.of(context).size.width,
                          child: TextField(
                            enableInteractiveSelection: false,
                            onChanged: (value) {
                              setState(() {
                                if (value.isNotEmpty &&
                                    value[0] != getCurrency(selectedValue2!)) {
                                  amountTextField2.clear();
                                  amountTextField2.text =
                                      "${getCurrency(selectedValue2!)} $value";
                                }
                              });

                              _debounce(
                                  value, selectedValue2!, selectedValue1!, 2);
                            },
                            controller: amountTextField2,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                            ),
                            // style: GoogleFonts.poppins(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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

void updateAndroidWidget(String count) {
  HomeWidget.saveWidgetData("text", count);
  HomeWidget.updateWidget(
    androidName: "ExchangeRateWidget",
  );
}

String getCurrency(String currencyCode) {
  var format = NumberFormat.simpleCurrency(name: currencyCode);
  return format.currencySymbol;
}

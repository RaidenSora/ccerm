import 'dart:convert';
import 'dart:async';

//import for test data
import 'package:currency/settings.dart';
import 'package:flutter/services.dart' show rootBundle;

//import dependencies at classes na kelangan ng app, like yung workmanager para sa background process etc.
import 'package:currency/classes/exchange_rates.dart';
import 'package:currency/env/env.dart';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:workmanager/workmanager.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:country_flags/country_flags.dart';
import 'package:intl/intl.dart';
import 'package:currency/currencies/currencies.dart';
import 'package:string_validator/string_validator.dart';

//function code ng background task
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) {
    print("Native called background task: $task");
    return Future.value(true);
  });
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().initialize(callbackDispatcher, isInDebugMode: true);

  //nag define tayo ng background process with duration of 15 minutes (background code will execute every 15 minutes)
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
  //defining variables and initial values na ididisplay ng application
  late Future<ExchangeRates> futureExchangeRates;
  Timer? _debouncer;
  String? selectedValue1 = "USD";
  String? selectedValue2 = "PHP";
  String? exchangeRatesBase = "USD";
  String? exchangeRateAddInitialValue = "AED";
  TextEditingController amountTextField1 = TextEditingController();
  TextEditingController amountTextField2 = TextEditingController();
  List<String> exchangeRatesRecords = ["KWD", "CAD", "PHP"];
  List<String?> exchangeRatesValues = [];

  //code kung san nilalagay isa isa yung value mula sa currencies.dart na file
  final List<DropdownMenuItem<String>> items =
      currencyCodes.asMap().entries.map((entry) {
    int index = entry.key;
    String currency = entry.value;

    //eto yung structure ang laman ng drop down menu ng mga currencies
    return DropdownMenuItem(
      value: currency,
      child: Row(
        children: [
          CountryFlag.fromCountryCode(
            countryCodes[index],
            shape: const RoundedRectangle(3),
            height: 23,
            width: 35,
          ),
          Container(
            margin: const EdgeInsets.only(left: 10),
            child: Text(
              currency,
              style: GoogleFonts.poppins(),
            ),
          ),
          Flexible(
            child: Container(
              margin: const EdgeInsets.only(left: 5),
              child: Text(
                "- ${currencyNames[index]}",
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  color: const Color(0xff636363),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }).toList();

  @override
  void initState() {
    super.initState();
    //nilalagay natin yung initial value sa textfield1 and texfeild2
    amountTextField1.text = "${getCurrency(selectedValue1!)} 0.00";
    amountTextField2.text = "${getCurrency(selectedValue2!)} 0.00";
    futureExchangeRates = fetchExchangeRates();
    initializeExchangeRates();
  }

  @override
  void dispose() {
    super.dispose();
    _debouncer?.cancel();
  }

  //function para malagay natin yung currency code sa unahan ng textfield
  void addCurrencyCode(
      String value, TextEditingController input, String selectedValue) {
    setState(() {
      if (isNumeric(value) || isFloat(value)) {
        input.clear();
        input.text = "${getCurrency(selectedValue!)} $value";
      }
    });
  }

  //function para ma swap yung currency sa currency converter
  void swapCurrencies() {
    setState(() {
      String? oldSelectedValue1, oldSelectedValue2;
      String oldAmount1, oldAmount2;
      oldSelectedValue1 = selectedValue1;
      oldSelectedValue2 = selectedValue2;
      oldAmount1 = amountTextField1.text;
      oldAmount2 = amountTextField2.text;

      selectedValue1 = oldSelectedValue2;
      selectedValue2 = oldSelectedValue1;
      amountTextField1.text = oldAmount2;
      amountTextField2.text = oldAmount1;
    });
  }

  //this will be executed pagkatapos mag type ng user ng value sa currency converter
  _debounce(
      String unCleanAmount, String have, String want, int fromTextField) async {
    if (_debouncer?.isActive ?? false) _debouncer?.cancel();
    _debouncer = Timer(const Duration(milliseconds: 500), () {
      String cleanedAmount = removeLettersAndExtraDots(unCleanAmount);

      if (cleanedAmount.isNotEmpty) {
        futureExchangeRates.then((onValue) {
          //value from user
          double? amount = double.parse(cleanedAmount);
          //exchange rate value ng currency na meron ka
          double? haveRate = onValue.data[have]?.value;
          //exchange rate value ng currency na gusto mong i-convert
          double? wantRate = onValue.data[want]?.value;
          double haveAmount, wantAmount;
          //computation ng value from user divided by exchange rate ng currency na meron ka
          haveAmount = amount / haveRate!;
          //computation ng value ng currency na gusto mong i-convert
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

  //fini-filter out nito yung mga dots tsaka yung character para maging valid na double or integer yung value
  String removeLettersAndExtraDots(String input) {
    String cleaned = input.replaceAll(RegExp(r'[^0-9.]'), '');
    List<String> parts = cleaned.split('.');
    if (parts.length <= 1) {
      return cleaned;
    }
    return '${parts[0]}.${parts.sublist(1).join('')}';
  }

  void initializeExchangeRates() async {
    await futureExchangeRates.then((onValue) {
      exchangeRatesValues.clear();
      for (var value in exchangeRatesRecords) {
        double? baseValue = onValue.data[exchangeRatesBase]?.value;
        double? targetValue = onValue.data[value]?.value;
        double haveAmount = 1 / baseValue!;
        double? exchangeRateFinalValue = haveAmount * targetValue!;

        setState(() {
          exchangeRatesValues.add(exchangeRateFinalValue.toStringAsFixed(2));
        });
      }
    });
  }

  //ito yung UI Design structure ng application
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
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Settings()),
                            );
                          },
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
                      ],
                    ),
                    margin: const EdgeInsets.only(top: 70),
                    padding: const EdgeInsets.fromLTRB(25, 25, 25, 10),
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
                            menuMaxHeight: 500,
                            underline: Container(),
                            iconSize: 24,
                            isExpanded: true,
                            onChanged: (value) {
                              setState(() {
                                selectedValue1 = value;
                                amountTextField1.text =
                                    "${getCurrency(value!)} 0.00";
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
                              addCurrencyCode(
                                  value, amountTextField1, selectedValue1!);

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
                            menuMaxHeight: 500,
                            underline: Container(),
                            iconSize: 24,
                            isExpanded: true,
                            onChanged: (value) {
                              setState(() {
                                selectedValue2 = value;
                                amountTextField2.text =
                                    "${getCurrency(value!)} 0.00";
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
                              addCurrencyCode(
                                  value, amountTextField2, selectedValue2!);

                              _debounce(
                                  value, selectedValue2!, selectedValue1!, 2);
                            },
                            controller: amountTextField2,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 10),
                          width: MediaQuery.of(context).size.width,
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            onPressed: swapCurrencies,
                            icon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.swap_horiz_outlined,
                                  color: Color(0xff0900FF),
                                ),
                                Container(
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  child: Text(
                                    "SWAP",
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xff0900FF),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 40),
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.fromLTRB(20, 15, 20, 0),
                          child: Text(
                            "Exchange\nRates",
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                              height: 1,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => showDialog<String>(
                            context: context,
                            builder: (BuildContext context) => Dialog(
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.fromLTRB(
                                          15, 15, 15, 5),
                                      child: Text(
                                        "Select Base Currency",
                                        style: GoogleFonts.poppins(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.fromLTRB(
                                          10, 10, 10, 0),
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
                                        menuMaxHeight: 500,
                                        underline: Container(),
                                        iconSize: 24,
                                        isExpanded: true,
                                        onChanged: (value) {
                                          setState(() {
                                            exchangeRatesBase = value;
                                          });
                                          initializeExchangeRates();
                                          Navigator.pop(context);
                                        },
                                        value: exchangeRatesBase,
                                        items: items,
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Close'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: const Color(0xff302C9F),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.07),
                                  spreadRadius: 5,
                                  blurRadius: 40,
                                  offset: const Offset(0, 0),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                CountryFlag.fromCountryCode(
                                  countryCodes[currencyCodes
                                      .indexOf(exchangeRatesBase!)],
                                  shape: const RoundedRectangle(3),
                                  height: 23,
                                  width: 35,
                                ),
                                Container(
                                  margin: const EdgeInsets.only(left: 15),
                                  child: Text(
                                    exchangeRatesBase!,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 17,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  "${getCurrency(exchangeRatesBase!)} 1",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        for (var item in exchangeRatesRecords)
                          Container(
                            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                            child: Row(
                              children: [
                                CountryFlag.fromCountryCode(
                                  countryCodes[currencyCodes.indexOf(item)],
                                  shape: const RoundedRectangle(3),
                                  height: 23,
                                  width: 35,
                                ),
                                Container(
                                  margin: const EdgeInsets.only(left: 15),
                                  child: Text(
                                    item,
                                    style: GoogleFonts.poppins(
                                      color: Colors.black,
                                      fontSize: 17,
                                    ),
                                  ),
                                ),
                                // Flexible(
                                //   child: Container(
                                //     margin: const EdgeInsets.only(left: 10),
                                //     child: Text(
                                //       currencyNames[
                                //           currencyCodes.indexOf(item)],
                                //       overflow: TextOverflow.ellipsis,
                                //       style: GoogleFonts.poppins(
                                //         color: const Color(0xff636363),
                                //         fontSize: 17,
                                //       ),
                                //     ),
                                //   ),
                                // ),
                                const Spacer(),
                                Text(
                                  exchangeRatesValues.isNotEmpty == true
                                      ? "${getCurrency(item)} ${exchangeRatesValues[exchangeRatesRecords.indexOf(item)]}"
                                      : "${getCurrency(item)} 0",
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 17,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Container(
                          margin: const EdgeInsets.only(top: 10),
                          width: MediaQuery.of(context).size.width,
                          alignment: Alignment.center,
                          child: IconButton(
                            onPressed: () => showDialog<String>(
                              context: context,
                              builder: (BuildContext context) => Dialog(
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.fromLTRB(
                                            15, 15, 15, 5),
                                        child: Text(
                                          "Select Currency to Add",
                                          style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.fromLTRB(
                                            10, 10, 10, 0),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 0, horizontal: 10),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                            color: const Color(0xFFE7E7E7),
                                          ),
                                        ),
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: DropdownButton(
                                          menuMaxHeight: 500,
                                          underline: Container(),
                                          iconSize: 24,
                                          isExpanded: true,
                                          onChanged: (value) {
                                            setState(() {
                                              exchangeRatesRecords.add(value!);
                                            });
                                            initializeExchangeRates();
                                            Navigator.pop(context);
                                          },
                                          value: exchangeRateAddInitialValue,
                                          items: items,
                                        ),
                                      ),
                                      const SizedBox(height: 15),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Close'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            icon: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.add_outlined,
                                  color: Color(0xff0900FF),
                                ),
                                Container(
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  child: Text(
                                    "Add Currency",
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xff0900FF),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
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

  //function para ma-fetch yung data mula sa API
  Future<ExchangeRates> fetchExchangeRates() async {
    //loading test data
    String jsonString = await rootBundle.loadString('assets/test_data.json');
    return ExchangeRates.fromJson(
        jsonDecode(jsonString) as Map<String, dynamic>);

    // final response = await http.get(Uri.parse(
    //     'https://api.currencyapi.com/v3/latest?apikey=${Env.apiKey}'));

    // if (response.statusCode == 200) {
    //   return ExchangeRates.fromJson(
    //       jsonDecode(response.body) as Map<String, dynamic>);
    // } else {
    //   throw Exception('Failed to load convertions');
    // }
  }
}

//function para ma-update yung value sa homepage widget
void updateAndroidWidget(String count) {
  HomeWidget.saveWidgetData("text", count);
  HomeWidget.updateWidget(
    androidName: "ExchangeRateWidget",
  );
}

//function para makuha yung currency symbol ng currency code
String getCurrency(String currencyCode) {
  var format = NumberFormat.simpleCurrency(name: currencyCode);
  return format.currencySymbol;
}

import 'dart:convert';
import 'dart:async';

//import for test data
import 'package:flutter/services.dart' show rootBundle;

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:currency/currencies/currencies.dart';
import 'package:country_flags/country_flags.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:home_widget/home_widget.dart';
import 'package:currency/classes/exchange_rates.dart';
import 'package:currency/env/env.dart';
import 'package:http/http.dart' as http;

class WidgetSettings extends StatefulWidget {
  const WidgetSettings({super.key});

  @override
  State<WidgetSettings> createState() => _WidgetSettingsState();
}

class _WidgetSettingsState extends State<WidgetSettings> {
  late Future<ExchangeRates> futureExchangeRates;
  String? selectedValue1 = "148";
  String? selectedValue2 = "114";
  bool isSaveButtonEnabled = true;
  String saveButtonString = "Save";

  //code kung san nilalagay isa isa yung value mula sa currencies.dart na file
  final List<DropdownMenuItem<String>> items =
      currencyCodes.asMap().entries.map((entry) {
    int index = entry.key;
    String currency = entry.value;

    //eto yung structure ang laman ng drop down menu ng mga currencies
    return DropdownMenuItem(
      value: index.toString(),
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

  void saveWidgetData(String from, String to) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      String exchangeFrom = currencyCodes[int.parse(from)];
      String exchangeTo = currencyCodes[int.parse(to)];
      String exchangeFromFlag = countryCodes[int.parse(from)];
      String exchangeToFlag = countryCodes[int.parse(to)];
      String exchangeFromCountry = currencyNames[int.parse(from)];
      String exchangeToCountry = currencyNames[int.parse(to)];
      await prefs.setString('exchange_from_index', from);
      await prefs.setString('exchange_to_index', to);
      await prefs.setString('exchange_from', exchangeFrom);
      await prefs.setString('exchange_to', exchangeTo);
      await prefs.setString('exchange_from_flag', exchangeFromFlag);
      await prefs.setString('exchange_to_flag', exchangeToFlag);
      await prefs.setString('exchange_from_country', exchangeFromCountry);
      await prefs.setString('exchange_to_country', exchangeToCountry);

      updateAndroidWidget(exchangeFrom, exchangeTo, exchangeFromFlag,
          exchangeToFlag, exchangeFromCountry, exchangeToCountry);

      Fluttertoast.showToast(
          msg: "Home Widget settings saved.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);
    } catch (e) {
      print("ERROR: $e");
      Fluttertoast.showToast(
          msg: "Saving failed.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }

    setState(() {
      isSaveButtonEnabled = true;
      saveButtonString = "Save";
    });
  }

  void initializeWidgetSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? exchangeFrom = prefs.getString('exchange_from');
    if (exchangeFrom == null) {
      await prefs.setString('exchange_from', "USD");
      await prefs.setString('exchange_to', "PHP");
      await prefs.setString('exchange_from_flag', "US");
      await prefs.setString('exchange_to_flag', "PH");
      await prefs.setString('exchange_from_country', "USD - US Dollar");
      await prefs.setString('exchange_to_country', "PHP - Philippine Peso");
      await prefs.setString('exchange_from_index', "148");
      await prefs.setString('exchange_from_index', "114");
    } else {
      final String? exchangeFrom = prefs.getString('exchange_from_index');
      final String? exchangeTo = prefs.getString('exchange_to_index');
      setState(() {
        selectedValue1 = exchangeFrom;
        selectedValue2 = exchangeTo;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    futureExchangeRates = fetchExchangeRates();
    initializeWidgetSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: AlignmentDirectional.topStart,
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/widget_settings.png'),
                fit: BoxFit.fill,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 30, 0, 20),
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.arrow_back,
                        ),
                      ),
                      Text(
                        "Widget Settings",
                        style: GoogleFonts.poppins(
                          fontSize: 25,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    "Exchange Rate Widget",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.fromLTRB(30, 15, 30, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "From",
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
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
                            });
                          },
                          value: selectedValue1,
                          items: items,
                        ),
                      ),
                      Text(
                        "To",
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 10, bottom: 15),
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
                            });
                          },
                          value: selectedValue2,
                          items: items,
                        ),
                      ),
                      TextButton(
                        onPressed: !isSaveButtonEnabled
                            ? null
                            : () async {
                                setState(() {
                                  isSaveButtonEnabled = false;
                                  saveButtonString = "Loading...";
                                });
                                saveWidgetData(
                                    selectedValue1!, selectedValue2!);
                              },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          backgroundColor: const Color(0xff302C9F),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            saveButtonString,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //function para ma-fetch yung data mula sa API
  Future<ExchangeRates> fetchExchangeRates() async {
    //loading test data
    // String jsonString = await rootBundle.loadString('assets/test_data.json');
    // return ExchangeRates.fromJson(
    //     jsonDecode(jsonString) as Map<String, dynamic>);

    final response = await http.get(Uri.parse(
        'https://api.currencyapi.com/v3/latest?apikey=${Env.apiKey}'));

    if (response.statusCode == 200) {
      return ExchangeRates.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to load convertions');
    }
  }

//function para makuha yung currency symbol ng currency code
  String getCurrency(String currencyCode) {
    var format = NumberFormat.simpleCurrency(name: currencyCode);
    return format.currencySymbol;
  }

  void updateAndroidWidget(
      String exchangeFrom,
      String exchangeTo,
      String exchangeFromFlag,
      String exchangeToFlag,
      String exchangeFromCountry,
      String exchangeToCountry) {
    futureExchangeRates.then((onValue) {
      HomeWidget.saveWidgetData("widget_exchange_from", exchangeFrom);
      HomeWidget.saveWidgetData("widget_exchange_to", exchangeTo);
      HomeWidget.saveWidgetData("widget_exchange_from_flag", exchangeFromFlag);
      HomeWidget.saveWidgetData("widget_exchange_to_flag", exchangeToFlag);
      HomeWidget.saveWidgetData(
          "widget_exchange_from_country", exchangeFromCountry);
      HomeWidget.saveWidgetData(
          "widget_exchange_to_country", exchangeToCountry);

      double? haveRate = onValue.data[exchangeFrom]?.value;
      //exchange rate value ng currency na gusto mong i-convert
      double? wantRate = onValue.data[exchangeTo]?.value;
      double wantAmount;
      //computation ng value ng currency na gusto mong i-convert
      wantAmount = haveRate! * wantRate!;
      HomeWidget.saveWidgetData("widget_exchange_from_rate",
          "${getCurrency(exchangeFrom)} ${onValue.data[exchangeFrom]?.value.toStringAsFixed(2)}");
      HomeWidget.saveWidgetData("widget_exchange_to_rate",
          "${getCurrency(exchangeTo)} ${wantAmount.toStringAsFixed(2)}");

      print(exchangeFrom);
      print(exchangeTo);
      print(exchangeFromFlag);
      print(exchangeToFlag);
      print(exchangeFromCountry);
      print(exchangeToCountry);
      print(
          "${getCurrency(exchangeFrom)} ${onValue.data[exchangeFrom]?.value.toStringAsFixed(2)}");
      print(
          "${getCurrency(exchangeTo)} ${onValue.data[exchangeTo]?.value.toStringAsFixed(2)}");

      HomeWidget.updateWidget(
        androidName: "ExchangeRateWidget",
      );
    });
  }
}

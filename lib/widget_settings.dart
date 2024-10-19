import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:currency/currencies/currencies.dart';
import 'package:country_flags/country_flags.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class WidgetSettings extends StatefulWidget {
  const WidgetSettings({super.key});

  @override
  State<WidgetSettings> createState() => _WidgetSettingsState();
}

class _WidgetSettingsState extends State<WidgetSettings> {
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
      await prefs.setString('exhange_from', currencyCodes[int.parse(from)]);
      await prefs.setString('exhange_to', currencyCodes[int.parse(to)]);
      await prefs.setString('exhange_from_flag', countryCodes[int.parse(from)]);
      await prefs.setString('exhange_to_flag', countryCodes[int.parse(to)]);
      await prefs.setString(
          'exhange_from_country', currencyNames[int.parse(from)]);
      await prefs.setString('exhange_to_country', currencyNames[int.parse(to)]);

      Fluttertoast.showToast(
          msg: "Home Widget settings saved.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);
    } catch (e) {
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
}

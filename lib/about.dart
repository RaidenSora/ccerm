import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class About extends StatefulWidget {
  const About({super.key});

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> {
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
                image: AssetImage('assets/about.png'),
                fit: BoxFit.fill,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 30, 0, 30),
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
                        "About",
                        style: GoogleFonts.poppins(
                          fontSize: 25,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    "Welcome to CCERM( Currency Converter and Exchange Rates Monitor) application! We are dedicated to providing users with accurate, real-time currency conversion and exchange rate information. Our goal is to empower travelers, businesses, OFWs, and anyone dealing with international transactions by simplifying the process of currency exchange. With a user-friendly interface and reliable data sourced from trusted financial institutions, we aim to help you make informed decisions and stay updated in a fast-paced global economy. Thank you for choosing us as your go-to resource for currency exchange needs.",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

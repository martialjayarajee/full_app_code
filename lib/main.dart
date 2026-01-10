import 'package:full_app_code/src/Screens/Phone_no.dart';
import 'package:full_app_code/src/views/Home.dart';
import 'package:full_app_code/src/widgets/Navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; // 👈 Add this import
import 'package:full_app_code/src/Screens/ScoreCard.dart';
import 'package:full_app_code/src/viewmodels/ScoreManager.dart';
import 'package:full_app_code/src/viewmodels/ScoreController.dart';
import 'package:full_app_code/src/views/Sliding_page.dart';
import 'package:full_app_code/src/Screens/advanced.settings_screen.dart';
import 'package:full_app_code/src/views/Venue.dart';
import 'package:full_app_code/src/views/alerts_page.dart';
import 'package:full_app_code/src/views/bluetooth_page.dart';
// This file will be auto-generated

void main() {// 👈 Opens or creates your local ObjectBox database

  runApp(
    ChangeNotifierProvider(
      create: (_) => ScoreController(),
      child: FigmaToCodeApp(),
    ),
  );
}

class FigmaToCodeApp extends StatelessWidget {
  const FigmaToCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ScoreManager()),
          ChangeNotifierProvider(create: (_) => ScoreController())
        ],
        child: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: SlidingPage(), // 👈 Your scoreboard page
            theme: ThemeData(
                textTheme: GoogleFonts.poppinsTextTheme(
                  Theme.of(context).textTheme,
                )
            )
        )
    );
  }
}




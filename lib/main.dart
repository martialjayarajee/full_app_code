import 'package:flutter/material.dart';
import 'package:full_app_code/src/database/objectbox.dart';
import 'package:full_app_code/src/views/Sliding_page.dart';
import 'package:google_fonts/google_fonts.dart';

late ObjectBoxDB objectBoxDB;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize ObjectBox BEFORE runApp
  objectBoxDB = await ObjectBoxDB.create();

  runApp(MyApp(objectBoxDB: objectBoxDB));
}

class MyApp extends StatelessWidget {
  final ObjectBoxDB objectBoxDB;

  const MyApp({
    super.key,
    required this.objectBoxDB,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SlidingPage(),
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
    );
  }
}
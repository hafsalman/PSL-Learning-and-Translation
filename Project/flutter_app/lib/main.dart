import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/login_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const PSLApp());
}

class PSLApp extends StatelessWidget {
  const PSLApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "PSL Dictionary",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "Montserrat", // use clean modern font
        scaffoldBackgroundColor: Color(0xFFF5D7DB),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF06142E),
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      home: LoginScreen(),
    );
  }
}

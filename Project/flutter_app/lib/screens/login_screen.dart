import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'signup_screen.dart';
import 'home_screen.dart';
import 'splash_screen.dart';


class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailC = TextEditingController();
  final passC = TextEditingController();

  // PALETTE
  final Color kDarkNavy = const Color(0xFF06142E);
  final Color kSalmon = const Color(0xFFBD83B8);
  final Color kMutedPurple = const Color(0xFF473E66);
  final Color kLightLilac = const Color(0xFFF2E7FE); // Light Lilac Background

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400]),
      filled: true,
      fillColor: Colors.grey[100],
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: kSalmon, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: kLightLilac, // 1. Light Lilac Background
      body: SingleChildScrollView(
        child: SizedBox(
          height: size.height,
          child: Column(
            children: [

              Expanded(
                flex: 1, // Takes 1/3 of space
                child: Center(
                  child: Image.asset(
                    "assets/logo.png",
                    height: 120, // Adjust logo size as needed
                    fit: BoxFit.contain,
                  ),
                ),
              ),


              Expanded(
                flex: 2, // Takes 2/3 of space
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: kDarkNavy,
                        ),
                      ),
                      const SizedBox(height: 30),

                      Text("Email", 
                          style: TextStyle(color: kMutedPurple, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: emailC,
                        decoration: _buildInputDecoration("example@gmail.com"),
                      ),
                      const SizedBox(height: 20),

                      Text("Password", 
                          style: TextStyle(color: kMutedPurple, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: passC,
                        obscureText: true,
                        decoration: _buildInputDecoration("****************"),
                      ),
                      const SizedBox(height: 10),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: Text(
                            "Forgot password?",
                            style: TextStyle(color: kMutedPurple),
                          ),
                        ),
                      ),
                      
                      const Spacer(), // Pushes buttons to the bottom of the form area

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kSalmon,
                          minimumSize: const Size(double.infinity, 55),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
onPressed: () async {
  if (emailC.text.isEmpty || passC.text.isEmpty) return;
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: emailC.text.trim(),
      password: passC.text.trim(),
    );
    // CHANGED: Go to Splash Screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => SplashScreen()),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login failed: ${e.toString()}")));
  }
},
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: TextStyle(color: kMutedPurple),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.push(context,
                                MaterialPageRoute(builder: (_) => SignupScreen())),
                            child: Text(
                              "Sign Up",
                              style: TextStyle(
                                color: kSalmon,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
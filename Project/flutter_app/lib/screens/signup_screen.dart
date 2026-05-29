import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'splash_screen.dart';


class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final emailC = TextEditingController();
  final passC = TextEditingController();

  final Color kDarkNavy = const Color(0xFF06142E);
  final Color kSalmon = const Color(0xFFBD83B8);
  final Color kMutedPurple = const Color(0xFF473E66);
  final Color kLightLilac = const Color(0xFFF2E7FE);

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
      backgroundColor: kLightLilac,
      body: SingleChildScrollView(
        child: SizedBox(
          height: size.height,
          child: Column(
            children: [

              Expanded(
                flex: 1,
                child: Center(
                  child: Image.asset(
                    "assets/logo.png",
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                ),
              ),


              Expanded(
                flex: 2,
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
                      // TITLE
                      Text(
                        "Sign Up",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: kDarkNavy,
                        ),
                      ),
                      const SizedBox(height: 30),

                      Text("Email",
                          style: TextStyle(
                              color: kMutedPurple, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: emailC,
                        decoration: _buildInputDecoration("example@gmail.com"),
                      ),
                      const SizedBox(height: 20),

                      Text("Password",
                          style: TextStyle(
                              color: kMutedPurple, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: passC,
                        obscureText: true,
                        decoration: _buildInputDecoration("**************"),
                      ),
                      const SizedBox(height: 15),

                      const Spacer(),

                      ElevatedButton(
onPressed: () async {
  try {
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
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
      SnackBar(content: Text("Signup failed: $e")));
  }
},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kSalmon,
                          minimumSize: const Size(double.infinity, 55),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Sign Up",
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
                            "Already have an account? ",
                            style: TextStyle(color: kMutedPurple),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => LoginScreen()),
                            ),
                            child: Text(
                              "Login",
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

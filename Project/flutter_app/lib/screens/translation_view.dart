import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class TranslationView extends StatefulWidget {
  const TranslationView({Key? key}) : super(key: key);

  @override
  State<TranslationView> createState() => _TranslationViewState();
}

class _TranslationViewState extends State<TranslationView> {
  final Color kDarkNavy = const Color(0xFF06142E);
  final Color kPurple = const Color(0xFF473E66);
  final Color kLightPink = const Color(0xFFF5D7DB);

  // --- FYP AI CONFIGURATION ---
  // Replace with your Laptop's IPv4 Address (find via 'ipconfig')
  final String serverUrl = "http://192.168.18.16:5000/translate";

  Future<void> _handleMedia(bool isCamera) async {
    final ImagePicker picker = ImagePicker();
    final XFile? video = await picker.pickVideo(
      source: isCamera ? ImageSource.camera : ImageSource.gallery,
    );

    if (video != null) {
      _uploadAndTranslate(File(video.path));
    }
  }

  Future<void> _uploadAndTranslate(File videoFile) async {
    // 1. Show Loading Dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 15),
            Text("AI is translating sign..."),
          ],
        ),
      ),
    );

    try {
      var request = http.MultipartRequest('POST', Uri.parse(serverUrl));
      request.files.add(await http.MultipartFile.fromPath('video', videoFile.path));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        _showResult(data['prediction'], data['confidence']);
      } else {
        _showError("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      _showError("Connection Failed. Ensure phone and laptop are on the same Wi-Fi.");
    }
  }

  void _showResult(String result, double confidence) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Translation Result"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(result, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue)),
            Text("Confidence: ${(confidence * 100).toStringAsFixed(1)}%"),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [kLightPink.withOpacity(0.4), Colors.white],
          )
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text("Translate", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: kDarkNavy)),
                Text("Sign to Text Recognition", style: TextStyle(fontSize: 16, color: kPurple)),
                const SizedBox(height: 40),
                _buildActionCard(
                  title: "Record Sign",
                  subtitle: "Open camera to record a sign", 
                  icon: Icons.videocam_rounded,
                  onTap: () => _handleMedia(true),
                ),
                const SizedBox(height: 20),
                _buildActionCard(
                  title: "Upload Video",
                  subtitle: "Select an MP4 from gallery",
                  icon: Icons.upload_file_rounded,
                  onTap: () => _handleMedia(false),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({required String title, required String subtitle, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
          border: Border.all(color: Colors.grey.shade200)
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: kDarkNavy.withOpacity(0.05), shape: BoxShape.circle),
              child: Icon(icon, color: kDarkNavy, size: 30),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kDarkNavy)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey[400], size: 16)
          ],
        ),
      ),
    );
  }
}
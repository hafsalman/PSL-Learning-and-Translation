import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../../services/firebase_service.dart';
import '../../widgets/cropped_video_player.dart';

class QuizScreen extends StatefulWidget {
  final String chapterId;
  final List<dynamic> allWords;
  final List<dynamic> quizChunk;

  const QuizScreen({
    Key? key, 
    required this.chapterId, 
    required this.allWords, 
    required this.quizChunk
  }) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final service = FirebaseService();
  
  List<Map<String, dynamic>> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  bool _isAnswered = false;
  String? _selectedAnswer;

  // PALETTE
  final Color kDarkNavy = const Color(0xFF06142E);
  final Color kSalmon = const Color(0xFFF1916D);
  final Color kLightGrey = const Color(0xFFF5F5F5);
  final Color kGreen = const Color(0xFF4CAF50);
  final Color kRed = const Color(0xFFE57373);
  final Color kLightPink = const Color(0xFFF5D7DB); // For gradient

  @override
  void initState() {
    super.initState();
    _generateQuizLocally();
  }

  void _generateQuizLocally() {
    List<Map<String, dynamic>> generated = [];

    for (var qDoc in widget.quizChunk) {
      String correctAnswer = qDoc['word'] ?? "Unknown";
      String videoUrl = qDoc['videoUrl'] ?? "";

      if (videoUrl.isEmpty) continue;

      List<String> options = [correctAnswer];
      
      // Create pool of wrong answers
      List<dynamic> potentialDistractors = List.from(widget.allWords)..removeWhere((w) => w['word'] == correctAnswer);
      potentialDistractors.shuffle();

      // Pick up to 3 distractors
      for (int i = 0; i < min(3, potentialDistractors.length); i++) {
        options.add(potentialDistractors[i]['word'] ?? "Unknown");
      }
      
      options.shuffle(); 

      generated.add({
        'videoUrl': videoUrl,
        'correctAnswer': correctAnswer,
        'options': options,
      });
    }

    setState(() {
      _questions = generated..shuffle(); // Shuffle questions order
    });
  }

  void _handleAnswer(String answer) {
    if (_isAnswered) return;

    bool isCorrect = answer == _questions[_currentIndex]['correctAnswer'];
    setState(() {
      _isAnswered = true;
      _selectedAnswer = answer;
      if (isCorrect) _score++;
    });

    Timer(const Duration(milliseconds: 1000), _nextQuestion);
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _isAnswered = false;
        _selectedAnswer = null;
      });
    } else {
      _finishQuiz();
    }
  }

  Future<void> _finishQuiz() async {
    await service.saveQuizScore(widget.chapterId, _score);
    _showResultDialog();
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        double percentage = (_score / _questions.length) * 100;
        bool passed = percentage >= 50;

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: passed ? Colors.green[50] : Colors.red[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    passed ? Icons.emoji_events : Icons.sentiment_dissatisfied,
                    size: 60,
                    color: passed ? kGreen : kRed,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  passed ? "Great Job!" : "Keep Practicing",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kDarkNavy),
                ),
                const SizedBox(height: 10),
                Text(
                  "You scored $_score out of ${_questions.length}",
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kDarkNavy,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.pop(context); 
                      Navigator.pop(context); 
                    },
                    child: const Text("Done", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(body: Center(child: Text("Preparing quiz...", style: TextStyle(color: kSalmon))));
    }

    var currentQ = _questions[_currentIndex];
    var options = currentQ['options'] as List<String>;
    double progress = (_currentIndex + 1) / _questions.length;

    return Scaffold(
      extendBodyBehindAppBar: true, // Allows the gradient to flow under the AppBar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: kDarkNavy),
          onPressed: () => Navigator.pop(context),
        ),
        title: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation(kSalmon),
            minHeight: 8,
          ),
        ),
      ),
      body: Container(
        // Modern sleek gradient background
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [kLightPink.withOpacity(0.5), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // CROPPED VIDEO CONTAINER
              Container(
                height: MediaQuery.of(context).size.height * 0.35,
                width: double.infinity,
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CroppedVideoPlayer(
                    key: ValueKey(currentQ['videoUrl']),
                    videoUrl: currentQ['videoUrl'],
                  ),
                ),
              ),

              Text("What is this sign?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[700])),
              const SizedBox(height: 20),

              // MCQ OPTIONS
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: options.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    String option = options[index];
                    bool isCorrect = option == currentQ['correctAnswer'];
                    bool isSelected = option == _selectedAnswer;

                    Color borderColor = Colors.grey.shade300;
                    Color bgColor = Colors.white;
                    Color textColor = kDarkNavy;

                    if (_isAnswered) {
                      if (isSelected) {
                        borderColor = isCorrect ? kGreen : kRed;
                        bgColor = isCorrect ? kGreen.withOpacity(0.1) : kRed.withOpacity(0.1);
                        textColor = isCorrect ? kGreen : kRed;
                      } else if (isCorrect) {
                        borderColor = kGreen;
                        textColor = kGreen;
                      }
                    }

                    return GestureDetector(
                      onTap: () => _handleAnswer(option),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor, width: 2),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(option, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                            if (_isAnswered && isSelected)
                              Icon(isCorrect ? Icons.check_circle : Icons.cancel, color: textColor)
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
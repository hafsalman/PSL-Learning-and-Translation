import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';
import '../video_screen.dart';
import 'quiz_screen.dart';
import 'dart:math';

class LessonDetailsScreen extends StatefulWidget {
  final String chapterId;
  final String chapterName;

  const LessonDetailsScreen({Key? key, required this.chapterId, required this.chapterName}) : super(key: key);

  @override
  _LessonDetailsScreenState createState() => _LessonDetailsScreenState();
}

class _LessonDetailsScreenState extends State<LessonDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final service = FirebaseService();
  List<dynamic> _allWords = [];
  bool _isLoading = true;

  // PALETTE
  final Color kDarkNavy = const Color(0xFF06142E);
  final Color kSalmon = const Color(0xFFF1916D);
  final Color kLightGrey = const Color(0xFFF5F5F5);
  final Color kLightPink = const Color(0xFFFFC0CB);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchWords();
  }

  Future<void> _fetchWords() async {
    var words = await service.getWords(widget.chapterId);
    setState(() {
      _allWords = words;
      _isLoading = false;
    });
  }

  @override
@override
  Widget build(BuildContext context) {
    return Scaffold(
      // CHANGED: Removed plain white scaffold background
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Make app bar transparent
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: kDarkNavy), onPressed: () => Navigator.pop(context)),
        centerTitle: true,
        title: Text(widget.chapterName, style: TextStyle(color: kDarkNavy, fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      body: Container(
        // CHANGED: Added soft, modern gradient background
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [kLightPink.withOpacity(0.6), Colors.white, Colors.white],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? Center(child: CircularProgressIndicator(color: kSalmon))
              : Column(
                  children: [
                    const SizedBox(height: 10),
                    // CHANGED: Sleek Free/Premium style Toggle
                    Container(
                      height: 50,
                      margin: const EdgeInsets.symmetric(horizontal: 30),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200, // Light grey container
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        indicator: BoxDecoration(
                          color: Colors.black, // Sleek black active state
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2))],
                        ),
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.grey.shade500,
                        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        tabs: const [Tab(text: "Lessons"), Tab(text: "Quizzes")],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildLearnTab(),
                          _buildQuizTab(), 
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildLearnTab() {
    if (_allWords.isEmpty) return Center(child: Text("No words found.", style: TextStyle(color: Colors.grey)));

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: _allWords.length,
      separatorBuilder: (_, __) => const SizedBox(height: 15),
      itemBuilder: (context, index) {
        var w = _allWords[index];
        return GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => VideoScreen(chapterId: widget.chapterId, wordId: w['id'], chapterName: widget.chapterName, wordTitle: w['word'])
          )),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Row(
              children: [
                Container(
                  height: 50, width: 50,
                  decoration: BoxDecoration(color: kSalmon.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.play_arrow_rounded, color: kSalmon, size: 30),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(w['word'], style: TextStyle(color: kDarkNavy, fontSize: 18, fontWeight: FontWeight.bold)),
                      Text("Tap to watch video", style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey[300]),
              ],
            ),
          ),
        );
      },
    );
  }

  // MULTIPLE QUIZ CHUNKING LOGIC
  Widget _buildQuizTab() {
    if (_allWords.length < 4) {
      return Padding(
        padding: const EdgeInsets.all(30.0),
        child: Center(child: Text("Not enough words in this chapter to create a quiz. (Minimum 4 required).", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 16))),
      );
    }

    int questionsPerQuiz = 15; // Set how many questions you want per quiz
    int totalQuizzes = (_allWords.length / questionsPerQuiz).ceil();

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: totalQuizzes,
      separatorBuilder: (_, __) => const SizedBox(height: 15),
      itemBuilder: (context, index) {
        int startIdx = index * questionsPerQuiz;
        int endIdx = min(startIdx + questionsPerQuiz, _allWords.length);
        
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: kDarkNavy.withOpacity(0.1), shape: BoxShape.circle),
                        child: Icon(Icons.quiz, color: kDarkNavy),
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Quiz ${index + 1}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kDarkNavy)),
                          Text("Words ${startIdx + 1} to $endIdx", style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kSalmon,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  // Extract the specific chunk of words for this quiz
                  List<dynamic> chunk = _allWords.sublist(startIdx, endIdx);
                  
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => QuizScreen(
                      chapterId: widget.chapterId,
                      allWords: _allWords, // Pass all words for distractor generation
                      quizChunk: chunk,    // Pass specific chunk to be tested
                    )
                  ));
                },
                child: const Text("Start Quiz", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              )
            ],
          ),
        );
      },
    );
  }
}
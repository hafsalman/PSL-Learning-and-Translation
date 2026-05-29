import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import 'video_screen.dart';

class WordsScreen extends StatelessWidget {
  final String chapterId;
  final String chapterName;

  WordsScreen({required this.chapterId, required this.chapterName});

  final service = FirebaseService();

  // Define default palette colors
  final Color kDarkNavy = const Color(0xFF06142E);
  final Color kNavyBlue = const Color(0xFF1B3358);
  final Color kSalmon = const Color(0xFFF1916D);
  final Color kMutedPurple = const Color(0xFF473E66);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDarkNavy,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      chapterName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Content List
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: FutureBuilder(
                  future: service.getWords(chapterId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator(color: kSalmon));
                    }

                    if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.library_books_outlined, size: 60, color: Colors.grey[300]),
                            const SizedBox(height: 10),
                            Text("No words found in this chapter", style: TextStyle(color: Colors.grey[400])),
                          ],
                        ),
                      );
                    }

                    var words = snapshot.data as List;

                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                      itemCount: words.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 15),
                      itemBuilder: (_, i) {
                        var w = words[i];
                        String wordTitle = w["word"];

                        // UPDATE: Pass the default colors here
                        return buildWordCard(context, wordTitle, w["id"], kDarkNavy, kSalmon);
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // UPDATE: Method signature now accepts colors
  Widget buildWordCard(BuildContext context, String word, String wordId, Color textColor, Color iconColor) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VideoScreen(
            chapterId: chapterId,
            wordId: wordId,
            chapterName: chapterName,
            wordTitle: word,
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Word Text
            Text(
              word,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor, // Use dynamic text color
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1), // Use dynamic icon color
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.play_arrow_rounded,
                color: iconColor, // Use dynamic icon color
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
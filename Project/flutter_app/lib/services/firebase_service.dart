import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math'; // Required for min() and shuffle

class FirebaseService {
  // Use one instance variable for clarity
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --------------------------------------------------
  // CONTENT FETCHING (Standard)
  // --------------------------------------------------

  Future<List<Map<String, dynamic>>> getChapters() async {
    // Changed "db" to "_db" for consistency
    var data = await _db.collection("chapters").get();
    return data.docs.map((d) => {"id": d.id, ...d.data()}).toList();
  }

  Future<List<Map<String, dynamic>>> getWords(String chapterId) async {
    var data = await _db
        .collection("chapters")
        .doc(chapterId)
        .collection("words")
        .get();
    return data.docs.map((d) => {"id": d.id, ...d.data()}).toList();
  }

  Future<Map<String, dynamic>> getVideo(String chapterId, String wordId) async {
    var doc = await _db
        .collection("chapters")
        .doc(chapterId)
        .collection("words")
        .doc(wordId)
        .get();
    // Added safety check
    if (!doc.exists) return {}; 
    return doc.data()!;
  }

  // --------------------------------------------------
  // QUIZ SERVICES
  // --------------------------------------------------

  // 1. Generate Quiz Data (10 random questions with options)
  Future<List<Map<String, dynamic>>> generateQuiz(String chapterId) async {
    try {
      // FIX: Changed 'psl_data' to 'chapters' to match the rest of your app
      QuerySnapshot snapshot = await _db
          .collection('chapters') 
          .doc(chapterId)
          .collection('words')
          .get();

      List<QueryDocumentSnapshot> allDocs = snapshot.docs;
      
      if (allDocs.length < 4) {
        // Not enough words to create multiple choice options
        // You might want to return an empty list or handle this gracefully in UI
        print("Warning: Not enough words in chapter ($chapterId) for a quiz.");
        return []; 
      }

      // Shuffle and pick 10 for questions (or less if total < 10)
      allDocs.shuffle();
      int questionCount = min(10, allDocs.length);
      List<QueryDocumentSnapshot> questionDocs = allDocs.sublist(0, questionCount);

      List<Map<String, dynamic>> quizData = [];

      for (var qDoc in questionDocs) {
        var data = qDoc.data() as Map<String, dynamic>;
        
        // Ensure keys exist to prevent crashes
        String correctAnswer = data['word'] ?? "Unknown";
        String videoUrl = data['videoUrl'] ?? "";

        if (videoUrl.isEmpty) continue; // Skip invalid entries

        // Generate distractors (wrong answers)
        List<String> options = [correctAnswer];
        
        // Create a pool of potential wrong answers
        List<QueryDocumentSnapshot> potentialDistractors = List.from(allDocs)..remove(qDoc);
        potentialDistractors.shuffle();

        // Pick 3 distractors
        for (int i = 0; i < min(3, potentialDistractors.length); i++) {
          var distractorData = potentialDistractors[i].data() as Map<String, dynamic>;
          options.add(distractorData['word'] ?? "Unknown");
        }
        
        options.shuffle(); // Shuffle options so correct isn't always first

        quizData.add({
          'videoUrl': videoUrl,
          'correctAnswer': correctAnswer,
          'options': options,
        });
      }
      return quizData;
    } catch (e) {
      print("Error generating quiz: $e");
      rethrow;
    }
  }

  // 2. Save User Score
  Future<void> saveQuizScore(String chapterId, int score) async {
    User? user = _auth.currentUser;
    if (user == null) return; // Guard against null user

    try {
      DocumentReference userQuizRef = _db
          .collection('users')
          .doc(user.uid)
          .collection('quiz_scores')
          .doc(chapterId);

      DocumentSnapshot doc = await userQuizRef.get();
      int currentHighScore = 0;
      if (doc.exists && doc.data() != null) {
        currentHighScore = (doc.data() as Map<String, dynamic>)['highScore'] ?? 0;
      }

      // Only update if the new score is higher
      if (score > currentHighScore) {
        await userQuizRef.set({
          'highScore': score,
          'lastTaken': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      print("Error saving score: $e");
    }
  }

  // 3. Get User High Score for a Chapter
  Future<int> getHighScore(String chapterId) async {
    User? user = _auth.currentUser;
    if (user == null) return 0;

    try {
      DocumentSnapshot doc = await _db
          .collection('users')
          .doc(user.uid)
          .collection('quiz_scores')
          .doc(chapterId)
          .get();

      if (doc.exists && doc.data() != null) {
        return (doc.data() as Map<String, dynamic>)['highScore'] ?? 0;
      }
    } catch (e) {
      print("Error fetching high score: $e");
    }
    return 0; // Default if no score exists
  }
}
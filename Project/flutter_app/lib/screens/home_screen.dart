import 'package:flutter/material.dart';
import 'chapters_screen.dart'; 
import 'community_screen.dart'; 
import 'lessons/lesson_roadmap_screen.dart'; 
import 'package:image_picker/image_picker.dart'; // Add this to your imports
import 'translation_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final Color kDarkNavy = const Color(0xFF06142E);
  final Color kSalmon = const Color(0xFFF1916D);

  final List<Widget> _pages = [
    LessonRoadmapScreen(),  
    ChaptersScreen(),       
    TranslationView(),      
    CommunityScreen(),      
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],

      // Wrapped in Container for Drop Shadow
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              spreadRadius: 5,
              offset: const Offset(0, -5), // Shadow upwards
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0, // Disable default elevation to use custom shadow
          currentIndex: _currentIndex,
          selectedItemColor: kSalmon,
          unselectedItemColor: Colors.grey[400],
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.map, size: 28)), // Larger Icon
              label: "Lessons"
            ),
            BottomNavigationBarItem(
              icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.book, size: 28)),
              label: "Dictionary"
            ),
            BottomNavigationBarItem(
              icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.translate, size: 28)),
              label: "Translate"
            ),
            BottomNavigationBarItem(
              icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.people, size: 28)),
              label: "Community"
            ),
          ],
        ),
      ),
    );
  }
}

// --- TRANSLATION VIEW MODULE ---
// --- TRANSLATION VIEW MODULE ---

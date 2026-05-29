import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import 'words_screen.dart';

class ChaptersScreen extends StatefulWidget {
  @override
  _ChaptersScreenState createState() => _ChaptersScreenState();
}

class _ChaptersScreenState extends State<ChaptersScreen> {
  // --- ADD THIS HELPER FUNCTION ---
  String _cleanChapterName(String rawName) {
    // This removes any numbers followed by a dot and space at the start of the string
    return rawName.replaceAll(RegExp(r'^\d+\.\s*'), '').trim();
  }
  final service = FirebaseService();

  final List<Color> customPalette = [
    const Color(0xFF06142E), // Dark Navy
    const Color(0xFF1B3358), // Navy Blue
    const Color(0xFF473E66), // Muted Purple/Grey
    const Color(0xFFBD83B8), // Lavender
    const Color(0xFFF5D7DB), // Pale Pink
    const Color(0xFFF1916D), // Salmon/Orange
  ];

  @override
  Widget build(BuildContext context) {
    // Note: No Scaffold here because this is a body widget inside HomeScreen's Scaffold
    return Stack(
      children: [
        // Background Image
        Container(
          height: double.infinity,
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/chapters.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(color: Colors.black.withOpacity(0.1)),
        ),

        SafeArea(
          child: Column(
            children: [
              // Header (Without Back Button)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Row(
                  children: [
                    // Replaced Back Button with just an Icon or logo if desired, or kept empty
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.menu_book, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 15),
                    const Text(
                      "Dictionary Chapters",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              // Grid Content
              Expanded(
                child: FutureBuilder(
                  future: service.getChapters(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Colors.white));
                    }
                    if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
                      return const Center(child: Text("No chapters found", style: TextStyle(color: Colors.white)));
                    }

                    var chapters = snapshot.data as List;

                    return GridView.builder(
                      padding: const EdgeInsets.fromLTRB(15, 0, 15, 20),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4, 
                        crossAxisSpacing: 10, 
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.0, 
                      ),
                      itemCount: chapters.length,
                      itemBuilder: (_, i) {
var c = chapters[i];
                        
                        // --- APPLY THE CLEANER HERE ---
                        String rawName = c["name"] ?? "Unknown";
                        String name = _cleanChapterName(rawName); 
                        
                        Color baseColor = customPalette[i % customPalette.length];
                        Color displayColor = baseColor.withOpacity(0.9);
                        bool isDark = baseColor.computeLuminance() < 0.5;
                        String emoji = _getEmojiForChapter(name);

                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => WordsScreen(chapterId: c["id"], chapterName: name),
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: displayColor,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white.withOpacity(0.15), width: 0.5),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // White Circle for Emoji
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.25),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    emoji,
                                    style: const TextStyle(fontSize: 18), 
                                  ),
                                ),
                                const SizedBox(height: 6),
                                
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 3),
                                  child: Text(
                                    name,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: isDark ? Colors.white : const Color(0xFF06142E),
                                      fontSize: 10, 
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper: Emoji Mapper (Kept same)
  String _getEmojiForChapter(String name) {
    String key = name.toLowerCase();
    if (key.contains("abc") || key.contains("alphabet")) return "🔤";
    if (key.contains("automobile") || key.contains("car")) return "🚗";
    if (key.contains("bank")) return "🏦";
    if (key.contains("bath")) return "🚽";
    if (key.contains("beach")) return "🏖️";
    if (key.contains("beauty")) return "💄";
    if (key.contains("bedroom")) return "🛏️";
    if (key.contains("bird")) return "🐦";
    if (key.contains("anatomy") || key.contains("body")) return "🦴";
    if (key.contains("brand")) return "🏷️";
    if (key.contains("building")) return "🏢";
    if (key.contains("calendar") || key.contains("time")) return "📅";
    if (key.contains("carpenter")) return "🪚";
    if (key.contains("classroom") || key.contains("school")) return "🏫";
    if (key.contains("clean")) return "🧹";
    if (key.contains("cloth")) return "👕";
    if (key.contains("color")) return "🎨";
    if (key.contains("computer")) return "💻";
    if (key.contains("construct")) return "🏗️";
    if (key.contains("countr")) return "🌍";
    if (key.contains("death") || key.contains("funeral")) return "⚰️";
    if (key.contains("drink")) return "🥤";
    if (key.contains("educat")) return "🎓";
    if (key.contains("family")) return "👨‍👩‍👧";
    if (key.contains("famous")) return "🌟";
    if (key.contains("farm")) return "🚜";
    if (key.contains("flower") || key.contains("plant")) return "🌻";
    if (key.contains("food")) return "🍔";
    if (key.contains("fruit")) return "🍎";
    if (key.contains("geography")) return "🗺️";
    if (key.contains("govern")) return "🏛️";
    if (key.contains("grammar") || key.contains("adjective") || key.contains("noun")) return "📖";
    if (key.contains("holiday")) return "🎉";
    if (key.contains("health") || key.contains("medic")) return "🏥";
    if (key.contains("hospital")) return "🏨";
    if (key.contains("hygiene")) return "🧼";
    if (key.contains("insect")) return "🕷️";
    if (key.contains("islam")) return "☪️";
    if (key.contains("jewelry")) return "💍";
    if (key.contains("kitchen")) return "🍳";
    if (key.contains("law")) return "⚖️";
    if (key.contains("life skill")) return "🧠";
    if (key.contains("living room")) return "🛋️";
    if (key.contains("mammal")) return "🦁";
    if (key.contains("marine")) return "🐠";
    if (key.contains("math") || key.contains("number")) return "🔢";
    if (key.contains("media")) return "📺";
    if (key.contains("military")) return "🎖️";
    if (key.contains("music")) return "🎵";
    if (key.contains("office")) return "💼";
    if (key.contains("pakistan")) return "🇵🇰";
    if (key.contains("profession")) return "👷";
    if (key.contains("science")) return "🔬";
    return "📘";
  }
}
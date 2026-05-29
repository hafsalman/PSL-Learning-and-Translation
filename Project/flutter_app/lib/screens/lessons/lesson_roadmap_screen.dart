import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';
import 'lesson_details_screen.dart';
import 'dart:math' as math;
import 'package:firebase_auth/firebase_auth.dart';

class LessonRoadmapScreen extends StatefulWidget {
  @override
  _LessonRoadmapScreenState createState() => _LessonRoadmapScreenState();
}

class _LessonRoadmapScreenState extends State<LessonRoadmapScreen> with TickerProviderStateMixin {
  final service = FirebaseService();
  final User? user = FirebaseAuth.instance.currentUser;

  // --- PALETTE ---
  final Color kDarkNavy = const Color(0xFF06142E);
  final Color kSalmon = const Color(0xFFF1916D);
  final Color kPurple = const Color(0xFF473E66);
  final Color kLightPink = const Color(0xFFF5D7DB);

  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  // Helper to remove "1. ", "13. ", etc. from chapter names
  String cleanChapterName(String name) {
    return name.replaceAll(RegExp(r'^\d+\.\s*'), '').trim();
  }

  // Helper to assign emojis based on keywords
  String getEmojiForChapter(String name) {
    String key = name.toLowerCase();
    if (key.contains("abc") || key.contains("alphabet")) return "🔤";
    if (key.contains("food")) return "🍔";
    if (key.contains("color")) return "🎨";
    if (key.contains("pakistan")) return "🇵🇰";
    if (key.contains("science")) return "🔬";
    if (key.contains("animal") || key.contains("bird")) return "🦁";
    if (key.contains("number")) return "🔢";
    if (key.contains("place")) return "🕌";
    if (key.contains("time") || key.contains("calendar")) return "📅";
    if (key.contains("family")) return "👨‍👩‍👧";
    return "📘"; // Default
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset("assets/bg.jpg", fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.white.withOpacity(0.6)),
          ),

          // Animated Decorations
          _buildFloatingDecoration(top: 180, left: -20, size: 100, color: kSalmon.withOpacity(0.2), icon: Icons.cloud),
          _buildFloatingDecoration(top: 250, right: -30, size: 80, color: kPurple.withOpacity(0.15), icon: Icons.star),

          Column(
            children: [
              // COMPACT HEADER
              Container(
                padding: const EdgeInsets.fromLTRB(25, 50, 25, 20),
                decoration: BoxDecoration(
                  color: kLightPink,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.white,
                              backgroundImage: const AssetImage("assets/cat.jpg"),
                              onBackgroundImageError: (_, __) => {},
                              child: const Icon(Icons.person, color: Colors.grey),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Hello 👋", style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                                Text(
                                  user?.email?.split('@')[0] ?? "Learner",
                                  style: TextStyle(color: kDarkNavy, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(color: Colors.white54, shape: BoxShape.circle),
                          child: Icon(Icons.sort, color: kDarkNavy, size: 20),
                        )
                      ],
                    ),
                    const SizedBox(height: 15),
                    Text("Welcome Back!", style: TextStyle(color: kDarkNavy, fontSize: 28, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 2),
                    Text("Continue your lesson below 👇", style: TextStyle(color: kPurple, fontSize: 14, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),

              // DYNAMIC ROADMAP
              Expanded(
                child: FutureBuilder(
                  future: service.getChapters(),
                  builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator(color: kSalmon));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text("No chapters found."));
                    }

                    // Sort chapters by their numeric prefix
                    List<Map<String, dynamic>> chapters = snapshot.data!;
                    chapters.sort((a, b) {
                      int numA = int.tryParse(a['name'].toString().split('.').first) ?? 0;
                      int numB = int.tryParse(b['name'].toString().split('.').first) ?? 0;
                      return numA.compareTo(numB);
                    });

                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(top: 20, bottom: 40),
                      child: _buildZigZagMap(context, chapters),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildZigZagMap(BuildContext context, List<Map<String, dynamic>> chapters) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double width = constraints.maxWidth;
        double itemHeight = 140.0;

        return Stack(
          children: [
            CustomPaint(
              size: Size(width, itemHeight * chapters.length),
              painter: RoadMapPainter(
                itemCount: chapters.length,
                itemHeight: itemHeight,
                color: Colors.grey.shade300,
              ),
            ),
            Column(
              children: List.generate(chapters.length, (index) {
                final chapter = chapters[index];
                String rawName = chapter['name'] ?? "Unknown";
                String cleanName = cleanChapterName(rawName);
                String emoji = getEmojiForChapter(cleanName);
                bool isLeft = index % 2 == 0;

                return SizedBox(
                  height: itemHeight,
                  width: width,
                  child: Stack(
                    children: [
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 500),
                        left: isLeft ? width * 0.20 : null,
                        right: !isLeft ? width * 0.20 : null,
                        top: 10,
                        child: _buildLessonNode(context, chapter['id'], cleanName, emoji),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLessonNode(BuildContext context, String id, String title, String icon) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => LessonDetailsScreen(chapterId: id, chapterName: title)),
        );
      },
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: kSalmon,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 5),
              boxShadow: [
                BoxShadow(color: kSalmon.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10)),
              ],
            ),
            child: Center(child: Text(icon, style: const TextStyle(fontSize: 32))),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: kDarkNavy, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingDecoration({double? top, double? bottom, double? left, double? right, required double size, required Color color, required IconData icon}) {
    return Positioned(
      top: top, bottom: bottom, left: left, right: right,
      child: AnimatedBuilder(
        animation: _floatController,
        builder: (context, child) {
          return Transform.translate(offset: Offset(0, 10 * math.sin(_floatController.value * 2 * math.pi)), child: child);
        },
        child: Icon(icon, size: size, color: color),
      ),
    );
  }
}

// PAINTER STAYS THE SAME
class RoadMapPainter extends CustomPainter {
  final int itemCount;
  final double itemHeight;
  final Color color;

  RoadMapPainter({required this.itemCount, required this.itemHeight, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = 12..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    double leftX = size.width * 0.20 + 40;
    double rightX = size.width * 0.80 - 40;
    final path = Path();
    path.moveTo(leftX, 50);

    for (int i = 0; i < itemCount - 1; i++) {
      double startX = (i % 2 == 0) ? leftX : rightX;
      double endX = ((i + 1) % 2 == 0) ? leftX : rightX;
      double startY = (i * itemHeight) + 50;
      double endY = ((i + 1) * itemHeight) + 50;
      path.cubicTo(startX, startY + 80, endX, endY - 80, endX, endY);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
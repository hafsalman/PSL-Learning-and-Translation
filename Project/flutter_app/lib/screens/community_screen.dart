import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'package:url_launcher/url_launcher.dart'; 

class CommunityScreen extends StatelessWidget {
  // --- PALETTE ---
  final Color kBackground = const Color(0xFFF5D7DB); // Soft Pink
  final Color kHeader = const Color(0xFF1B3358);     // Deep Blue
  final Color kDarkNavy = const Color(0xFF06142E);   // Dark Navy (Text)
  final Color kPurple = const Color(0xFF473E66);     // Purple
  final Color kAccent = const Color(0xFFBD83B8);     // Accent
  final Color kCoral = const Color(0xFFF1916D);      // Coral (Buttons)

  // --- HELPER: LAUNCH URL ---
  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $url';
      }
    } catch (e) {
      debugPrint("Error launching URL: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ---------------------------
            // 1. CUSTOM APP BAR
            // ---------------------------
            _buildAppBar(context),

            // ---------------------------
            // 2. SCROLLABLE CONTENT
            // ---------------------------
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- HERO SECTION ---
                    _buildHeroSection(),

                    const SizedBox(height: 25),

                    // --- STATISTICS SECTION ---
                    _buildSectionTitle("Impact & Statistics"),
                    _buildStatisticsScroll(),

                    const SizedBox(height: 30),

                    // --- RESOURCES LINKS ---
                    _buildSectionTitle("Resources & Organizations"),
                    _buildResourceList(),

                    const SizedBox(height: 30),

                    // --- FESF ACKNOWLEDGEMENT ---
                    _buildFESFCard(),

                    const SizedBox(height: 30),

                    // --- DEVELOPERS ---
                    _buildSectionTitle("Meet the Developers"),
                    _buildDevelopersList(),

                    const SizedBox(height: 30),

                    // --- FAQ SECTION ---
                    _buildSectionTitle("Frequently Asked Questions"),
                    _buildFAQSection(),

                    const SizedBox(height: 30),

                    // --- INTERACTIVE MAP (Placeholder) ---
                    _buildSectionTitle("Support Centers"),
                    _buildMapPlaceholder(),

                    const SizedBox(height: 40),

                    // --- FEEDBACK BUTTON ---
                    Center(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kCoral,
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          elevation: 5,
                        ),
                        onPressed: () {
                          // Handle feedback action
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Feedback form opening...")),
                          );
                        },
                        icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
                        label: const Text(
                          "Submit Feedback",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // WIDGET BUILDERS
  // ---------------------------------------------------------------------------

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Profile Button (Left)
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProfileScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: kHeader.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 3)),
                ],
              ),
              child: Icon(Icons.person, color: kHeader, size: 24),
            ),
          ),
          
          Text("Community", 
            style: TextStyle(color: kHeader, fontSize: 22, fontWeight: FontWeight.bold)),
            
          // Empty container for balance
          const SizedBox(width: 44), 
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      height: 180,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: kHeader,
        borderRadius: BorderRadius.circular(25),
        image: const DecorationImage(
          image: AssetImage('assets/community_hero.jpg'), // Ensure this asset exists
          fit: BoxFit.cover,
          opacity: 0.4, 
        ),
        boxShadow: [
          BoxShadow(color: kHeader.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Awareness &",
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w300),
            ),
            Text(
              "Connection",
              style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              "Bridging the gap through PSL",
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Text(
        title,
        style: TextStyle(
          color: kHeader,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatisticsScroll() {
    return SizedBox(
      height: 140,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 20),
        physics: const BouncingScrollPhysics(),
        children: [
          _buildStatCard("12M+", "Deaf Persons\nin Pakistan", Icons.groups),
          _buildStatCard("35%", "Access to\nEducation", Icons.school),
          _buildStatCard("<5%", "Employment\nRate", Icons.work),
          const SizedBox(width: 20),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: kHeader.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: kCoral, size: 28),
          const Spacer(),
          Text(
            value,
            style: TextStyle(color: kHeader, fontSize: 26, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(color: kPurple, fontSize: 12, height: 1.2),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildResourceCard(
            "Pakistan Association of the Deaf (PAD)",
            "National association working for Deaf rights and community support.",
            "https://pad.org.pk",
            Icons.groups_outlined,
          ),
          const SizedBox(height: 15),
          _buildResourceCard(
            "Deaf Reach Schools",
            "Education and empowerment program for Deaf children by FESF.",
            "https://www.deafreach.org",
            Icons.school_outlined,
          ),
          const SizedBox(height: 15),
          _buildResourceCard(
            "National Forum of the Disabled (NFD)",
            "General disability advocacy including Deaf rights.",
            "http://nfdf.org",
            Icons.public_outlined,
          ),
          const SizedBox(height: 15),
          _buildResourceCard(
            "STEP Pakistan",
            "Inclusive education and vocational training for children with disabilities.",
            "https://step.org.pk",
            Icons.accessibility_new_outlined,
          ),
          const SizedBox(height: 15),
          _buildResourceCard(
            "PSL Support by FESF",
            "Official dictionaries and learning materials.",
            "https://psl.org.pk/",
            Icons.menu_book_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildResourceCard(String title, String desc, String url, IconData icon) {
    return GestureDetector(
      onTap: () => _launchURL(url),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white),
          boxShadow: [
            BoxShadow(color: kHeader.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kBackground,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: kHeader, size: 24),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: kHeader, fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(desc, style: TextStyle(color: kPurple, fontSize: 12)),
                  const SizedBox(height: 8),
                  Text(
                    "Visit Website ➡️",
                    style: TextStyle(color: kCoral, fontWeight: FontWeight.bold, fontSize: 12),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFESFCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kHeader, kPurple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: kHeader.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.handshake, color: kHeader), 
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("Powered by", style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Text("FESF Pakistan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 15),
          const Text(
            "Special thanks to Family Educational Services Foundation for their incredible work in Deaf education and PSL data.",
            style: TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: kHeader,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                _launchURL("https://fesf.org.pk/");
              },
              child: const Text("Support FESF"),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDevelopersList() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(left: 20),
      child: Row(
        children: [
          _buildDevCard("Amna Mansoor", "Full Stack Developer", "assets/dev1.jpg", "amnamansoor2468@gmail.com"),
          _buildDevCard("Hafsa Salman", "AI Engineer", "assets/dev2.png", "hafsalman0521@gmail.com"),
          _buildDevCard("Alizah Basit", "UI/UX Designer", "assets/dev3.png", null),
          const SizedBox(width: 20),
        ],
      ),
    );
  }

  Widget _buildDevCard(String name, String role, String imagePath, String? email) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white),
      ),
      child: Column(
        children: [
          // FIX: Used AssetImage to show the picture
          CircleAvatar(
            radius: 30,
            backgroundColor: kAccent.withOpacity(0.2),
            backgroundImage: AssetImage(imagePath), 
            onBackgroundImageError: (_, __) => const Icon(Icons.person), // Fallback if image missing
          ),
          const SizedBox(height: 10),
          Text(name, 
            textAlign: TextAlign.center,
            style: TextStyle(color: kHeader, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 2),
          Text(role, 
            textAlign: TextAlign.center,
            style: TextStyle(color: kPurple, fontSize: 11)),
          const SizedBox(height: 10),
          
          if (email != null)
            GestureDetector(
              onTap: () => _launchURL("mailto:$email"),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: kBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.email, size: 16, color: kCoral),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFAQSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _buildFAQTile("What is PSL?", "Pakistan Sign Language (PSL) is the visual language used by the Deaf community in Pakistan."),
          const Divider(height: 1),
          _buildFAQTile("How can I contribute?", "You can support by donating to FESF or spreading awareness about Deaf culture."),
          const Divider(height: 1),
          _buildFAQTile("Are the lessons free?", "Yes! This app is dedicated to providing free access to PSL learning resources."),
        ],
      ),
    );
  }

  Widget _buildFAQTile(String question, String answer) {
    return ExpansionTile(
      title: Text(question, style: TextStyle(color: kHeader, fontWeight: FontWeight.w600, fontSize: 14)),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      iconColor: kCoral,
      collapsedIconColor: kPurple,
      children: [
        Text(answer, style: TextStyle(color: kDarkNavy, fontSize: 13, height: 1.4)),
      ],
    );
  }

  Widget _buildMapPlaceholder() {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Stack(
        children: [
          const Center(
            child: Icon(Icons.map, size: 60, color: Colors.grey),
          ),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kHeader,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              onPressed: () {},
              child: const Text("View Interactive Map", style: TextStyle(color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../services/firebase_service.dart';

class VideoScreen extends StatefulWidget {
  final String chapterId;
  final String wordId;
  final String chapterName;
  final String wordTitle; 

  VideoScreen({
    required this.chapterId, 
    required this.wordId,
    required this.chapterName, 
    required this.wordTitle,
  });

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  VideoPlayerController? _controller;
  final service = FirebaseService();
  bool _isPlaying = false;
  bool _isInitialized = false;

  // YOUR PALETTE
  final Color kDarkNavy = const Color(0xFF06142E);
  final Color kSalmon = const Color(0xFFF1916D);

  @override
  void initState() {
    super.initState();
    loadVideo();
  }

  void loadVideo() async {
    try {
      var data = await service.getVideo(widget.chapterId, widget.wordId);
      
      _controller = VideoPlayerController.networkUrl(Uri.parse(data["videoUrl"]))
        ..initialize().then((_) {
          setState(() {
            _isInitialized = true;
            _isPlaying = true;
          });
          _controller!.setLooping(true); // Loop enabled
          _controller!.play();
        });
    } catch (e) {
      print("Error loading video: $e");
    }
  }

  void _togglePlay() {
    if (_controller == null || !_isInitialized) return;

    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
        _isPlaying = false;
      } else {
        _controller!.play();
        _isPlaying = true;
      }
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDarkNavy, // Header Background
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back Button
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.wordTitle, // Main Title (Word)
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Chapter: ${widget.chapterName}", // Subtitle
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),


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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isInitialized && _controller != null)
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: AspectRatio(
                          aspectRatio: _controller!.value.aspectRatio,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: VideoPlayer(_controller!),
                              ),
                              
                              GestureDetector(
                                onTap: _togglePlay,
                                child: Container(
                                  color: Colors.transparent, // Invisible hit box
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),

                              if (!_isPlaying)
                                IgnorePointer(
                                  child: Container(
                                    padding: const EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.4),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.play_arrow_rounded,
                                      color: kSalmon, // Palette Color
                                      size: 50,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      )
                    else
                      Center(
                        child: CircularProgressIndicator(color: kSalmon),
                      ),

                    const SizedBox(height: 20),
                    
                    if (_isInitialized)
                      Text(
                        "Tap video to pause/resume",
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
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
}
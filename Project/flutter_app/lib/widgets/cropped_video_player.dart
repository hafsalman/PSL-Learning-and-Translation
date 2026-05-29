import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CroppedVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const CroppedVideoPlayer({Key? key, required this.videoUrl}) : super(key: key);

  @override
  State<CroppedVideoPlayer> createState() => _CroppedVideoPlayerState();
}

class _CroppedVideoPlayerState extends State<CroppedVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        // Ensure we mount the state only if the widget is still active
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
          _controller.setVolume(0.0); // MUTE AUDIO
          _controller.setLooping(true);
          _controller.play();
        }
      }).catchError((error) {
        print("Video initialization error: $error");
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. SAFETY CHECK: If not ready or aspect ratio is invalid (0.0), show loader
    if (!_isInitialized || _controller.value.aspectRatio == 0.0) {
      return Container(
        color: Colors.black,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final double videoWidth = _controller.value.size.width;
    final double videoHeight = _controller.value.size.height;
    
    // We want to show half the width, same height
    final double targetAspectRatio = (videoWidth / 2) / videoHeight;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: 2),
        color: Colors.black,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      // ClipRRect ensures the corners are rounded for the video too
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        // AspectRatio forces the container to be the shape of the "Half Video"
        child: AspectRatio(
          aspectRatio: targetAspectRatio,
          // LayoutBuilder gives us the exact size of this half-box
          child: LayoutBuilder(
            builder: (context, constraints) {
              // We calculate the size the FULL video should be to fit this height
              double renderHeight = constraints.maxHeight;
              double renderWidth = renderHeight * _controller.value.aspectRatio;

              // Stack allows us to position the video arbitrarily
              return Stack(
                children: [
                  Positioned(
                    top: 0,
                    bottom: 0,
                    left: 0, // Anchor to left
                    // Force the video to be its full calculated width (which is 2x our box)
                    width: renderWidth, 
                    child: VideoPlayer(_controller),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Full-screen image viewer with pinch-to-zoom and Hero animation.
class ImageViewer extends StatelessWidget {
  final String imageUrl;
  final String heroTag;

  const ImageViewer({super.key, required this.imageUrl, required this.heroTag});

  static Route<void> route(String imageUrl, String heroTag) {
    return PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.black,
      transitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (_, __, ___) => ImageViewer(imageUrl: imageUrl, heroTag: heroTag),
      transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Center(
          child: Hero(
            tag: heroTag,
            child: InteractiveViewer(
              minScale: 1,
              maxScale: 4,
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
                placeholder: (_, __) => const CircularProgressIndicator(color: Colors.white),
                errorWidget: (_, __, ___) => const Icon(Icons.broken_image_outlined, size: 48, color: Colors.white54),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

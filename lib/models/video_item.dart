class VideoItem {
  const VideoItem({
    required this.title,
    required this.videoId,
    required this.duration,
  });

  final String title;
  final String videoId;
  final String duration;

  bool get hasValidVideoId => RegExp(r'^[A-Za-z0-9_-]{11}$').hasMatch(videoId);
}

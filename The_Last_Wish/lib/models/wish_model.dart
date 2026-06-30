class WishModel {
  final String wish;
  final String curse;
  final String videoUrl;
  final DateTime time;

  WishModel({
    required this.wish,
    required this.curse,
    required this.videoUrl,
    required this.time,
  });

  Map<String, dynamic> toMap() {
    return {"wish": wish, "curse": curse, "videoUrl": videoUrl, "time": time};
  }
}

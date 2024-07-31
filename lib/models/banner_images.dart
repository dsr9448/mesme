class BannerImage {
  final String imgUrl;

  BannerImage({required this.imgUrl});

  factory BannerImage.fromJson(Map<String, dynamic> json) {
    return BannerImage(
      imgUrl: json['imgUrl'],
    );
  }
}
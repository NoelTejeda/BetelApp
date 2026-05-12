class AppContentModel {
  final List<String> carouselImages;
  final String aboutUs;
  final String location;
  final String commissions;

  AppContentModel({
    required this.carouselImages,
    required this.aboutUs,
    required this.location,
    required this.commissions,
  });

  factory AppContentModel.fromMap(Map<String, dynamic> map) {
    return AppContentModel(
      carouselImages: List<String>.from(map['carouselImages'] ?? []),
      aboutUs: map['aboutUs'] ?? '',
      location: map['location'] ?? '',
      commissions: map['commissions'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'carouselImages': carouselImages,
      'aboutUs': aboutUs,
      'location': location,
      'commissions': commissions,
    };
  }

  factory AppContentModel.empty() {
    return AppContentModel(
      carouselImages: [],
      aboutUs: '',
      location: '',
      commissions: '',
    );
  }
}

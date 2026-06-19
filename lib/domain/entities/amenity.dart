class Amenity {
  final String id;
  final String title;
  final String imageUrl;
  final String? policy;

  Amenity({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.policy,
  });
}
